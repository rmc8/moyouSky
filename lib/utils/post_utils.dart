import 'package:moyousky/widgets/post/post.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:timeago/timeago.dart' as timeago;

List<Post> getPostWidgets(List<bsky.FeedView> feedViews) {
  return feedViews.map((feedView) {
    final dateTime = DateTime.parse(feedView.post.record.createdAt.toString());
    final relativeTime = timeago.format(dateTime, locale: "ja"); // en_short
    return Post(
      feedView: feedView,
      postTime: relativeTime,
    );
  }).toList();
}
