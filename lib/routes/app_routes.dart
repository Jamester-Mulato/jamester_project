/// Named routes used by the app.
///
/// The `/report` route is the Activity 9 addition. `/reports` opens the same
/// screen on its saved-reports view so the Empty state can be demonstrated
/// directly from the Home screen.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String report = '/report';
  static const String savedReports = '/reports';
}
