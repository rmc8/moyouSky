import 'package:flutter/material.dart';

import 'package:bluesky/bluesky.dart' as bsky;

import 'package:moyousky/views/search.dart';
import 'package:moyousky/views/timeline.dart';
import 'package:moyousky/utils/fade_route.dart';
import 'package:moyousky/utils/post_author_data.dart';
import 'package:moyousky/widgets/post_detail/replies.dart';
import 'package:moyousky/widgets/post_detail/main_post.dart';
import 'package:moyousky/widgets/navigation/bottom_navi.dart';
import 'package:moyousky/widgets/common/headerLogo.dart' as hl;
import 'package:moyousky/widgets/post_detail/parent_posts.dart';
import 'package:moyousky/services/post_thread_service.dart' as pt;

class PostDetails extends StatefulWidget {
  final bsky.AtUri uri;
  final AuthorData authorData;

  const PostDetails({
    required this.uri,
    required this.authorData,
  });

  @override
  PostThreadState createState() => PostThreadState();
}

class PostThreadState extends State<PostDetails> {
  late Future<bsky.PostThread> _postThreadFuture;
  bool _showAdditionalWidgets = false;


  @override
  void initState() {
    super.initState();
    _postThreadFuture = pt.PostThreadService().getPostThread(widget.uri, 6);
  }

  void _onAuthorRowRendered() {
    Future.delayed(const Duration(microseconds: 100), () {
      setState(() {
        _showAdditionalWidgets = true;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }


  AppBar _buildAppBar() {
    return AppBar(
      title: hl.HeaderLogo(),
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black54),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.settings,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildPostThreadContent(),
        _buildReplyContainer(),
      ],
    );
  }

  FutureBuilder<bsky.PostThread> _buildPostThreadContent() {
    return FutureBuilder<bsky.PostThread>(
      future: _postThreadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data received.'));
        } else {
          bsky.PostThread postThreadData = snapshot.data!;
          return _buildContent(postThreadData);
        }
      },
    );
  }


  Widget _buildContent(bsky.PostThread postThreadData) {
    final record = postThreadData.thread.data as bsky.PostThreadViewRecord;
    return ListView(
      children: [
        if (_showAdditionalWidgets)
          PreviousRepliesWidget(postThreadData: record),
        AuthorRowWidget(
          postThreadData: postThreadData,
          authorData: widget.authorData,
          onRendered:_onAuthorRowRendered,
        ),
        if (_showAdditionalWidgets)
          ChildRepliesWidget(postThreadData: record),
        const SizedBox(height: 60.0),
      ],
    );
  }

  Positioned _buildReplyContainer() {
    final authorAvatar = widget.authorData.avatar;
    final authorName = widget.authorData.displayName;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          // TODO: 返信用のViewを表示する
        },
        child: Container(
          height: 60,
          decoration: const BoxDecoration(
            color: Color(0xFFFAFAFA),
            border: Border(
              top: BorderSide(
                color: Color(0xFFEEEEEE),
                width: 1.0,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22.0,
                  backgroundImage:
                  authorAvatar != null ? NetworkImage(authorAvatar) : null,
                  child: authorAvatar == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 13.5),
                Text(
                  '$authorNameさんに返信する',
                  style:
                  const TextStyle(fontSize: 18.0, color: Color(0xFF444444)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BskyBottomNavigationBar _buildBottomNavigationBar() {
    return BskyBottomNavigationBar(
      onTap: (index) {
        if (index == 0) {
          Navigator.of(context).push(FadeRoute(page: const Timeline()));
        } else if (index == 1) {
          Navigator.of(context).push(FadeRoute(page: SearchScreen()));
        }
        // 他のindexの処理を追加することができます
      },
    );
  }
}
