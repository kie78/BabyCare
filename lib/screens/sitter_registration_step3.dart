import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/sitter_registration.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_toast.dart';
import 'sitter_login.dart';

class SitterRegistrationStep3Screen extends StatefulWidget {
  final SitterRegistrationData registrationData;

  const SitterRegistrationStep3Screen({
    super.key,
    required this.registrationData,
  });

  @override
  State<SitterRegistrationStep3Screen> createState() =>
      _SitterRegistrationStep3ScreenState();
}

class _SitterRegistrationStep3ScreenState
    extends State<SitterRegistrationStep3Screen> {
  late Map<String, bool> _uploadedDocuments;
  late Map<String, String?> _selectedFileNames;
  String? _pickingDocumentId;

  final List<_DocumentUpload> documents = [
    _DocumentUpload(
      id: 'profilePic',
      title: 'Profile Picture',
      icon: Icons.account_circle_outlined,
      description: 'Clear headshot for parents to see',
    ),
    _DocumentUpload(
      id: 'nationalId',
      title: 'National ID',
      icon: Icons.card_membership_outlined,
      description: 'Front and back of your ID',
    ),
    _DocumentUpload(
      id: 'lciLetter',
      title: 'LCI Letter',
      icon: Icons.description_outlined,
      description: 'Local Community Integration letter',
    ),
    _DocumentUpload(
      id: 'resumeCv',
      title: 'Resume/CV',
      icon: Icons.file_present_outlined,
      description: 'Your professional background',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _uploadedDocuments = {
      'profilePic': widget.registrationData.profilePicturePath != null,
      'nationalId': widget.registrationData.nationalIdPath != null,
      'lciLetter': widget.registrationData.lciLetterPath != null,
      'resumeCv': widget.registrationData.resumeCvPath != null,
    };
    _selectedFileNames = {
      'profilePic': _extractFileName(widget.registrationData.profilePicturePath),
      'nationalId': _extractFileName(widget.registrationData.nationalIdPath),
      'lciLetter': _extractFileName(widget.registrationData.lciLetterPath),
      'resumeCv': _extractFileName(widget.registrationData.resumeCvPath),
    };
  }

  String? _extractFileName(String? path) {
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final normalizedPath = path.replaceAll('\\', '/');
    final segments = normalizedPath.split('/');
    return segments.isEmpty ? path : segments.last;
  }

  void _setDocumentPath(String docId, String path) {
    switch (docId) {
      case 'profilePic':
        widget.registrationData.profilePicturePath = path;
        break;
      case 'nationalId':
        widget.registrationData.nationalIdPath = path;
        break;
      case 'lciLetter':
        widget.registrationData.lciLetterPath = path;
        break;
      case 'resumeCv':
        widget.registrationData.resumeCvPath = path;
        break;
    }
  }

  Future<void> _pickDocument(String docId) async {
    if (_pickingDocumentId != null) {
      return;
    }

    final allowedExtensions = docId == 'profilePic'
        ? const ['jpg', 'jpeg', 'png']
        : const ['pdf', 'jpg', 'jpeg', 'png'];

    setState(() {
      _pickingDocumentId = docId;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (!mounted || result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final path = file.path;
      if (path == null || path.trim().isEmpty) {
        AppToast.showError(
          context,
          'Unable to access the selected file. Try again.',
        );
        return;
      }

      _setDocumentPath(docId, path);
      setState(() {
        _uploadedDocuments[docId] = true;
        _selectedFileNames[docId] = file.name;
      });

      AppToast.showSuccess(
        context,
        '${_documentLabel(docId)} selected successfully.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _pickingDocumentId = null;
        });
      }
    }
  }

  String _documentLabel(String docId) {
    return documents.firstWhere((document) => document.id == docId).title;
  }

  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  bool _allDocumentsUploaded() {
    return _uploadedDocuments.values.every((uploaded) => uploaded);
  }

  Future<void> _onCompletePressed() async {
    if (!_allDocumentsUploaded()) {
      AppToast.showInfo(context, 'Please upload all documents');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.registerBabysitter(
      data: widget.registrationData,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      AppToast.showError(
        context,
        authProvider.errorMessage ?? 'Registration failed. Please try again.',
        statusCode: authProvider.lastStatusCode,
        fallbackMessage: 'Registration failed. Please try again.',
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const SitterLoginScreen(
          showPendingApprovalBanner: true,
          successMessage:
              'Registration submitted successfully. You can sign in after approval.',
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isSubmitting = authProvider.isLoading;

    return Scaffold(
      backgroundColor: BabyCareTheme.universalWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button & Title
                    _buildHeader(),

                    const SizedBox(height: 24),

                    // Progress Bar (100%)
                    _buildProgressBar(),

                    const SizedBox(height: 32),

                    // Document Upload Cards
                    _buildDocumentCards(isSubmitting: isSubmitting),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Sticky Footer Navigation
            _buildStickyFooter(isSubmitting: isSubmitting),
          ],
        ),
      ),
    );
  }

  /// Header with back button and title
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _onBackPressed,
                child: const Icon(
                  Icons.arrow_back,
                  color: BabyCareTheme.primaryBerry,
                  size: 28,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Verification Documents',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: BabyCareTheme.primaryBerry,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your documents to complete registration',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: BabyCareTheme.darkGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Progress bar showing 100% completion
  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step 3 of 3',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: BabyCareTheme.darkGrey),
            ),
            Text(
              '100%',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: BabyCareTheme.primaryBerry,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: 1.0,
            minHeight: 6,
            backgroundColor: BabyCareTheme.lightGrey,
            valueColor: const AlwaysStoppedAnimation<Color>(
              BabyCareTheme.primaryBerry,
            ),
          ),
        ),
      ],
    );
  }

  /// Document upload cards
  Widget _buildDocumentCards({required bool isSubmitting}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: documents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final doc = documents[index];
        final isUploaded = _uploadedDocuments[doc.id] ?? false;
        final isPicking = _pickingDocumentId == doc.id;
        final selectedFileName = _selectedFileNames[doc.id];

        return GestureDetector(
          onTap: isSubmitting ? null : () => _pickDocument(doc.id),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BabyCareTheme.universalWhite,
              border: Border.all(
                color: isUploaded
                    ? BabyCareTheme.primaryBerry
                    : BabyCareTheme.lightGrey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
              boxShadow: [
                if (isUploaded)
                  BoxShadow(
                    color: BabyCareTheme.primaryBerry.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              children: [
                // Icon Circle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUploaded
                        ? BabyCareTheme.lightPink
                        : BabyCareTheme.lightGrey,
                  ),
                  child: Center(
                    child: isPicking
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                BabyCareTheme.primaryBerry,
                              ),
                            ),
                          )
                        : isUploaded
                        ? const Icon(
                            Icons.check_circle,
                            color: BabyCareTheme.primaryBerry,
                            size: 32,
                          )
                        : Icon(
                            doc.icon,
                            color: BabyCareTheme.primaryBerry,
                            size: 28,
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: BabyCareTheme.darkGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc.description,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: BabyCareTheme.darkGrey.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isPicking
                            ? 'Selecting file...'
                            : isUploaded
                            ? (selectedFileName ?? 'Uploaded ✓')
                            : 'Tap to upload',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: isUploaded || isPicking
                              ? BabyCareTheme.primaryBerry
                              : BabyCareTheme.darkGrey.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Upload Arrow
                Icon(
                  isPicking ? Icons.more_horiz : Icons.arrow_forward,
                  color: isUploaded || isPicking
                      ? BabyCareTheme.primaryBerry
                      : BabyCareTheme.darkGrey.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Sticky footer navigation
  Widget _buildStickyFooter({required bool isSubmitting}) {
    final allUploaded = _allDocumentsUploaded();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: BabyCareTheme.universalWhite,
        border: Border(
          top: BorderSide(color: BabyCareTheme.lightGrey, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Back Button
            Expanded(
              child: GestureDetector(
                onTap: isSubmitting ? null : _onBackPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: BabyCareTheme.darkGrey, width: 2),
                    borderRadius: BorderRadius.circular(
                      BabyCareTheme.radiusLarge,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'BACK',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: BabyCareTheme.darkGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Complete Button
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: allUploaded
                      ? BabyCareTheme.primaryGradient
                      : LinearGradient(
                          colors: [
                            BabyCareTheme.lightGrey,
                            BabyCareTheme.lightGrey,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(
                    BabyCareTheme.radiusLarge,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: allUploaded && !isSubmitting
                      ? _onCompletePressed
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSubmitting)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              BabyCareTheme.universalWhite,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.check_circle_outline,
                          color: BabyCareTheme.universalWhite,
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        isSubmitting ? 'SUBMITTING' : 'COMPLETE',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: allUploaded || isSubmitting
                                  ? BabyCareTheme.universalWhite
                                  : BabyCareTheme.darkGrey.withValues(
                                      alpha: 0.5,
                                    ),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data class for document upload
class _DocumentUpload {
  final String id;
  final String title;
  final IconData icon;
  final String description;

  const _DocumentUpload({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
  });
}
