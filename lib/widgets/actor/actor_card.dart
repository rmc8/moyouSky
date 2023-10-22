import 'package:flutter/material.dart';

import 'package:bluesky/bluesky.dart' as bsky;

import 'package:moyousky/views/user_profile.dart';
import 'package:moyousky/utils/fade_route.dart';
import 'package:moyousky/utils/constants.dart' as cons;
import 'package:moyousky/widgets/label/actor_state.dart';

class ActorCard extends StatelessWidget {
  final bsky.Actor actor;

  const ActorCard({Key? key, required this.actor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context)
          .push(FadeRoute(page: UserProfile(did: actor.did))),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(),
            const SizedBox(width: 8.0),
            Expanded(child: _buildDetails()),

          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
      child: CircleAvatar(
        backgroundImage:
            actor.avatar != null ? NetworkImage(actor.avatar!) : null,
        child: actor.avatar == null ? const Icon(Icons.person) : null,
      ),
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameAndIDWithAction(),
          if (actor.description != null) const SizedBox(height: 8.0),
          _buildDescription(),
        ],
      ),
    );
  }

  Widget _buildDisplayNameAndHandle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          actor.displayName ?? actor.handle,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            fontFamily: cons.DEFAULT_FONT,
          ),
        ),
        Text('@${actor.handle}',
            style: const TextStyle(fontSize: 14.0, color: Colors.black54)),
      ],
    );
  }

  Widget _buildNameAndIDWithAction() {
    final labels = _buildLabels();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildDisplayNameAndHandle()),
            const SizedBox(width: 8.0),
            _buildActionButton(),
          ],
        ),
        const SizedBox(height: 8.0),
        Row(
          children: labels,
        ),
      ],
    );
  }



  Widget _buildDescription() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 68.0),
      child: Text(actor.description ?? ''),
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement action button logic
        },
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF222222)),
        child: const Text('アクション',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13.5)),
      ),
    );
  }

  List<Widget> _buildLabels() {
    return [
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
  }
}
