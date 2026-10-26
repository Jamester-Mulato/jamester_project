/// Shared, app-wide values.
///
/// Activity 9 uses a simulated backend, so the delay and notice strings live
/// here and are reused by the report service and the report form screen.
class AppConstants {
  AppConstants._();

  static const String appName = 'CampusCare';
  static const String systemName =
      'CampusCare Campus Incident Reporting System';
  static const String tagline =
      'A clearer way to report and follow up on campus concerns.';

  static const String demoEmail = 'student@campuscare.edu';
  static const String demoPassword = 'campuscare123';

  static const Duration simulatedRequestDelay = Duration(seconds: 10);
  static const Duration simulatedFetchDelay = Duration(milliseconds: 700);

  static const String simulationNotice =
      'Demo mode: backend responses are simulated. Reports stay in memory only '
      'until the REST API and PostgreSQL database are connected.';
}
