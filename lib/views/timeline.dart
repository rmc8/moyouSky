import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moyousky/widgets/post/post.dart';
import 'package:moyousky/services/bluesky_api_service.dart';
import 'package:moyousky/utils/post_utils.dart';
import 'package:moyousky/widgets/drawer/main_drawer.dart';
import 'package:moyousky/widgets/common/headerLogo.dart' as hl;
import 'package:moyousky/views/search.dart';
import 'package:moyousky/animation/fade_route.dart';
import 'package:moyousky/widgets/drawer_button/main_drawer_btn.dart';
import 'package:moyousky/widgets/navigation/bottom_navi.dart';
import 'package:moyousky/notifiers/timeline_notifier.dart';
import 'package:moyousky/repository/shared_preferences_repository.dart';
import 'package:moyousky/utils/post_utils.dart';

final blueskyApiServiceProvider = Provider<BlueskyApiService>((ref) {
  return BlueskyApiService();
});

final timelineNotifierProvider = StateNotifierProvider<TimelineNotifier,
        Map<String, List<PostWithTimestamp>>>(
    (ref) => TimelineNotifier(ref.read(blueskyApiServiceProvider)));

final prefs = SharedPreferencesRepository();

class Timeline extends ConsumerStatefulWidget {
  const Timeline({Key? key}) : super(key: key);

  @override
  TimelineState createState() => TimelineState();
}

class TimelineState extends ConsumerState<Timeline>
    with AutomaticKeepAliveClientMixin<Timeline> {
  List<Post> posts = [];
  List<Map> postsJson = [];
  bool isLoading = false;
  bool showToTopButton = false;
  String? did;

  TimelineState({this.posts = const []});

  @override
  bool get wantKeepAlive => true;

  late final apiService = BlueskyApiService();
  String cursor = "";
  String? nextCursor;
  final _scrollController = ScrollController();

  TimelineState copyWith({List<Post>? posts}) {
    return TimelineState(posts: posts ?? this.posts);
  }

  late final StreamSubscription<String> _didChangeSubscription;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    _didChangeSubscription = prefs.didChange.listen((newDid) {
      print(newDid);
      setState(() {
        did = newDid;
        _initializeData();
      });
    });

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _didChangeSubscription.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    did = await prefs.getDiD();
    final postsData = ref.read(timelineNotifierProvider.notifier).getPostsData(did!);

    if (postsData != null) {
      final List<Post> postsFromData = getPostWidgets(postsData);
      setState(() {
        posts = postsFromData;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = true;
      });
      _fetchPosts();
    }
  }


  _scrollListener() {
    if (_scrollController.offset > 300 && !showToTopButton) {
      setState(() {
        showToTopButton = true;
      });
    } else if (_scrollController.offset <= 300 && showToTopButton) {
      setState(() {
        showToTopButton = false;
      });
    }
    if (_scrollController.offset <=
            _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        isLoading = true;
      });
      _fetchNewPosts();
    }
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        isLoading = true;
      });
      _fetchPastPosts();
    }
  }

  Future<void> _fetchPosts() async {
    final feedViews = await apiService.getTimeline(limit: 32, cursor: cursor);
    final List<Post> fetchedPosts = getPostWidgets(feedViews.feeds);

    nextCursor = feedViews.cursor;
    ref.read(timelineNotifierProvider.notifier).savePostsData(did!, feedViews.feeds);

    setState(() {
      posts = fetchedPosts;
      isLoading = false;
    });

  }

  Future<void> _fetchPastPosts() async {
    final feedViews =
        await apiService.getTimeline(limit: 32, cursor: nextCursor);
    final List<Post> fetchedPosts = getPostWidgets(feedViews.feeds);
    nextCursor = feedViews.cursor;
    ref.read(timelineNotifierProvider.notifier).savePostsData(did!, feedViews.feeds);

    setState(() {
      posts.addAll(fetchedPosts);
      isLoading = false;
    });
  }

  Future<void> _fetchNewPosts() async {
    final feedViews = await apiService.getTimeline(limit: 32, cursor: cursor);
    final fetchedPosts = getPostWidgets(feedViews.feeds);
    final List<Post> newPosts = [];
    ref.read(timelineNotifierProvider.notifier).savePostsData(did!, feedViews.feeds);
    for (var post in fetchedPosts) {
      if (!posts.contains(post)) {
        newPosts.add(post);
      } else {
        break;
      }
    }

    nextCursor = feedViews.cursor;
    setState(() {
      isLoading = false;
      posts = newPosts;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final did = prefs.getDiD();
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: UserAvatar(),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: hl.HeaderLogo(),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.black54,
              ),
              onPressed: () {}),
        ],
      ),
      drawer: const MainDrawer(),
      body: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: posts.length,
            itemBuilder: (context, index) => posts[index],
            addAutomaticKeepAlives: true,
          ),
          if (isLoading)
            const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black87,
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                // change post view
              },
              child: const Icon(Icons.add),
            ),
          ),
          if (showToTopButton)
            Positioned(
              bottom: 24,
              left: 16,
              width: 40,
              height: 40,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  _scrollController.animateTo(0,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut);
                },
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                child: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BskyBottomNavigationBar(
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).push(FadeRoute(page: SearchScreen()));
          }
          // 他のindexの処理を追加することができます
        },
      ),
    );
  }
}
