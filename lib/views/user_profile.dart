import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart';
import 'package:moyousky/services/actor_service.dart';
import 'package:moyousky/animation/fade_route.dart';
import 'package:moyousky/widgets/navigation/bottom_navi.dart';
import 'package:moyousky/views/search.dart';
import 'package:moyousky/views/timeline.dart';
import 'package:moyousky/widgets/user_profile/profile_section.dart' as ps;

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
    final ImageStream stream = NetworkImage(url!).resolve(const ImageConfiguration());
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
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 456.0,
            floating: false,
            pinned: true,
            flexibleSpace: ps.UserProfileHeader(profileData: profileData),
            leading: InkWell(
              onTap: () => Navigator.of(context).pop(), // 戻るボタンの動作
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xAA0000000),
                ),
                margin: const EdgeInsets.all(14.5),
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
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: Container(
                color: Colors.white,  // 背景色を設定
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
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: const <Widget>[ // ここにそれぞれのタブに対応するタイムラインを実装したいです。
                Center(child: Text('投稿の内容')),
                Center(child: Text('返信の内容')),
                Center(child: Text('画像の内容')),
                Center(child: Text('いいねの内容')),
              ],
            ),
          ),
        ],
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
