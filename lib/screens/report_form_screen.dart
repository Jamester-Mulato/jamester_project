import 'package:flutter/material.dart';

import '../models/report.dart';
import '../routes/app_routes.dart';
import '../services/report_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/status_panel.dart';

/// The four asynchronous responses required by Activity 9.
enum ReportUiState { idle, loading, success, empty, error }

/// Two views live inside this one screen: the form and the saved-report list.
enum ReportView { create, saved }

/// Activity 9 report form.
///
/// Responsibilities:
/// * validate the report fields,
/// * prevent duplicate submissions while a request is pending,
/// * reuse AppTextField and AppButton,
/// * show Loading, Success, Empty, and Error responses with recovery actions.
class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key, this.initialView = ReportView.create});

  final ReportView initialView;

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final ReportService _service = ReportService.instance;

  ReportUiState _uiState = ReportUiState.idle;
  ReportView _view = ReportView.create;
  ReportCategory _category = ReportCategory.facility;
  bool _simulateFailure = false;
  Report? _lastSubmitted;

  @override
  void initState() {
    super.initState();
    _view = widget.initialView;
    if (_view == ReportView.saved) {
      _syncSavedReportsState();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Keeps the response visible after a state change. The form is taller than
  /// a laptop viewport, so the user should not have to scroll back up to see
  /// Loading, Success, Empty, or Error feedback.
  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  void _syncSavedReportsState() {
    _uiState = _service.isEmpty ? ReportUiState.empty : ReportUiState.idle;
  }

  void _selectView(ReportView view) {
    if (_uiState == ReportUiState.loading) return;

    setState(() {
      _view = view;
      if (view == ReportView.saved) {
        _syncSavedReportsState();
      } else {
        _uiState = ReportUiState.idle;
      }
    });
    _scrollToTop();
  }

  /// Validates the form and starts the simulated request.
  Future<void> submitReport() async {
    if (_uiState == ReportUiState.loading) return;

    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    await _performSubmission(simulateFailure: _simulateFailure);
  }

  /// Shared submission path used by the form and by the Error-state Retry.
  Future<void> _performSubmission({required bool simulateFailure}) async {
    if (_uiState == ReportUiState.loading) return;

    FocusScope.of(context).unfocus();
    setState(() => _uiState = ReportUiState.loading);
    _scrollToTop();

    try {
      final Report report = await _service.submitReport(
        ReportDraft(
          title: _titleController.text.trim(),
          category: _category,
          location: _locationController.text.trim(),
          description: _descriptionController.text.trim(),
        ),
        simulateFailure: simulateFailure,
      );

      if (!mounted) return;
      setState(() {
        _lastSubmitted = report;
        _simulateFailure = simulateFailure;
        _uiState = ReportUiState.success;
      });
      _scrollToTop();
    } on ReportSubmissionException {
      if (!mounted) return;
      setState(() => _uiState = ReportUiState.error);
      _scrollToTop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _uiState = ReportUiState.error);
      _scrollToTop();
    }
  }

  /// Retry deliberately turns the failure simulation off so the demo recovers.
  void _retrySubmission() {
    setState(() => _simulateFailure = false);
    _performSubmission(simulateFailure: false);
  }

  void _startAnotherReport() {
    _titleController.clear();
    _locationController.clear();
    _descriptionController.clear();
    setState(() {
      _category = ReportCategory.facility;
      _simulateFailure = false;
      _lastSubmitted = null;
      _view = ReportView.create;
      _uiState = ReportUiState.idle;
    });
    _scrollToTop();
  }

  void _reviewForm() {
    setState(() => _uiState = ReportUiState.idle);
    _scrollToTop();
  }

  void _clearForm() {
    _titleController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _formKey.currentState?.reset();
    setState(() {
      _category = ReportCategory.facility;
      _simulateFailure = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report center'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _uiState == ReportUiState.loading
                  ? null
                  : () {
                      Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.home);
                    },
              icon: const Icon(Icons.home_outlined, size: 19),
              label: const Text('Home'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 44),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  _buildViewSelector(),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool showingForm = _view == ReportView.create;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'REPORT CENTER',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
            ),
            const _SimulationChip(),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          showingForm ? 'Report a campus concern' : 'Saved reports',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          showingForm
              ? 'Tell us what happened. Required fields are validated before '
                    'the simulated request starts.'
              : 'Reports submitted in this session appear here. This list is '
                    'empty until the first successful submission.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildViewSelector() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SegmentedButton<ReportView>(
        segments: <ButtonSegment<ReportView>>[
          const ButtonSegment<ReportView>(
            value: ReportView.create,
            icon: Icon(Icons.edit_note_outlined, size: 19),
            label: Text('New report'),
          ),
          ButtonSegment<ReportView>(
            value: ReportView.saved,
            icon: const Icon(Icons.list_alt_outlined, size: 19),
            label: Text('Saved reports (${_service.reports.length})'),
          ),
        ],
        selected: <ReportView>{_view},
        showSelectedIcon: false,
        onSelectionChanged: _uiState == ReportUiState.loading
            ? null
            : (Set<ReportView> selection) => _selectView(selection.first),
      ),
    );
  }

  Widget _buildContent() {
    if (_view == ReportView.saved) {
      return switch (_uiState) {
        ReportUiState.empty => _buildEmptyPanel(),
        ReportUiState.loading => _buildSavedLoading(),
        _ => _buildSavedReports(),
      };
    }

    return switch (_uiState) {
      ReportUiState.success => _buildSuccessPanel(),
      ReportUiState.error => _buildErrorPanel(),
      ReportUiState.empty => _buildEmptyPanel(),
      ReportUiState.idle || ReportUiState.loading => _buildForm(),
    };
  }

  Widget _buildForm() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool isLoading = _uiState == ReportUiState.loading;

    return KeyedSubtree(
      key: const ValueKey<String>('report-form'),
      child: Column(
        children: <Widget>[
          if (isLoading) _buildLoadingBanner(context),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Report details',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _StatusPill(
                          label: isLoading ? 'Working' : 'Draft',
                          color: isLoading ? colors.primary : colors.outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Fields marked by validation must be completed before '
                      'submission.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 22),
                    AppTextField(
                      key: const Key('report-title'),
                      controller: _titleController,
                      label: 'Report title',
                      hintText: 'e.g., Broken streetlight near the library',
                      prefixIcon: Icons.title,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      validator: (String? value) {
                        final String title = value?.trim() ?? '';
                        if (title.isEmpty) {
                          return 'Enter a short report title.';
                        }
                        if (title.length < 5) {
                          return 'Use at least 5 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ReportCategory>(
                      initialValue: _category,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_outlined, size: 20),
                      ),
                      items: ReportCategory.values
                          .map(
                            (ReportCategory category) =>
                                DropdownMenuItem<ReportCategory>(
                                  value: category,
                                  child: Text(category.label),
                                ),
                          )
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (ReportCategory? value) {
                              if (value == null) return;
                              setState(() => _category = value);
                            },
                      validator: (ReportCategory? value) =>
                          value == null ? 'Choose a report category.' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      key: const Key('report-location'),
                      controller: _locationController,
                      label: 'Location',
                      hintText: 'e.g., Engineering Building, 2nd floor',
                      prefixIcon: Icons.place_outlined,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      validator: (String? value) {
                        final String location = value?.trim() ?? '';
                        if (location.isEmpty) {
                          return 'Enter where the concern happened.';
                        }
                        if (location.length < 3) {
                          return 'Use at least 3 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      key: const Key('report-description'),
                      controller: _descriptionController,
                      label: 'Description',
                      hintText:
                          'Describe the concern, when it started, and any '
                          'details that would help the response team.',
                      helperText:
                          'At least 20 characters. Do not include '
                          'passwords or other sensitive information.',
                      prefixIcon: Icons.notes_outlined,
                      enabled: !isLoading,
                      maxLines: 5,
                      validator: (String? value) {
                        final String description = value?.trim() ?? '';
                        if (description.isEmpty) {
                          return 'Describe the concern.';
                        }
                        if (description.length < 20) {
                          return 'Use at least 20 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: SwitchListTile.adaptive(
                          key: const Key('simulate-failure'),
                          value: _simulateFailure,
                          onChanged: isLoading
                              ? null
                              : (bool value) {
                                  setState(() => _simulateFailure = value);
                                },
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Simulate a failed submission',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            'Turn this on to demonstrate the Error state. No real '
                            'request is sent either way.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                          secondary: Icon(
                            Icons.science_outlined,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            final bool stacked = constraints.maxWidth < 560;
                            final Widget submit = AppButton(
                              key: const Key('submit-report'),
                              label: 'Submit report',
                              loadingLabel: 'Submitting report...',
                              icon: Icons.send_outlined,
                              isLoading: isLoading,
                              onPressed: isLoading ? null : submitReport,
                              expand: !stacked,
                            );
                            final Widget clear = AppButton(
                              label: 'Clear form',
                              variant: AppButtonVariant.secondary,
                              icon: Icons.refresh,
                              onPressed: isLoading ? null : _clearForm,
                              expand: stacked,
                            );

                            if (stacked) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  submit,
                                  const SizedBox(height: 10),
                                  clear,
                                ],
                              );
                            }

                            return Row(
                              children: <Widget>[
                                Expanded(child: submit),
                                const SizedBox(width: 12),
                                clear,
                              ],
                            );
                          },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBanner(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      key: const Key('loading-banner'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Submitting your report...',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The simulated request is pending. The submit button is '
                  'disabled to prevent a duplicate submission.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessPanel() {
    final Report? report = _lastSubmitted;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return StatusPanel(
      key: const Key('success-panel'),
      tone: StatusPanelTone.success,
      icon: Icons.check_circle_outline,
      eyebrow: 'Success',
      title: 'Report submitted successfully',
      message:
          'The simulated request completed and the report was added to this '
          'session. No database record was saved.',
      primaryAction: AppButton(
        label: 'Submit another report',
        icon: Icons.add,
        expand: false,
        onPressed: _startAnotherReport,
      ),
      secondaryAction: AppButton(
        label: 'View saved reports',
        icon: Icons.list_alt_outlined,
        variant: AppButtonVariant.secondary,
        expand: false,
        onPressed: () => _selectView(ReportView.saved),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          children: <Widget>[
            _DetailRow(
              label: 'Reference',
              value: report?.reference ?? 'Unavailable',
              emphasize: true,
            ),
            const Divider(height: 22),
            _DetailRow(label: 'Title', value: report?.title ?? '—'),
            const SizedBox(height: 10),
            _DetailRow(label: 'Category', value: report?.category.label ?? '—'),
            const SizedBox(height: 10),
            _DetailRow(label: 'Location', value: report?.location ?? '—'),
            if (report != null) ...<Widget>[
              const SizedBox(height: 10),
              _DetailRow(
                label: 'Submitted',
                value: _formatDate(report.submittedAt),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPanel() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return StatusPanel(
      key: const Key('error-panel'),
      tone: StatusPanelTone.error,
      icon: Icons.error_outline,
      eyebrow: 'Error',
      title: 'We could not submit your report',
      message:
          'The simulated request failed. Your answers were kept, so you can '
          'retry the submission or review the form before trying again.',
      primaryAction: AppButton(
        key: const Key('retry-submission'),
        label: 'Retry submission',
        icon: Icons.refresh,
        expand: false,
        onPressed: _retrySubmission,
      ),
      secondaryAction: AppButton(
        label: 'Review the form',
        icon: Icons.edit_outlined,
        variant: AppButtonVariant.secondary,
        expand: false,
        onPressed: _reviewForm,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.errorContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.error.withValues(alpha: 0.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.science_outlined, color: colors.error, size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Simulated failure: no REST API request was made and no record '
                'was saved. Retry turns the simulation off and sends the same '
                'details again.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPanel() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return StatusPanel(
      key: const Key('empty-panel'),
      tone: StatusPanelTone.empty,
      icon: Icons.inbox_outlined,
      eyebrow: 'Empty',
      title: 'No reports yet',
      message:
          'The saved-reports list has zero records. Create your first report '
          'and it will appear here after a successful submission.',
      primaryAction: AppButton(
        key: const Key('empty-create-report'),
        label: 'Create a report',
        icon: Icons.add,
        expand: false,
        onPressed: () => _selectView(ReportView.create),
      ),
      secondaryAction: AppButton(
        label: 'Back to Home',
        icon: Icons.home_outlined,
        variant: AppButtonVariant.secondary,
        expand: false,
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        },
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.lightbulb_outline, color: colors.tertiary, size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'This is the Empty state, not a validation error. No reports '
                'exist in this session yet, so there is no data to display.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedReports() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final List<Report> reports = _service.reports;

    if (reports.isEmpty) return _buildEmptyPanel();

    return KeyedSubtree(
      key: const ValueKey<String>('saved-reports'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Report history',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reports.length} report${reports.length == 1 ? '' : 's'} '
                      'saved in memory for this session.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AppButton(
                label: 'New report',
                icon: Icons.add,
                expand: false,
                onPressed: () => _selectView(ReportView.create),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...reports.map(
            (Report report) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReportCard(report: report),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Simulated result: these cards are rendered from the in-memory '
            'service, not from PostgreSQL.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedLoading() {
    return const Card(
      key: Key('saved-loading'),
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            SizedBox(width: 14),
            Expanded(child: Text('Loading saved reports...')),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final String minute = date.minute.toString().padLeft(2, '0');
    final String period = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} · '
        '$hour:$minute $period';
  }
}

class _SimulationChip extends StatelessWidget {
  const _SimulationChip();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.science_outlined, size: 15, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            'Simulated backend',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: emphasize
                ? theme.textTheme.titleSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  )
                : theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final Report report;

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
                _StatusPill(
                  label: report.category.label,
                  color: colors.primary,
                ),
                const Spacer(),
                Text(
                  report.reference,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              report.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Icon(
                  Icons.place_outlined,
                  size: 17,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    report.location,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              report.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Icon(
                  Icons.schedule_outlined,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _formatDate(report.submittedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                _StatusPill(label: 'Pending review', color: colors.tertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final String minute = date.minute.toString().padLeft(2, '0');
    final String period = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} · '
        '$hour:$minute $period';
  }
}
