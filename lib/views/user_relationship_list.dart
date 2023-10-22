import 'package:flutter/material.dart';
import 'package:moyousky/services/actor_service.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/widgets/actor/actor_card.dart';

class UserRelationshipList extends StatefulWidget {
  final Function(String?) fetcher;
  final String title;

  const UserRelationshipList({
    super.key,
    required this.fetcher,
    required this.title,
  });

  @override
  UserRelationshipListState createState() => UserRelationshipListState();
}

class UserRelationshipListState extends State<UserRelationshipList> {
  late Future<ActorListResult> _actorsFuture;
  List<bsky.Actor> actorList = [];
  String? _latestCursor;
  bool isLoading = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    _initializeData();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      _fetchPastActors();
    }
  }

  Future<void> _initializeData() async {
    var initialActors = await widget.fetcher(null);
    setState(() {
      actorList.addAll(initialActors.actorList);
      _latestCursor = initialActors.cursor;
    });
  }

  Future<void> _fetchPastActors() async {
    if (_latestCursor == null || isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    var newActors = await widget.fetcher(_latestCursor);

    setState(() {
      actorList.addAll(newActors.actorList);
      _latestCursor = newActors.cursor;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Center(
          child: Text(
        widget.title,
        style:
            const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      )),
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: <Widget>[
        IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {}),
      ],
    );
  }

  NotificationListener _body() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification &&
            scrollNotification.metrics.pixels ==
                scrollNotification.metrics.maxScrollExtent) {
          _fetchPastActors();
        }
        return true;
      },
      child: ListView.builder(
        itemCount: actorList.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == actorList.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final actor = actorList[index];
          return ActorCard(actor: actor);
        },
      ),
    );
  }
}
