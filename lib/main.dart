// ignore_for_file: unnecessary_import, prefer_const_constructors

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tabamewin32/tabamewin32.dart';
import 'models/registration.dart';
import 'pages/quickmenu.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await registerAll();

  /// ? Window
  WindowOptions windowOptions = const WindowOptions(
    size: Size(300, 150),
    center: false,
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    alwaysOnTop: true,
    minimumSize: Size(300, 150),
    title: "Tabame",
  );
  windowManager.setMinimizable(false);
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAsFrameless();
    await windowManager.setHasShadow(false);
  });

  await setWindowAsTransparent();
  runApp(const Tabame());
}

final kInitialColor = Color(0xff3B414D);
final kTintColor = Color(0xFF373C47);

final kLightBackground = Color(0xffFFFFFF);
final kLightTint = Color(0xff4DCF72);
final kLightText = Color.fromRGBO(169, 69, 138, 1);

final kDarkBackground = Color.fromRGBO(55, 47, 98, 1);
final kDarkTint = Color.fromRGBO(250, 249, 248, 1);
final kDarkText = Color.fromRGBO(250, 249, 248, 1);

num darkerColor(int color, {int darkenBy = 0x10, int floor = 0x0}) {
  final darkerHex = (max((color >> 16) - darkenBy, floor) << 16) + (max(((color & 0xff00) >> 8) - darkenBy, floor) << 8) + max(((color & 0xff) - darkenBy), floor);
  return darkerHex;
}

final ValueNotifier<bool> darkThemeNotifier = ValueNotifier(true);

class Tabame extends StatelessWidget {
  const Tabame({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkThemeNotifier,
      builder: (_, mode, __) => MaterialApp(
        scrollBehavior: MyCustomScrollBehavior(),
        debugShowCheckedModeBanner: false,
        title: 'Tabame - Taskbar Menu',
        theme: ThemeData(
          splashColor: Color.fromARGB(40, 0, 0, 0),
          backgroundColor: kLightBackground,
          dividerColor: Color.alphaBlend(Colors.black.withOpacity(0.2), kLightBackground), // Color(darkerColor(kBackground.value, darkenBy: 0x44) as int),
          cardColor: kLightBackground,
          errorColor: kLightTint,
          iconTheme: Theme.of(context).iconTheme.copyWith(color: kLightText),
          textTheme: Theme.of(context).textTheme.apply(bodyColor: kLightText, displayColor: kLightText, decorationColor: kLightText),
          tooltipTheme: Theme.of(context).tooltipTheme.copyWith(
                verticalOffset: 10,
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                height: 0,
                margin: EdgeInsets.all(0),
                textStyle: TextStyle(color: kLightText, fontSize: 12, height: 0),
                decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
              ),
        ),
        darkTheme: ThemeData(
          splashColor: Color.fromARGB(40, 0, 0, 0),
          backgroundColor: kDarkBackground,
          dividerColor: Color.alphaBlend(Colors.black.withOpacity(0.2), kDarkBackground), // Color(darkerColor(kBackground.value, darkenBy: 0x44) as int),
          cardColor: kDarkBackground,
          errorColor: kDarkTint,
          iconTheme: Theme.of(context).iconTheme.copyWith(color: kDarkText),
          textTheme: Theme.of(context).textTheme.apply(bodyColor: kDarkText, displayColor: kDarkText, decorationColor: kDarkText),
          tooltipTheme: Theme.of(context).tooltipTheme.copyWith(
                verticalOffset: 10,
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                height: 0,
                margin: EdgeInsets.all(0),
                textStyle: TextStyle(color: kDarkText, fontSize: 12, height: 0),
                decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
              ),
        ),
        themeMode: mode ? ThemeMode.dark : ThemeMode.light,
        home: const QuickMenu(),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse};
}
