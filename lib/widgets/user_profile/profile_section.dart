import 'package:flutter/material.dart';
import 'package:moyousky/widgets/user_profile/component/avatar_builder.dart';
import 'package:moyousky/widgets/user_profile/component/count_label.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:bluesky/bluesky.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileHeader extends StatelessWidget {
  final ActorProfile? profileData;

  const UserProfileHeader({Key? key, required this.profileData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      background: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Background (Banner)
          Transform.translate(
            offset: const Offset(0, -144),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                image: profileData?.banner!= null
                    ? DecorationImage(
                        image: NetworkImage(profileData?.banner ?? ''),
                        fit: BoxFit.scaleDown,
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 114.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Avatar
                AvatarBuilder(avatarUrl: profileData?.avatar),
                Text(
                  profileData?.displayName ?? profileData?.handle ?? '',
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Text('@' + (profileData?.handle ?? ''),
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 14.0)),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CountLabel(
                          count: profileData?.followersCount?.toString(),
                          label: 'フォロワー',
                          onTap: () {
                            // TODO: フォロワーのリストを表示するロジックを追加
                          }),
                      CountLabel(
                          count: profileData?.followsCount?.toString(),
                          label: 'フォロー',
                          onTap: () {
                            // TODO: フォローのリストを表示するロジックを追加
                          }),
                      CountLabel(
                        count: profileData?.postsCount?.toString(),
                        label: 'ポスト数',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 24.0, right: 24.0, top: 8.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 108.0),
                    child: SingleChildScrollView(
                      child: Linkify(
                        onOpen: (link) async {
                          try {
                            await launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication);
                          } catch (e) {
                            print('Could not launch ${link.url}. Error: $e');
                          }
                        },
                        text: profileData?.description ?? '',
                        style: const TextStyle(color: Colors.black),
                        linkStyle: const TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
