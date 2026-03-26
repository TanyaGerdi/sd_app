import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // 0 = system, 1 = light, 2 = dark
  int get selectedIndex {
    switch (_themeMode) {
      case ThemeMode.system:
        return 0;
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
    }
  }

  void setFromIndex(int index) {
    switch (index) {
      case 0:
        setThemeMode(ThemeMode.system);
      case 1:
        setThemeMode(ThemeMode.light);
      case 2:
        setThemeMode(ThemeMode.dark);
    }
  }

  static ThemeProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeProviderInherited>()!
        .provider;
  }

  static ThemeProvider? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeProviderInherited>()
        ?.provider;
  }
}

class ThemeProviderInherited extends InheritedNotifier<ThemeProvider> {
  final ThemeProvider provider;
  const ThemeProviderInherited({
    super.key,
    required this.provider,
    required super.child,
  }) : super(notifier: provider);
}
