import 'package:flutter/material.dart';
import 'package:moyousky/widgets/post.dart';
import 'package:moyousky/services/bluesky_api_service.dart';
import 'package:moyousky/repository/shared_preferences_repository.dart';
import 'package:moyousky/utils/post_utils.dart';

class Timeline extends StatefulWidget {
  const Timeline({Key? key}) : super(key: key);

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts = [];
  final prefsRepository = SharedPreferencesRepository();
  late final apiService = BlueskyApiService(prefsRepository);

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final feedViews = await apiService.getTimeline();
    final List<Post> fetchedPosts = getPostWidgets(feedViews);

    setState(() {
      posts = fetchedPosts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.menu, color: Colors.black54),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud, color: Color.fromARGB(255, 74, 74, 74)),
              Padding(
                padding: EdgeInsets.only(left: 5.0),
                child:
                    Text('moyouSky', style: TextStyle(color: Colors.black87)),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
                icon: const Icon(
                  Icons.lightbulb,
                  color: Colors.black54,
                ),
                onPressed: () {}),
            IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.black54,
                ),
                onPressed: () {}),
          ],
        ),
        body: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) => posts[index],
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
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.black54),
              label: "Profile",
              backgroundColor: Colors.white,
            ),
          ],
        ));
  }
}
