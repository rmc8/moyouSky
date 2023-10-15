import 'package:moyousky/widgets/post/post.dart';
import 'package:timeago/timeago.dart' as timeago;

List<Post> getPostWidgets(List<Map<String, dynamic>> feedViews) {
  return feedViews.map((feedView) {
    final dateTime = DateTime.parse(feedView['post']['record']['createdAt']);
    final relativeTime = timeago.format(dateTime, locale: 'en_short');

    return Post(
      feedView: feedView,
      postTime: relativeTime,
    );
  }).toList();
}
