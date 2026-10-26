import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:semester_project/app.dart';
import 'package:semester_project/screens/report_form_screen.dart';
import 'package:semester_project/services/report_service.dart';

void main() {
  setUp(() {
    ReportService.instance.reset();
    ReportService.instance.submissionDelay = const Duration(milliseconds: 100);
    ReportService.instance.fetchDelay = const Duration(milliseconds: 10);
  });

  Widget reportApp({ReportView initialView = ReportView.create}) {
    return MaterialApp(home: ReportFormScreen(initialView: initialView));
  }

  void useLargeSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
  }

  Future<void> fillValidReport(WidgetTester tester) async {
    final Finder title = find.byKey(const Key('report-title'));
    final Finder location = find.byKey(const Key('report-location'));
    final Finder description = find.byKey(const Key('report-description'));

    await tester.ensureVisible(title);
    await tester.enterText(title, 'Broken streetlight near the library');
    await tester.ensureVisible(location);
    await tester.enterText(location, 'Library main entrance');
    await tester.ensureVisible(description);
    await tester.enterText(
      description,
      'The streetlight beside the library entrance has been flickering for '
      'three nights, making the walkway difficult to see.',
    );
    await tester.pump();
  }

  testWidgets('invalid form shows field-level validation', (
    WidgetTester tester,
  ) async {
    useLargeSurface(tester);
    await tester.pumpWidget(reportApp());
    await tester.pumpAndSettle();

    await tapVisible(tester, find.byKey(const Key('submit-report')));
    await tester.pump();

    expect(find.text('Enter a short report title.'), findsOneWidget);
    expect(find.text('Enter where the concern happened.'), findsOneWidget);
    expect(find.text('Describe the concern.'), findsOneWidget);
    expect(ReportService.instance.reports, isEmpty);
  });

  testWidgets('valid submit shows Loading then Success and disables submit', (
    WidgetTester tester,
  ) async {
    useLargeSurface(tester);
    await tester.pumpWidget(reportApp());
    await tester.pumpAndSettle();
    await fillValidReport(tester);

    await tapVisible(tester, find.byKey(const Key('submit-report')));
    await tester.pump();

    expect(find.byKey(const Key('loading-banner')), findsOneWidget);
    expect(find.text('Submitting your report...'), findsOneWidget);

    final FilledButton submit = tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const Key('submit-report')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(submit.onPressed, isNull);

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('success-panel')), findsOneWidget);
    expect(find.text('Report submitted successfully'), findsOneWidget);
    expect(find.textContaining('CC-'), findsOneWidget);
    expect(ReportService.instance.reports, hasLength(1));
  });

  testWidgets('simulated failure shows Error and Retry succeeds', (
    WidgetTester tester,
  ) async {
    useLargeSurface(tester);
    await tester.pumpWidget(reportApp());
    await tester.pumpAndSettle();
    await fillValidReport(tester);

    await tapVisible(tester, find.byKey(const Key('simulate-failure')));
    await tester.pump();

    await tapVisible(tester, find.byKey(const Key('submit-report')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('error-panel')), findsOneWidget);
    expect(find.text('We could not submit your report'), findsOneWidget);
    expect(ReportService.instance.reports, isEmpty);

    await tapVisible(tester, find.byKey(const Key('retry-submission')));
    await tester.pump();
    expect(find.byKey(const Key('loading-banner')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('success-panel')), findsOneWidget);
    expect(ReportService.instance.reports, hasLength(1));
  });

  testWidgets('saved reports starts in the Empty state', (
    WidgetTester tester,
  ) async {
    useLargeSurface(tester);
    await tester.pumpWidget(reportApp(initialView: ReportView.saved));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('empty-panel')), findsOneWidget);
    expect(find.text('No reports yet'), findsOneWidget);
    expect(find.byKey(const Key('empty-create-report')), findsOneWidget);
  });

  testWidgets('app starts on Login and reaches Home', (
    WidgetTester tester,
  ) async {
    useLargeSurface(tester);
    await tester.pumpWidget(const CampusCareApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-submit')), findsOneWidget);
    expect(find.text('Demo credentials'), findsOneWidget);

    await tapVisible(tester, find.text('Skip to dashboard (demo)'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back, Maria'), findsOneWidget);
    expect(find.byKey(const Key('home-report-button')), findsOneWidget);
  });
}
