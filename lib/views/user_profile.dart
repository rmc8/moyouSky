import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart';
import 'package:moyousky/services/actor_service.dart';
import 'package:moyousky/animation/fade_route.dart';
import 'package:moyousky/widgets/navigation/bottom_navi.dart';
import 'package:moyousky/views/search.dart';
import 'package:moyousky/views/timeline.dart';
import 'package:moyousky/widgets/user_profile/profile_section.dart' as ps;
import 'package:moyousky/widgets/user_profile/feeds.dart';
import 'package:moyousky/services/author_feed_fetcher_service.dart';
import 'package:moyousky/utils/constants.dart' as cons;

class UserProfile extends StatefulWidget {
  final String did;

  const UserProfile({super.key, required this.did});

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final ActorService _apiService = ActorService();
  ActorProfile? profileData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await _apiService.fetchProfileDataObj(widget.did);
      setState(() {
        profileData = data;
      });
    } catch (e) {
      print('Error fetching profile: $e');
      // TODO: error handling
    }
  }

  Future<ImageInfo> _getImageInfo(String? url) async {
    final Completer<ImageInfo> completer = Completer();
    final ImageStream stream =
        NetworkImage(url!).resolve(const ImageConfiguration());
    final listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    });
    stream.addListener(listener);
    completer.future.then((_) => stream.removeListener(listener));
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 40.0,
        title: Text(
          profileData?.displayName ?? profileData?.handle ?? 'プロフィール',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
          ),
        ),
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(6.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xAA0000000),
            ),
            child: const Center(
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          InkWell(
            onTap: () {}, // TODO: メニューを開く動作
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xAA0000000),
              ),
              margin: const EdgeInsets.all(8.0),
              child: const Center(
                child: Icon(Icons.more_vert, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: NotificationListener<ScrollUpdateNotification>(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 440,
              floating: false,
              pinned: true,
              toolbarHeight: 52.5,
              flexibleSpace: ps.UserProfileHeader(profileData: profileData),
              leading: Icon(Icons.arrow_back, color: Colors.transparent),
              backgroundColor: Colors.white,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0.0),
                child: Material(
                  color: Colors.white,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4.5), // この行を追加
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      tabs: const <Widget>[
                        Tab(text: '投稿'),
                        Tab(text: '返信'),
                        Tab(text: '画像'),
                        Tab(text: 'いいね'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        AuthorFeedView(
                            feedFetcher: PostFetcher(actor: widget.did)),
                        AuthorFeedView(
                            feedFetcher: ReplyFetcher(actor: widget.did)),
                        AuthorFeedView(
                            feedFetcher: MediaPostFetcher(actor: widget.did)),
                        AuthorFeedView(
                            feedFetcher: LikeFetcher(actor: widget.did)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BskyBottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).push(FadeRoute(page: Timeline()));
          } else if (index == 1) {
            Navigator.of(context).push(FadeRoute(page: SearchScreen()));
          }
          // 他のindexの処理を追加することができます
        },
      ),
    );
  }
}
