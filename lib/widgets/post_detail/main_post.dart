import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/utils/fade_route.dart';
import 'package:moyousky/views/user_profile.dart';
import 'package:moyousky/utils/post_author_data.dart';
import 'package:moyousky/widgets/post/facets/facets.dart';
import 'package:moyousky/widgets/post/embed/manager.dart';
import 'package:intl/intl.dart';


class AuthorRowWidget extends StatelessWidget {
  final bsky.PostThread postThreadData;
  final AuthorData authorData;
  final VoidCallback? onRendered;

  AuthorRowWidget({
    required this.postThreadData,
    required this.authorData,
    this.onRendered,
  });

  @override
  Widget build(BuildContext context) {
    final postAuthorName = authorData.displayName;
    final postAuthorHandle = authorData.handle;
    final postAuthorAvatar = authorData.avatar;
    final data = postThreadData.thread.data;
    final postData = (data as bsky.PostThreadViewRecord).post;
    final postValue = postData.record.text;
    final postedDate = postData.record.createdAt;
    final reactionExists = (postData.repostCount + postData.likeCount) > 0;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (onRendered != null) {
        onRendered!();
      }
    });

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(FadeRoute(page: UserProfile(did: authorData.did)));
                },
                child: CircleAvatar(
                  radius: 28.0,
                  backgroundImage: postAuthorAvatar != null
                      ? NetworkImage(postAuthorAvatar)
                      : null,
                  child: postAuthorAvatar == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 10.5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    postAuthorName,
                    style: const TextStyle(
                        fontSize: 20.5, fontWeight: FontWeight.bold),
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
            child: Align(
              alignment: Alignment.centerLeft,
              child: FacetsProcessing(
                postData: {
                  'post': {
                    'record': {
                      'text': postValue,
                      'facets': postData.record.toJson()['facets'] ?? [],
                    },
                  },
                },
                fontSize: 20.0,
              ),
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
                          // TODO: repost list
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
                          // TODO: like list
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
          SizedBox(height: reactionExists ? 16.5 : 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  // TODO: repost
                },
                child: const Icon(
                  Icons.comment_rounded,
                  color: Colors.black45,
                ),
              ),
              InkWell(
                onTap: () {
                  // TODO: リポストなどする
                },
                child: Icon(
                  Icons.repeat,
                  color: postData.isReposted ? Colors.green : Colors.black45,
                ),
              ),
              InkWell(
                onTap: () {
                  // TODO: postにいいねなどする
                },
                child: Icon(
                  Icons.favorite,
                  color: postData.isLiked ? Colors.redAccent : Colors.black45,
                ),
              ),
              InkWell(
                onTap: () {
                  // // TODO: postに対する操作
                },
                child: const Icon(
                  Icons.more_horiz,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
