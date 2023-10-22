import 'package:flutter/material.dart';

import 'package:bluesky/bluesky.dart' as bsky;

import 'package:moyousky/utils/post_utils.dart';
import 'package:moyousky/widgets/post/post.dart';
import 'package:moyousky/services/author_feed_fetcher_service.dart';

class AuthorFeedView extends StatefulWidget {
  final Fetcher feedFetcher;

  AuthorFeedView({required this.feedFetcher});

  @override
  AuthorFeedViewState createState() => AuthorFeedViewState();
}

class AuthorFeedViewState extends State<AuthorFeedView> {
  List<bsky.FeedView> feedViews = [];
  List<Post> postWidgets = []; // このリストを追加
  String? cursor;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialPosts();
  }

  Future<void> _loadInitialPosts() async {
    setState(() {
      isLoading = true;
    });

    final result = await widget.feedFetcher.fetchPosts(null);
    feedViews = result.feedList;
    postWidgets = getPostWidgets(feedViews); // feedViewsをPostウィジェットに変換

    cursor = result.cursor;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadMorePosts() async {
    if (cursor == null || isLoading) return;

    setState(() {
      isLoading = true;
    });

    final result = await widget.feedFetcher.fetchPosts(cursor);
    feedViews.addAll(result.feedList);
    postWidgets
        .addAll(getPostWidgets(result.feedList)); // 追加のfeedViewsをPostウィジェットに変換

    cursor = result.cursor;

    setState(() {
      isLoading = false;
    });
  }

  // TODO: 最新の投稿をロードする関数をここに追加。

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: postWidgets.length + (isLoading ? 1 : 0), // postWidgetsの長さを使用
      itemBuilder: (context, index) {
        if (index == postWidgets.length) {
          return const Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(),
            ),
          );
        }

        return postWidgets[index]; // リストの各アイテムを直接返す
      },
      controller: _getScrollController(),
    );
  }

  ScrollController _getScrollController() {
    final controller = ScrollController();

    controller.addListener(() {
      if (controller.position.atEdge) {
        if (controller.position.pixels == 0) {
          // TODO: 最新の投稿をロード
        } else {
          _loadMorePosts();
        }
      }
    });

    return controller;
  }
}

