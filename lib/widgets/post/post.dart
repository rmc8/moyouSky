import 'package:flutter/material.dart';
import 'package:moyousky/widgets/post/facets/facets.dart';

class Post extends StatelessWidget {
  final Map<String, dynamic> feedView;
  final String postTime;

  const Post({
    Key? key,
    required this.feedView,
    required this.postTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final post = feedView['post'];
    final author = post['author'];

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4, bottom: 8),
              child: CircleAvatar(
                backgroundImage: NetworkImage(author['avatar']),
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
                                text: '${author['displayName']} ',
                                style: const TextStyle(
                                  fontSize: 18.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '@${author['handle']}',
                                style: const TextStyle(color: Colors.black45),
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        postTime,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  PostWithLinks(
                    postData: {
                      'post': {
                        'record': {
                          'text': post['record']['text'],
                          'facets': post['record']['facets'] ?? [],
                        }
                      }
                    },
                  ),

                  // TODO: Add embeds
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _iconTextWidget(
                          Icons.comment_rounded, post['replyCount']),
                      _iconTextWidget(Icons.repeat, post['repostCount']),
                      _iconTextWidget(Icons.favorite, post['likeCount']),
                      const Icon(
                        Icons.more_horiz,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconTextWidget(IconData icon, int count) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.black45,
        ),
        const SizedBox(width: 4.0),
        Text(
          '$count',
          style: const TextStyle(color: Colors.black45),
        ),
      ],
    );
  }
}
