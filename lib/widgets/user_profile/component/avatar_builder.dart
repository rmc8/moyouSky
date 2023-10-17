import 'package:flutter/material.dart';

class AvatarBuilder extends StatelessWidget {
  final String? avatarUrl;

  const AvatarBuilder({Key? key, required this.avatarUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Stack(
        alignment: Alignment.center,
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 40.0,
          ),
          CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl!),
            radius: 37.0,
          ),
        ],
      );
    } else {
      return const Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 40.0,
          ),
          CircleAvatar(
            radius: 37.5,
            child: Icon(Icons.person, size: 36.0, color: Colors.grey),
          ),
        ],
      );
    }
  }
}
