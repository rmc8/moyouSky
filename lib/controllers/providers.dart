import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/repository/shared_preferences_repository.dart';
import 'package:moyousky/utils/database_helper.dart';

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
    try {
      await bsky.createSession(
        service: service,
        identifier: id,
        password: password,
      );
      await DatabaseHelper.instance.insertLoginInfo({
        'service': service,
        'id': id,
        'password': password,
      });

      final sharedPreferencesRepository =
          ref.read(sharedPreferencesRepositoryProvider);
      await sharedPreferencesRepository.setService(service);
      await sharedPreferencesRepository.setId(id);

      state = true;
    } catch (e) {
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
