import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bilingual/models/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
        light: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
        ),
        dark: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange,
        ),
        initial: AdaptiveThemeMode.system,
        builder: (ThemeData theme, ThemeData darkTheme) => MaterialApp(
              home: const HomePage(),
              theme: theme,
              darkTheme: darkTheme,
            ));
  }
}
