import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/utils/constants.dart' as cons;
import 'package:moyousky/widgets/label/actor_state.dart';
import 'package:moyousky/views/user_profile.dart';
import 'package:moyousky/animation/fade_route.dart';

class ActorCard extends StatelessWidget {
  final bsky.Actor actor;

  const ActorCard({Key? key, required this.actor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labels = [
      if (actor.isFollowing && actor.isNotFollowedBy)
        const LabelWidget(labelType: LabelType.following),
      if (actor.isNotFollowing && actor.isFollowedBy)
        const LabelWidget(labelType: LabelType.follower),
      if (actor.isFollowing && actor.isFollowedBy)
        const LabelWidget(labelType: LabelType.mutualFollow),
      if (actor.isMuted) const LabelWidget(labelType: LabelType.muted),
      if (actor.isBlocking) const LabelWidget(labelType: LabelType.blocked),
      if (!actor.toJson()['labels'].isEmpty &&
          actor.toJson()['labels'][0]['val'] == 'spam')
        const LabelWidget(labelType: LabelType.spam)
    ];
    return InkWell(
        onTap: () {
          Navigator.of(context).push(FadeRoute(page: UserProfile(did: actor.did)));
        },
        child: Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with padding
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
                  child: CircleAvatar(
                    backgroundImage: actor.avatar != null
                        ? NetworkImage(actor.avatar!)
                        : null,
                    child: actor.avatar == null ? const Icon(Icons.person) : null,
                  ),
                ),
                // Nested Column Structure
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name, ID, and Labels
                        Row(
                          children: [
                            // Name and ID
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(actor.displayName ?? actor.handle,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: cons.DEFAULT_FONT,
                                      )),
                                  Text('@${actor.handle}',
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black54,
                                      )),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: labels,
                                  )
                                ],
                              ),
                            ),
                            // Action Button
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement action button logic
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF222222),
                                ),
                                child: const Text(
                                  'アクション',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5),
                                ),
                              ),
                            )
                          ],
                        ),
                        // Description
                        if (labels.isNotEmpty && actor.description != null)
                          const SizedBox(height: 8.0),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 68.0),
                          child: Text(actor.description ?? ''),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }
}
