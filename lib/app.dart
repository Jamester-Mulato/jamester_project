import 'package:flutter/material.dart';

import 'constants/app_constants.dart';
import 'routes/app_routes.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/report_form_screen.dart';

/// Root of the CampusCare Flutter Web app.
///
/// Activity 9 keeps the Activity 8 Login and Home screens and adds the
/// `/report` and `/reports` routes for the new report form.
class CampusCareApp extends StatelessWidget {
  const CampusCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F766E),
    );

    return MaterialApp(
      title: AppConstants.systemName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colors,
        scaffoldBackgroundColor: const Color(0xFFF6F8F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F8F8),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.85),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.primary, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.error, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.error, width: 1.8),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          labelStyle: TextStyle(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.w700,
          ),
          hintStyle: TextStyle(
            color: colors.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          helperStyle: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 12,
            height: 1.4,
          ),
          errorStyle: TextStyle(color: colors.error, fontSize: 12),
          prefixIconColor: colors.onSurfaceVariant,
        ),
        dividerTheme: DividerThemeData(
          color: colors.outlineVariant,
          space: 1,
          thickness: 1,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
        ),
      ),
      initialRoute: AppRoutes.login,
      routes: <String, WidgetBuilder>{
        AppRoutes.login: (BuildContext context) => const LoginScreen(),
        AppRoutes.home: (BuildContext context) => const HomeScreen(),
        AppRoutes.report: (BuildContext context) => const ReportFormScreen(),
        AppRoutes.savedReports: (BuildContext context) =>
            const ReportFormScreen(initialView: ReportView.saved),
      },
    );
  }
}
