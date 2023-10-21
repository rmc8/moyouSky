import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  // debugPaintSizeEnabled = true;
  timeago.setLocaleMessages("ja", timeago.JaMessages());
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await SharedPreferencesRepository().isLoggedIn();
  ThemeMode mode = ThemeMode.system;
  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent,
  //   statusBarBrightness: Brightness.dark,
  //   statusBarIconBrightness: Brightness.dark,
  //   systemNavigationBarColor: Colors.transparent,
  //   systemNavigationBarIconBrightness: Brightness.dark,
  // ));
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'moyouSky',
        theme: ThemeData(textTheme: appTextTheme),
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
