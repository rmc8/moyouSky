import 'package:flutter/material.dart';

import 'package:bluesky/bluesky.dart' as bsky;
import 'package:timeago/timeago.dart' as timeago;

import 'package:moyousky/utils/fade_route.dart';
import 'package:moyousky/views/user_profile.dart';
import 'package:moyousky/widgets/post/facets/facets.dart';
import 'package:moyousky/widgets/post/embed/manager.dart';

class SubPostWidget extends StatelessWidget {
  final List<bsky.PostThreadViewRecord?> postList;
  final bool borderBottom;
  final bool borderTop;

  SubPostWidget({
    Key? key,
    required this.postList,
    this.borderBottom = false,
    this.borderTop = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (postList.isEmpty) return const SizedBox.shrink();
    return buildPosts(context);
  }


  Widget buildPosts(BuildContext context) {
    final borderWidget = Divider(color: Color(0XFFDBDBDB), thickness: 0.5);
    return Column(
      children: postList.map((thread) {
        if (thread == null) return const SizedBox.shrink();
        final post = thread.post;

        List<Widget> widgets = [];

        if (borderTop) {
          widgets.add(borderWidget);
        }

        widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildAvatar(post, context),
                  const SizedBox(width: 12.5),
                  viewPost(post),
                ],
              ),
            )
        );

        if (borderBottom) {
          widgets.add(borderWidget);
        }

        return Column(children: widgets);
      }).toList(),
    );
  }


  Expanded viewPost(bsky.Post post) {
    return Expanded(
      child: Column(
        children: [
          buildUserDetailRow(post),
          buildPostContent(post),
          Padding(padding: EdgeInsets.only(right: 12.0),
          child: EmbedManager(post: post)),
          buildPostAction(post),
        ],
      ),
    );
  }

  Widget buildAvatar(bsky.Post post, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(FadeRoute(page: UserProfile(did: post.author.did)));
        },
        child: Container(
          width: 46.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: (post.author.avatar != null &&
                    post.author.avatar!.isNotEmpty)
                    ? NetworkImage(post.author.avatar!)
                    : null,
                child:
                (post.author.avatar == null || post.author.avatar!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserDetailRow(bsky.Post post) {
    final displayName = post.author.displayName ?? post.author.handle;
    final handle = post.author.handle;
    final dateTime = DateTime.parse(post.record.createdAt.toString());
    final relativeTime = timeago.format(dateTime, locale: "ja");

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // DisplayName & Handle
        Expanded(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 17.5,
                  ),
                ),
                if (displayName != handle)
                  TextSpan(
                    text: " @$handle",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13.5,
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Created At (Relative Time)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            relativeTime,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPostContent(bsky.Post post) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
          padding: const EdgeInsets.only(right: 4.0, top: 6.5),
          child: FacetsProcessing(
            postData: {
              'post': {
                'record': {
                  'text': post.record.text.toString(),
                  'facets': post.record.toJson()['facets'] ?? [],
                },
              },
            },
          )),
    );
  }

  Widget buildPostAction(bsky.Post post) {
    final replyCount = post.replyCount;
    final repostCount = post.repostCount;
    final likeCount = post.likeCount;

    return Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _actionIconWithCount(
            icon: Icons.comment_rounded,
            count: replyCount,
            onTap: () {
              // TODO: reply action
            },
          ),
          _actionIconWithCount(
            icon: Icons.repeat,
            count: repostCount,
            color: post.isReposted ? Colors.green : Colors.black45,
            onTap: () {
              // TODO: repost action
            },
          ),
          _actionIconWithCount(
            icon: Icons.favorite,
            count: likeCount,
            color: post.isLiked ? Colors.redAccent : Colors.black45,
            onTap: () {
              // TODO: like action
            },
          ),
          InkWell(
            onTap: () {
              // TODO: other post action
            },
            child: const Icon(
              Icons.more_horiz,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIconWithCount({
    required IconData icon,
    required int count,
    Color? color,
    required void Function() onTap,
  }) {
    const defaultColor = Colors.black45;
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? defaultColor,
          ),
          const SizedBox(width: 6.0), // spacing between icon and text
          Text(
            '$count',
            style: TextStyle(color: color ?? defaultColor, fontSize: 14.5, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

}
