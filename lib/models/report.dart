/// Categories that a student can choose when filing a campus concern.
enum ReportCategory {
  facility(
    'Facility issue',
    'Broken fixtures, electrical, or building concerns',
  ),
  safety('Safety hazard', 'Unsafe areas, lighting, or security concerns'),
  cleanliness('Cleanliness', 'Waste, sanitation, or housekeeping concerns'),
  itSupport('IT support', 'Network, device, or laboratory equipment concerns'),
  other('Other', 'A concern that does not fit the categories above');

  const ReportCategory(this.label, this.description);

  final String label;
  final String description;
}

/// The values collected by the report form before submission.
class ReportDraft {
  const ReportDraft({
    required this.title,
    required this.category,
    required this.location,
    required this.description,
  });

  final String title;
  final ReportCategory category;
  final String location;
  final String description;
}

/// A submitted report returned by the (currently simulated) report service.
class Report {
  const Report({
    required this.reference,
    required this.title,
    required this.category,
    required this.location,
    required this.description,
    required this.submittedAt,
  });

  final String reference;
  final String title;
  final ReportCategory category;
  final String location;
  final String description;
  final DateTime submittedAt;
}
