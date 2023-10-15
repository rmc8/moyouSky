import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String userId;
  final int followers;
  final int following;

  const ProfileSection({
    required this.imageUrl,
    required this.name,
    required this.userId,
    required this.followers,
    required this.following,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 28, bottom: 28, right: 16, left: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom: BorderSide(
                color: Color.fromARGB(255, 212, 216, 216), width: 0.5)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 48.0,
          ),
          const SizedBox(height: 8.0),
          Text(name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
          const SizedBox(height: 4.0),
          Text(userId,
              style: const TextStyle(color: Colors.grey, fontSize: 16.0)),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text('フォロワー', style: TextStyle(color: Colors.grey)),
                  Text(followers.toString()),
                ],
              ),
              const SizedBox(width: 16.0),
              Column(
                children: [
                  const Text('フォロー', style: TextStyle(color: Colors.grey)),
                  Text(following.toString()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
