import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sts_kehadiran/core/theme.dart';

void main() {
  final theme = AppTheme.light();
  final text = theme.textTheme;

  test('type scale matches the agreed sizes', () {
    expect(text.displaySmall?.fontSize, inInclusiveRange(28, 32));
    expect(text.displaySmall?.fontWeight, FontWeight.w800);
    expect(text.headlineSmall?.fontSize, 24);
    expect(text.titleLarge?.fontSize, 22);
    expect(text.titleMedium?.fontSize, inInclusiveRange(18, 20));
    expect(text.bodyLarge?.fontSize, 16);
    expect(text.bodyMedium?.fontSize, 16);
    expect(text.bodySmall?.fontSize, greaterThanOrEqualTo(13));
    expect(text.labelMedium?.fontSize, greaterThanOrEqualTo(13));
  });

  test('every themed text style keeps the app font', () {
    final styles = <String, TextStyle?>{
      'displaySmall': text.displaySmall,
      'headlineSmall': text.headlineSmall,
      'titleMedium': text.titleMedium,
      'bodyLarge': text.bodyLarge,
      'bodySmall': text.bodySmall,
      'labelLarge': text.labelLarge,
      'filled button': theme.filledButtonTheme.style?.textStyle?.resolve({}),
      'text button': theme.textButtonTheme.style?.textStyle?.resolve({}),
      'nav label': theme.navigationBarTheme.labelTextStyle?.resolve({}),
      'field label': theme.inputDecorationTheme.labelStyle,
    };
    for (final entry in styles.entries) {
      expect(entry.value?.fontFamily, isNotNull, reason: entry.key);
    }
    // The primary button inherits the themed label style instead of
    // replacing it with one that has no font.
    expect(AppTheme.primaryButton.textStyle?.resolve({}), isNull);
  });

  test('buttons meet the minimum tap target', () {
    final minimum = theme.filledButtonTheme.style?.minimumSize?.resolve({});
    expect(minimum?.height, greaterThanOrEqualTo(48));
    expect(
      AppTheme.primaryButton.minimumSize?.resolve({})?.height,
      greaterThanOrEqualTo(56),
    );
  });

  test('login gradient fades from white to a tint of the app green', () {
    expect(AppGradients.login.colors.first, Colors.white);
    expect(AppGradients.login.colors.last, AppColors.loginGreen);
    expect(
      AppColors.loginGreen,
      Color.lerp(Colors.white, AppColors.green, 0.55),
    );
  });

  test('login fields are white with a dark border', () {
    final login = AppTheme.loginForm(theme);
    final fields = login.inputDecorationTheme;
    expect(fields.fillColor, Colors.white);
    final border = fields.enabledBorder! as OutlineInputBorder;
    expect(border.borderSide.color, AppColors.darkGreen);
    // The button has the same corners as the fields.
    final buttonShape = login.filledButtonTheme.style?.shape?.resolve(
      {},
    ) as RoundedRectangleBorder?;
    expect(buttonShape?.borderRadius, border.borderRadius);
    expect(
      login.filledButtonTheme.style?.minimumSize?.resolve({})?.height,
      greaterThanOrEqualTo(48),
    );
    // The rest of the app keeps its own field style.
    expect(theme.inputDecorationTheme.fillColor, AppColors.background);
  });
}
