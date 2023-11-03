import 'package:moyousky/utils/database_helper.dart';
import 'package:moyousky/services/actor_service.dart' as skys;
import 'package:moyousky/repository/shared_preferences_repository.dart';

void updateOwnAccountInfo() async {
  final spr = SharedPreferencesRepository();
  final currentUserId = await spr.getId();
  if (currentUserId.isEmpty) {
    return;
  }
  final currentService = await spr.getService();
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  final loginInfo = await databaseHelper.getLoginInfoByServiceAndId(
      currentService, currentUserId);
  if (loginInfo.isEmpty) {
    return;
  }
  final handle = loginInfo['handle'];
  final prf = skys.ActorService();
  final profileData = await prf.fetchProfileDataObj(handle);
  final avatar = profileData.avatar ?? '';
  final Map<String, dynamic> userDataToUpdate = {
    'handle': handle,
    'display_name': profileData.displayName,
    'avatar_url': avatar,
    'followers_count': profileData.followersCount,
    'follows_count': profileData.followsCount,
    'description': profileData.description,
  };
  await databaseHelper.updateLoginInfoByHandleAndService(handle, currentService, userDataToUpdate);
  spr.setAvatar(avatar);
}



