import 'package:flutter/material.dart';

/// The app's colours. Values are unchanged from the original screens; they
/// were only moved here so every screen shares one definition.
abstract final class AppColors {
  static const green = Color(0xFF00C58B);
  static const darkGreen = Color(0xFF064C3D);
  static const accent = Color(0xFF29A884);
  static const background = Color(0xFFF2FFFA);
  static const muted = Color(0xFF63796F);
  static const seed = Color(0xFF27665B);

  // Card surfaces.
  static const attendanceCard = Color(0xFFCFF2E7);
  static const scheduleCard = Color(0xFFE3F2F9);
  static const classChip = Color(0xFFC9E2E8);
  static const scheduleDivider = Color(0xFFCADDE4);
  static const mintTint = Color(0xFFD9F6EC);
  static const dateChip = Color(0xFFE2ECE8);
  static const dateChipIcon = Color(0xFF6A7973);
  static const dateChipText = Color(0xFF53625D);
  static const amber = Color(0xFFDCAB4D);
  static const lessonBlue = Color(0xFF4E9AAB);

  // Navigation.
  static const navSelected = Color(0xFF008D67);
  static const navUnselected = Color(0xFF9BA6B5);
  static const navLabel = Color(0xFF647082);

  // Forms and errors.
  static const fieldBorder = Color(0xFFD5EDE4);
  static const error = Color(0xFFB3261E);
  static const errorBackground = Color(0xFFFDECEA);
  static const errorText = Color(0xFF8C1D18);

  // Shadows.
  static const shadow = Color(0x300D483A);
  static const buttonShadow = Color(0x5500A67D);

  /// Light tint of [green] at the bottom of the login background.
  static final loginGreen = Color.lerp(Colors.white, green, 0.55)!;
}

abstract final class AppGradients {
  /// Login background: white at the top fading to [AppColors.loginGreen].
  static final login = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.white, AppColors.loginGreen],
  );
}

/// Fixed component sizes in logical pixels (dp).
abstract final class AppSizes {
  /// Height of text fields and the primary button, so they line up.
  static const controlHeight = 56.0;
}

/// Spacing in logical pixels (dp).
abstract final class AppSpacing {
  /// Left and right margin of every screen.
  static const screen = 20.0;

  /// Gap between cards and sections.
  static const section = 16.0;

  /// Inner padding of cards.
  static const card = 20.0;
}

abstract final class AppTheme {
  /// Text sizes in sp. Screens use these through [ThemeData.textTheme]
  /// instead of hard-coded font sizes.
  static const textTheme = TextTheme(
    // Login title, "STS KEHADIRAN".
    displaySmall: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.5,
      height: 1.2,
    ),
    // Greeting, e.g. "Hello, Mr. Dylan" and "Welcome back, Teacher!".
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
      height: 1.2,
    ),
    // App title.
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.4,
    ),
    // Section and card headings.
    titleMedium: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
    // Emphasised body text, e.g. a lesson subject.
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(fontSize: 16, height: 1.35),
    bodyMedium: TextStyle(fontSize: 16, height: 1.35),
    // Captions: never smaller than 13 sp.
    bodySmall: TextStyle(fontSize: 13, height: 1.3),
    // Buttons.
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    // Chips.
    labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    // Bottom navigation labels (Material's standard 12 sp).
    labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
  );

  /// The large primary action on a screen, e.g. "Sign In".
  static final primaryButton = FilledButton.styleFrom(
    backgroundColor: AppColors.green,
    foregroundColor: Colors.white,
    disabledBackgroundColor: const Color(0xFF7FDFC2),
    disabledForegroundColor: Colors.white,
    minimumSize: const Size.fromHeight(AppSizes.controlHeight),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    elevation: 1,
    shadowColor: AppColors.buttonShadow,
  );

  static OutlineInputBorder _border(
    Color color, {
    double width = 1,
    required double radius,
  }) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(radius),
    borderSide: BorderSide(color: color, width: width),
  );

  /// [theme] with the login screen's fields: white fill, dark border and
  /// at least [AppSizes.controlHeight] tall, so they line up with the
  /// primary button. Larger system text makes them taller.
  static ThemeData loginFields(ThemeData theme) {
    OutlineInputBorder border(Color color, [double width = 1.5]) =>
        _border(color, width: width, radius: 12);
    return theme.copyWith(
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        fillColor: Colors.white,
        constraints: const BoxConstraints(minHeight: AppSizes.controlHeight),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: border(AppColors.darkGreen),
        focusedBorder: border(AppColors.green, 2),
        errorBorder: border(AppColors.error),
        focusedErrorBorder: border(AppColors.error, 2),
        disabledBorder: border(AppColors.muted),
      ),
    );
  }

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.seed);
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    // Sizes from [textTheme] on top of the platform font (family, colour),
    // so every style below renders in the app's font.
    final text = base.textTheme.merge(textTheme);
    OutlineInputBorder border(Color color, [double width = 1]) =>
        _border(color, width: width, radius: 16);
    const minTap = Size(48, 48);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: text,
      iconTheme: const IconThemeData(size: 24),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: AppColors.shadow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: minTap,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: minTap,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: minTap,
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: minTap, iconSize: 24),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        labelStyle: text.bodyLarge,
        prefixIconColor: AppColors.accent,
        enabledBorder: border(AppColors.fieldBorder),
        focusedBorder: border(AppColors.green, 2),
        errorBorder: border(AppColors.error),
        focusedErrorBorder: border(AppColors.error, 2),
        disabledBorder: border(AppColors.dateChip),
        errorStyle: text.bodySmall?.copyWith(color: AppColors.error),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shadowColor: AppColors.shadow,
        height: 72,
        indicatorColor: AppColors.mintTint,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 26,
            color: states.contains(WidgetState.selected)
                ? AppColors.navSelected
                : AppColors.navUnselected,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? text.labelSmall!.copyWith(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w800,
                )
              : text.labelSmall!.copyWith(color: AppColors.navLabel),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        contentTextStyle: text.bodyLarge?.copyWith(color: Colors.white),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.scheduleDivider,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
