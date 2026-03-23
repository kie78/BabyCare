import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/sitter_registration.dart';
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
  }

  void _simulateUpload(String docId) {
    // Simulate file picker and upload
    setState(() {
      _uploadedDocuments[docId] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$docId uploaded successfully'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  bool _allDocumentsUploaded() {
    return _uploadedDocuments.values.every((uploaded) => uploaded);
  }

  void _onCompletePressed() {
    if (!_allDocumentsUploaded()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all documents')),
      );
      return;
    }

    // Save final data
    widget.registrationData.profilePicturePath = 'uploaded';
    widget.registrationData.nationalIdPath = 'uploaded';
    widget.registrationData.lciLetterPath = 'uploaded';
    widget.registrationData.resumeCvPath = 'uploaded';

    // TODO: Submit registration to backend
    // For now, navigate to Sitter Login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SitterLoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildDocumentCards(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Sticky Footer Navigation
            _buildStickyFooter(),
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
  Widget _buildDocumentCards() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: documents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final doc = documents[index];
        final isUploaded = _uploadedDocuments[doc.id] ?? false;

        return GestureDetector(
          onTap: () => _simulateUpload(doc.id),
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
                    child: isUploaded
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
                        isUploaded ? 'Uploaded ✓' : 'Tap to upload',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: isUploaded
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
                  Icons.arrow_forward,
                  color: isUploaded
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
  Widget _buildStickyFooter() {
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
                onTap: _onBackPressed,
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
                  onPressed: allUploaded ? _onCompletePressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: BabyCareTheme.universalWhite,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'COMPLETE',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: allUploaded
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
