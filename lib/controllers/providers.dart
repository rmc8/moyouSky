import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/repository/shared_preferences_repository.dart';
import 'package:moyousky/utils/database_helper.dart';
import 'package:moyousky/utils/database_helper.dart' as dh;
import 'package:moyousky/services/bluesky_api_service.dart' as skys;

final blueskySessionProvider = StreamProvider<bsky.Bluesky>((ref) async* {
  final sharedPreferencesRepository =
      ref.read(sharedPreferencesRepositoryProvider);
  final service = await sharedPreferencesRepository.getService();
  final id = await sharedPreferencesRepository.getId();

  final loginInfo =
      await DatabaseHelper.instance.getLoginInfoByServiceAndId(service, id);
  final password = loginInfo['password'];

  while (true) {
    final session = await bsky.createSession(
      service: service,
      identifier: id,
      password: password,
    );

    final bluesky = bsky.Bluesky.fromSession(
      session.data,
      service: service,
    );

    yield bluesky;

    await Future.delayed(const Duration(minutes: 10));
  }
});

class LoginStateNotifier extends StateNotifier<bool> {
  LoginStateNotifier(this.ref) : super(false) {
    checkLoginStatus();
  }

  final StateNotifierProviderRef<LoginStateNotifier, bool> ref;

  Future<void> checkLoginStatus() async {
    final loginInfo = await DatabaseHelper.instance.getLoginInfo();
    state = loginInfo.isNotEmpty;
  }

  Future<void> login(String service, String id, String password) async {
    final sharedPreferencesRepository =
    ref.read(sharedPreferencesRepositoryProvider);
    try {
      final res = await bsky.createSession(
        service: service,
        identifier: id,
        password: password,
      );
      final Map<String, dynamic> loginDataToInsert = {
        'service': service,
        'id': id,
        'password': password,
        'email': res.data.email,
        'handle': res.data.handle,
        'did': res.data.did,
        'display_name': '',
        'avatar_url': '',
        'followers_count': 0,
        'follows_count': 0,
        'description': '',
      };
      print(res.data);
      await DatabaseHelper.instance.insertLoginInfo(loginDataToInsert);
      final prf = skys.BlueskyApiService();
      await sharedPreferencesRepository.setService(service);
      await sharedPreferencesRepository.setId(res.data.handle.toString());
      await sharedPreferencesRepository.setDid(res.data.did.toString());
      final profileData = await prf.fetchProfileData(res.data.handle);
      final Map<String, dynamic> userDataToInsert = {
        'display_name': profileData['displayName'],
        'avatar_url': profileData['avatar'],
        'followers_count': profileData['followersCount'],
        'follows_count': profileData['followsCount'],
        'description': profileData['description'],
      };
      await DatabaseHelper.instance.updateLoginInfoByHandleAndService(res.data.handle, service, userDataToInsert);
      state = true;
    } catch (e) {
      await sharedPreferencesRepository.setService('');
      await sharedPreferencesRepository.setId('');
      throw Exception('Login failed: $e.toString()');
    }
  }
}

final loginStateProvider =
    StateNotifierProvider<LoginStateNotifier, bool>((ref) {
  return LoginStateNotifier(ref);
});

final sharedPreferencesRepositoryProvider =
    Provider<SharedPreferencesRepository>((ref) {
  return SharedPreferencesRepository();
});
