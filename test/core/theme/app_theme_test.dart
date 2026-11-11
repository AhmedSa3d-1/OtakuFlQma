import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animewitcher/core/theme/app_theme.dart';

void main() {
  test('dark SnackBars use the application surface colors', () {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppTheme.primary,
      brightness: Brightness.dark,
    );
    final theme = AppTheme.snackBarThemeFor(colorScheme);

    expect(theme.backgroundColor, AppTheme.surface);
    expect(theme.contentTextStyle?.color, AppTheme.onSurface);
  });

  test(
    'light SnackBars use nearby surface colors instead of inverse colors',
    () {
      final colorScheme = ColorScheme.fromSeed(seedColor: AppTheme.lightCoral);
      final theme = AppTheme.snackBarThemeFor(colorScheme);

      expect(theme.backgroundColor, colorScheme.surfaceContainerHigh);
      expect(theme.contentTextStyle?.color, colorScheme.onSurface);
    },
  );
  test('OtakuFlQma primary is the fixed app accent in dark and light themes', () {
    const dynamicBlue = ColorScheme.dark(primary: Color(0xFF448AFF));
    final darkTheme = AppTheme.createDarkTheme(dynamicBlue);
    final lightTheme = AppTheme.createLightTheme(null);

    expect(AppTheme.otakuFlQmaPrimary, const Color(0xFFE60066));
    expect(darkTheme.colorScheme.primary, AppTheme.otakuFlQmaPrimary);
    expect(darkTheme.colorScheme.secondary, AppTheme.otakuFlQmaSecondary);
    expect(lightTheme.colorScheme.primary, AppTheme.otakuFlQmaPrimary);
    expect(lightTheme.colorScheme.secondary, AppTheme.otakuFlQmaSecondary);
  });

}
