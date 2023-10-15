import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesRepository {
  SharedPreferences? _sharedPreferences;

  Future<bool> isLoggedIn() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('service') != null;
  }

  Future<SharedPreferences> get sharedPreferences async {
    if (_sharedPreferences != null) return _sharedPreferences!;
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences!;
  }

  Future<String> getService() async {
    return (await sharedPreferences).getString('service') ?? '';
  }

  Future<void> setService(String service) async {
    (await sharedPreferences).setString('service', service);
  }

  Future<String> getId() async {
    return (await sharedPreferences).getString('id') ?? '';
  }

  Future<void> setId(String id) async {
    (await sharedPreferences).setString('id', id);
  }

  Future<String> getDiD() async {
    return (await sharedPreferences).getString('did') ?? '';
  }

  Future<void> setDid(String did) async {
    (await sharedPreferences).setString('did', did);
  }
}
