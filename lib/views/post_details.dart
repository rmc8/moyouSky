import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/services/post_thread_service.dart' as pt;
import 'package:moyousky/widgets/common/headerLogo.dart' as hl;
import 'package:moyousky/utils/post_author_data.dart';
import 'package:moyousky/widgets/post/facets/facets.dart';
import 'package:moyousky/animation/fade_route.dart';
import 'package:moyousky/widgets/navigation/bottom_navi.dart';
import 'package:moyousky/views/timeline.dart';
import 'package:moyousky/views/search.dart';
import 'package:moyousky/widgets/post/embed/manager.dart';

class PostDetails extends StatefulWidget {
  final bsky.AtUri uri;
  final AuthorData authorData;

  const PostDetails({
    Key? key,
    required this.uri,
    required this.authorData,
  }) : super(key: key);

  @override
  PostThreadState createState() => PostThreadState();
}

class PostThreadState extends State<PostDetails> {
  late Future<bsky.PostThread> _postThreadFuture;

  @override
  void initState() {
    super.initState();
    _postThreadFuture = pt.PostThreadService().getPostThread(widget.uri, 6);
  }

  @override
  Widget build(BuildContext context) {
    final authorAvatar = widget.authorData.avatar;
    final authorName = widget.authorData.displayName;
    return Scaffold(
      appBar: AppBar(
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
              onPressed: () {}),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                FutureBuilder<bsky.PostThread>(
                  future: _postThreadFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return const Center(child: Text('No data received.'));
                    } else {
                      final postThreadData = snapshot.data;
                      return Column(
                        children: [
                          _buildAuthorRow(postThreadData!),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        Positioned(
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
                color: Colors.white12,
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
                      backgroundImage: authorAvatar != null
                          ? NetworkImage(authorAvatar)
                          : null,
                      child: authorAvatar == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 13.5),
                    Text(
                      '$authorNameさんに返信する',
                      style: const TextStyle(
                          fontSize: 18.0, color: Color(0xFF444444)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
      bottomNavigationBar: BskyBottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).push(FadeRoute(page: const Timeline()));
          } else if (index == 1) {
            Navigator.of(context).push(FadeRoute(page: SearchScreen()));
          }
          // 他のindexの処理を追加することができます
        },
      ),
    );
  }

  Widget _buildAuthorRow(bsky.PostThread postThreadData) {
    final postAuthorName = widget.authorData.displayName;
    final postAuthorHandle = widget.authorData.handle;
    final postAuthorAvatar = widget.authorData.avatar;
    final data = postThreadData.thread.data;
    final postData = (data as bsky.PostThreadViewRecord).post;
    final postValue = postData.record.text;
    final postedDate = postData.record.createdAt;
    final reactionExists = (postData.repostCount + postData.likeCount) > 0;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28.0,
                backgroundImage: postAuthorAvatar != null
                    ? NetworkImage(postAuthorAvatar)
                    : null,
                child: postAuthorAvatar == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10.5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    postAuthorName,
                    style: const TextStyle(fontSize: 21.5),
                  ),
                  Text(
                    '@$postAuthorHandle',
                    style: const TextStyle(color: Colors.grey, fontSize: 15.0),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: FacetsProcessing(
              postData: {
                'post': {
                  'record': {
                    'text': postValue,
                    'facets': postData.record.facets ?? [],
                  },
                },
              },
              fontSize: 20.0,
            ),
          ),
          EmbedManager(post: postData),
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 16.0, left: 4.0, right: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat('y年M月d日 H時m分', 'ja_JP').format(postedDate),
                style: const TextStyle(fontSize: 16.5, color: Colors.black45),
              ),
            ),
          ),
          if (reactionExists)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFCCCCCC), width: 0.5),
                  bottom: BorderSide(color: Color(0xFFCCCCCC), width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (postData.repostCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: InkWell(
                        onTap: () {
                          // onTapのアクションを実装する
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${postData.repostCount} ',
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const TextSpan(
                                text: 'リポスト',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (postData.likeCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: InkWell(
                        onTap: () {
                          // onTapのアクションを実装する
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${postData.likeCount} ',
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const TextSpan(
                                text: 'いいね',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          SizedBox(height: reactionExists ? 24.0 : 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // 等間隔で配置
            children: [
              InkWell(
                onTap: () {
                  // Icons.comment_rounded の onTap アクション
                },
                child: Icon(
                  Icons.comment_rounded,
                  color: Colors.black54,
                ),
              ),
              InkWell(
                onTap: () {
                  // Icons.comment_rounded の onTap アクション
                },
                child: Icon(
                  Icons.repeat,
                  color: Colors.black54,
                ),
              ),
              InkWell(
                onTap: () {
                  // Icons.favorite の onTap アクション
                },
                child: Icon(
                  Icons.favorite,
                  color: Colors.black54,
                ),
              ),
              InkWell(
                onTap: () {
                  // more_horiz の onTap アクション
                },
                child: Icon(
                  Icons.more_horiz,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
