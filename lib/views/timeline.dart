import 'package:flutter/material.dart';
import 'package:moyousky/widgets/post.dart';
import 'package:moyousky/services/bluesky_api_service.dart';
import 'package:moyousky/utils/database_helper.dart';
import 'package:moyousky/utils/post_utils.dart';
import 'package:moyousky/widgets/main_drawer.dart';

class Timeline extends StatefulWidget {
  const Timeline({Key? key}) : super(key: key);

  @override
  TimelineState createState() => TimelineState();
}

class TimelineState extends State<Timeline> {
  List<Post> posts = [];
  bool isLoading = false;
  bool showToTopButton = false;

  // final prefsRepository = SharedPreferencesRepository();
  late final apiService = BlueskyApiService(DatabaseHelper.instance);
  String cursor = "";
  String? nextCursor;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    _fetchPosts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

    setState(() {
      posts.addAll(fetchedPosts);
      isLoading = false;
    });
  }

  Future<void> _fetchNewPosts() async {
    final feedViews = await apiService.getTimeline(limit: 32, cursor: cursor);
    final fetchedPosts = getPostWidgets(feedViews.feeds);
    final List<Post> newPosts = [];

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
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black54),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // ドロワーを開く
              },
            );
          },
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud, color: Color.fromARGB(255, 74, 74, 74)),
            Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: Text('moyouSky', style: TextStyle(color: Colors.black87)),
            ),
          ],
        ),
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
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black54,
        unselectedItemColor: Colors.black54,
        selectedFontSize: 10.5,
        unselectedFontSize: 10.5,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_filled,
              color: Colors.black54,
            ),
            label: "Home",
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded, color: Colors.black54),
            label: "Search",
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed_rounded, color: Colors.black54),
            label: "Feed",
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, color: Colors.black54),
            label: "Notification",
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
