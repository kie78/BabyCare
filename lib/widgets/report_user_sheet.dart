import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/report_provider.dart';
import 'app_toast.dart';

const List<_ReportOption> _reportOptions = <_ReportOption>[
  _ReportOption(
    value: 'spam',
    label: 'Spam',
    description: 'Unsolicited or repeated irrelevant messages.',
  ),
  _ReportOption(
    value: 'harassment',
    label: 'Harassment',
    description: 'Threatening, abusive, or bullying behaviour.',
  ),
  _ReportOption(
    value: 'inappropriate',
    label: 'Inappropriate content',
    description: 'Offensive content, profile pictures, or language.',
  ),
  _ReportOption(
    value: 'other',
    label: 'Other',
    description: 'Anything else that should be reviewed by the team.',
  ),
];

Future<void> showReportUserSheet(
  BuildContext context, {
  required String reportedUserId,
  required String reportedUserName,
  required String reportedUserRole,
}) async {
  final normalizedUserId = reportedUserId.trim();
  if (normalizedUserId.isEmpty) {
    AppToast.showInfo(
      context,
      'We could not identify this $reportedUserRole yet. Please try again shortly.',
    );
    return;
  }

  final submitted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ReportUserSheet(
      reportedUserId: normalizedUserId,
      reportedUserName: reportedUserName,
      reportedUserRole: reportedUserRole,
    ),
  );

  if (!context.mounted || submitted != true) {
    return;
  }

  AppToast.showSuccess(
    context,
    'Report submitted. Our team will review it shortly.',
  );
}

class _ReportUserSheet extends StatefulWidget {
  const _ReportUserSheet({
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reportedUserRole,
  });

  final String reportedUserId;
  final String reportedUserName;
  final String reportedUserRole;

  @override
  State<_ReportUserSheet> createState() => _ReportUserSheetState();
}

class _ReportUserSheetState extends State<_ReportUserSheet> {
  late final TextEditingController _descriptionController;
  String _selectedType = _reportOptions.first.value;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onSubmitPressed() async {
    final reportProvider = context.read<ReportProvider>();
    final success = await reportProvider.submitReport(
      reportedUserId: widget.reportedUserId,
      reportType: _selectedType,
      description: _descriptionController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    AppToast.showError(
      context,
      reportProvider.errorMessage ?? 'Unable to submit your report right now.',
      statusCode: reportProvider.lastStatusCode,
      fallbackMessage: 'Unable to submit your report right now.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final maxSheetHeight = mediaQuery.size.height * 0.9;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(16, 24, 16, bottomInset + 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: Material(
            color: BabyCareTheme.universalWhite,
            borderRadius: BorderRadius.circular(28),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: BabyCareTheme.lightGrey,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Report ${widget.reportedUserName}',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: BabyCareTheme.primaryBerry,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Why are you reporting this ${widget.reportedUserRole}?',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: BabyCareTheme.darkGrey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._reportOptions.map(
                    (option) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildOptionTile(context, option),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add details (optional)',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.darkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Tell us what happened',
                      hintStyle: TextStyle(
                        color: BabyCareTheme.darkGrey.withValues(alpha: 0.45),
                      ),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: reportProvider.isSubmitting
                          ? null
                          : _onSubmitPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BabyCareTheme.primaryBerry,
                        foregroundColor: BabyCareTheme.universalWhite,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: reportProvider.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  BabyCareTheme.universalWhite,
                                ),
                              ),
                            )
                          : const Text('Submit Report'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: reportProvider.isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: BabyCareTheme.primaryBerry,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildOptionTile(BuildContext context, _ReportOption option) {
    final isSelected = _selectedType == option.value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = option.value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? BabyCareTheme.lightPink
              : BabyCareTheme.lightGrey.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? BabyCareTheme.primaryBerry
                : BabyCareTheme.lightGrey,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.flag_rounded : Icons.outlined_flag_rounded,
              color: BabyCareTheme.primaryBerry,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: BabyCareTheme.darkGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.darkGrey.withValues(alpha: 0.72),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportOption {
  const _ReportOption({
    required this.value,
    required this.label,
    required this.description,
  });

  final String value;
  final String label;
  final String description;
}
