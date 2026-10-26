import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../models/report.dart';

/// Raised when the simulated submission is configured to fail.
class ReportSubmissionException implements Exception {
  const ReportSubmissionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// In-memory stand-in for the planned REST API.
///
/// No network request or database write happens here. The delays and the
/// optional failure let the UI demonstrate Loading, Success, Empty, and Error
/// states honestly while the backend is still planned.
class ReportService extends ChangeNotifier {
  ReportService._();

  static final ReportService instance = ReportService._();

  final List<Report> _reports = <Report>[];
  int _sequence = 0;

  /// Overridable so widget tests do not have to wait ten real seconds.
  Duration submissionDelay = AppConstants.simulatedRequestDelay;
  Duration fetchDelay = AppConstants.simulatedFetchDelay;

  List<Report> get reports => List<Report>.unmodifiable(_reports);

  bool get hasReports => _reports.isNotEmpty;

  bool get isEmpty => _reports.isEmpty;

  Future<List<Report>> fetchReports() async {
    await Future<void>.delayed(fetchDelay);
    return reports;
  }

  Future<Report> submitReport(
    ReportDraft draft, {
    bool simulateFailure = false,
  }) async {
    await Future<void>.delayed(submissionDelay);

    if (simulateFailure) {
      throw const ReportSubmissionException(
        'The simulated request failed before the report could be saved.',
      );
    }

    _sequence += 1;
    final Report report = Report(
      reference:
          'CC-${DateTime.now().year}-${_sequence.toString().padLeft(4, '0')}',
      title: draft.title,
      category: draft.category,
      location: draft.location,
      description: draft.description,
      submittedAt: DateTime.now(),
    );

    _reports.insert(0, report);
    notifyListeners();
    return report;
  }

  /// Clears the in-memory list. Used by tests and by the demo reset action.
  void reset() {
    _reports.clear();
    _sequence = 0;
    submissionDelay = AppConstants.simulatedRequestDelay;
    fetchDelay = AppConstants.simulatedFetchDelay;
    notifyListeners();
  }
}
