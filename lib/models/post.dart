import 'package:moyousky/widgets/post/post.dart';
import 'package:timeago/timeago.dart' as timeago;

List<Post> getPostWidgets(List<Map<String, dynamic>> feedViews) {
  return feedViews.map((feedView) {
    final dateTime = DateTime.parse(feedView['post']['record']['createdAt']);
    final relativeTime = timeago.format(dateTime, locale: 'en_short');

    return Post(
      username: feedView['post']['author']['displayName'],
      userId: feedView['post']['author']['handle'],
      postTime: relativeTime,
      content: feedView['post']['record']['text'],
      iconUrl: feedView['post']['author']['avatar'],
      replyCount: feedView['post']['replyCount'],
      repostCount: feedView['post']['repostCount'],
      favoriteCount: feedView['post']['likeCount'],
    );
  }).toList();
}
