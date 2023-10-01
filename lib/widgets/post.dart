import 'package:flutter/material.dart';

class Post extends StatelessWidget {
  final String username;
  final String userId;
  final String postTime;
  final String content;
  final String iconUrl;
  final int replyCount;
  final int repostCount;
  final int favoriteCount;
  final List<String> images;

  const Post({
    Key? key,
    required this.username,
    required this.userId,
    required this.postTime,
    required this.content,
    required this.iconUrl,
    required this.replyCount,
    required this.repostCount,
    required this.favoriteCount,
    this.images = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                backgroundImage: NetworkImage(iconUrl),
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
                                text: '$username ',
                                style: const TextStyle(
                                  fontSize: 18.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '@$userId',
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
                  Text(content, style: const TextStyle(fontSize: 17.0)),
                  if (images.isNotEmpty) const SizedBox(height: 8.0),
                  if (images.isNotEmpty)
                    GridView.builder(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) =>
                          Image.network(images[index]),
                      itemCount: images.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _iconTextWidget(Icons.comment_rounded, replyCount),
                      _iconTextWidget(Icons.repeat, repostCount),
                      _iconTextWidget(Icons.favorite, favoriteCount),
                      const Icon(
                        Icons.more_horiz,
                        color: Colors.black45,
                      ),
                    ],
                  )
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
