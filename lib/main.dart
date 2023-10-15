import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:moyousky/themes/app_text_theme.dart';
import 'package:moyousky/views/login.dart';
import 'package:moyousky/views/timeline.dart';
import 'package:moyousky/themes/statusBar.dart';
import 'package:moyousky/repository/shared_preferences_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages("ja", timeago.JaMessages());
  final isLoggedIn = await SharedPreferencesRepository().isLoggedIn();
  ThemeMode mode = ThemeMode.system;

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'moyouSky',
        theme: ThemeData(
            textTheme: appTextTheme),
        darkTheme: ThemeData.dark(),
        themeMode: mode,
        home: isLoggedIn ? const Timeline() : LoginScreen(),
        locale: WidgetsBinding.instance.platformDispatcher.locales.first,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ja'),
        ],
        builder: (BuildContext context, Widget? child) {
          setSystemUIOverlayStyle(context);
          return child!;
        },
      ),
    ),
  );
}

final isLoggedInProvider =
    StateNotifierProvider<IsLoggedInNotifier, bool>((ref) {
  return IsLoggedInNotifier();
});

final currentIndexProvider =
    StateNotifierProvider<CurrentIndexNotifier, int>((ref) {
  return CurrentIndexNotifier();
});

class IsLoggedInNotifier extends StateNotifier<bool> {
  IsLoggedInNotifier() : super(false);

  void setLoggedIn(bool value) {
    state = value;
  }
}

class CurrentIndexNotifier extends StateNotifier<int> {
  CurrentIndexNotifier() : super(0);

  void updateIndex(int newIndex) {
    state = newIndex;
  }
}
