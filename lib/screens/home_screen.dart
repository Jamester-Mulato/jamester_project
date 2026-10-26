import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../routes/app_routes.dart';
import '../services/report_service.dart';
import '../widgets/app_button.dart';

/// Activity 8 Home screen, extended with Report Form navigation.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openReport(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.report);
  }

  void _openSavedReports(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.savedReports);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 24,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.verified_user_outlined,
                color: colors.onPrimary,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppConstants.appName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              tooltip: 'Sign out',
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              },
              icon: const Icon(Icons.logout_outlined),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Welcome back, Maria',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConstants.tagline,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _HeroCard(
                    onReport: () => _openReport(context),
                    onSavedReports: () => _openSavedReports(context),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final bool wide = constraints.maxWidth >= 760;
                      final double cardWidth = wide
                          ? (constraints.maxWidth - 32) / 3
                          : constraints.maxWidth;

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: <Widget>[
                          SizedBox(
                            width: cardWidth,
                            child: AnimatedBuilder(
                              animation: ReportService.instance,
                              builder: (BuildContext context, Widget? child) {
                                return _StatCard(
                                  icon: Icons.folder_copy_outlined,
                                  label: 'Saved reports',
                                  value:
                                      '${ReportService.instance.reports.length}',
                                  caption: ReportService.instance.isEmpty
                                      ? 'No reports in this session yet'
                                      : 'Stored in memory for this demo',
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: const _StatCard(
                              icon: Icons.science_outlined,
                              label: 'Response mode',
                              value: 'Simulated',
                              caption:
                                  'Future.delayed stands in for the REST API',
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: const _StatCard(
                              icon: Icons.cloud_off_outlined,
                              label: 'Backend',
                              value: 'Not connected',
                              caption:
                                  'PostgreSQL integration is still planned',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.info_outline,
                          color: colors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppConstants.simulationNotice,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onReport, required this.onSavedReports});

  final VoidCallback onReport;
  final VoidCallback onSavedReports;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colors.primary.withValues(alpha: 0.12),
            colors.primaryContainer.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool wide = constraints.maxWidth >= 700;
          final Widget copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'REPORT CENTER',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Something not right on campus?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'File a facility, safety, cleanliness, or IT concern. '
                'The form checks your details before anything is submitted.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  AppButton(
                    key: const Key('home-report-button'),
                    label: 'Report an incident',
                    icon: Icons.add_alert_outlined,
                    expand: false,
                    onPressed: onReport,
                  ),
                  AppButton(
                    label: 'View saved reports',
                    icon: Icons.list_alt_outlined,
                    variant: AppButtonVariant.secondary,
                    expand: false,
                    onPressed: onSavedReports,
                  ),
                ],
              ),
            ],
          );

          if (!wide) return copy;

          return Row(
            children: <Widget>[
              Expanded(child: copy),
              const SizedBox(width: 32),
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  Icons.campaign_outlined,
                  size: 62,
                  color: colors.primary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: 19, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
