import 'package:flutter/material.dart';
import 'package:moyousky/widgets/post/facets/facets.dart';
import 'package:moyousky/services/post_service.dart';
import 'package:moyousky/services/report_service.dart';
import 'package:moyousky/widgets/post/actions/actions.dart';
import 'package:moyousky/widgets/post/post_component/post_widgets.dart';
import 'package:moyousky/repository/shared_preferences_repository.dart' as spr;
import 'package:moyousky/animation/fade_route.dart';
import 'package:moyousky/views/user_profile.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/widgets/post/embed/manager.dart';
import 'package:moyousky/views/post_details.dart';
import 'package:moyousky/utils/post_author_data.dart';

class Post extends StatefulWidget {
  final bsky.FeedView feedView;
  final String postTime;

  const Post({
    Key? key,
    required this.feedView,
    required this.postTime,
  }) : super(key: key);

  @override
  PostState createState() => PostState();
}

class PostState extends State<Post> {
  bool isLiked = false;
  int likeCount = 0;
  bool isReposted = false;
  int repostCount = 0;
  bool myOwnPost = false;

  String get postDid => widget.feedView.post.author.did ?? '';
  late final PostService postApiService;
  late final ReportService reportApiService;
  final sharedPreferencesRepository = spr.SharedPreferencesRepository();

  @override
  void initState() {
    super.initState();
    likeCount = widget.feedView.post.likeCount;
    repostCount = widget.feedView.post.repostCount;
    isLiked = widget.feedView.post.viewer.like != null ? true : false;
    isReposted = widget.feedView.post.viewer.repost != null ? true : false;
    postApiService = PostService();
    reportApiService = ReportService();
    _checkOwnership();
  }

  Future<void> _checkOwnership() async {
    String myDid = await sharedPreferencesRepository.getDiD();
    String authorDid = widget.feedView.post.author.did ?? '';
    if (mounted) {
      setState(() {
        myOwnPost = myDid == authorDid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.feedView.post;
    final author = post.author;
    final reason = widget.feedView.toJson()['reason'];
    final parentPostAuthor = widget.feedView.toJson()?['reply']?['parent']
        ?['author']?['displayName'];
    final postAuthor = AuthorData(
      displayName: author.displayName ?? author.handle,
      handle: author.handle,
      avatar: author.avatar,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reason?['\$type'] == 'app.bsky.feed.defs#reasonRepost') ...[
              Padding(
                  padding: const EdgeInsets.only(left: 40.5),
                  child: Row(
                    children: [
                      const Icon(Icons.repeat,
                          size: 16.0, color: Color(0xff737373)),
                      const SizedBox(width: 4.0),
                      Text('${reason['by']['displayName']}さんがリポストしました',
                          style: const TextStyle(
                            color: Color(0xff7f7f7f),
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  )),
              const SizedBox(height: 6.0),
            ],
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  FadeRoute(
                    page: PostDetails(
                      uri: post.uri,
                      authorData: postAuthor,
                    ),
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4, bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                            FadeRoute(page: UserProfile(did: author.did)));
                      },
                      child: CircleAvatar(
                        backgroundImage: (author.avatar != null)
                            ? NetworkImage(author.avatar.toString())
                            : null,
                        child: (author.avatar == null)
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: author.displayName.toString(),
                                      style: const TextStyle(
                                        fontSize: 18.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const WidgetSpan(
                                      child: SizedBox(width: 5.0),
                                    ),
                                    TextSpan(
                                      text: '@${author.handle.toString()}',
                                      style: const TextStyle(
                                          color: Colors.black45),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5.0),
                              child: Text(
                                widget.postTime,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        if (parentPostAuthor != null) ...[
                          Row(
                            children: [
                              Icon(Icons.reply, color: Colors.grey[600]),
                              const SizedBox(width: 4.0),
                              Flexible(
                                child: Text(
                                  '$parentPostAuthorさんへ返信しました',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2.0),
                        ],
                        Container(
                          width: double.infinity, // これにより、Rowの全幅を使用します
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                FadeRoute(
                                  page: PostDetails(
                                    uri: post.uri,
                                    authorData: postAuthor,
                                  ),
                                ),
                              );
                            },
                            child: FacetsProcessing(
                              postData: {
                                'post': {
                                  'record': {
                                    'text': post.record.text.toString(),
                                    'facets':
                                        post.record.toJson()['facets'] ?? [],
                                  },
                                },
                              },
                            ),
                          ),
                        ),
                        EmbedManager(post: widget.feedView.post),
                        const SizedBox(height: 13.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            iconTextWidget(
                              Icons.comment_rounded,
                              post.replyCount,
                              (_) {},
                            ),
                            iconTextWidget(
                              Icons.repeat,
                              repostCount,
                              () => handleRepostAction(
                                  widget.feedView.post,
                                  isReposted,
                                  postApiService, (newState, countChange) {
                                setState(() {
                                  isReposted = newState;
                                  repostCount += countChange;
                                });
                              }),
                              color: isReposted ? Colors.green : Colors.black45,
                            ),
                            iconTextWidget(
                              Icons.favorite,
                              likeCount,
                              () => handleFavoriteAction(
                                  widget.feedView.post, isLiked, postApiService,
                                  (newState, countChange) {
                                setState(() {
                                  isLiked = newState;
                                  likeCount += countChange;
                                });
                              }),
                              color:
                                  isLiked ? Colors.redAccent : Colors.black45,
                            ),
                            GestureDetector(
                              onTap: () => showBottomSheetCustom(
                                  context,
                                  widget.feedView,
                                  postApiService,
                                  reportApiService,
                                  myOwnPost),
                              child: const Icon(
                                Icons.more_horiz,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
