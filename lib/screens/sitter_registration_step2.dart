import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/sitter_registration.dart';
import 'sitter_registration_step3.dart';

class SitterRegistrationStep2Screen extends StatefulWidget {
  final SitterRegistrationData registrationData;

  const SitterRegistrationStep2Screen({
    super.key,
    required this.registrationData,
  });

  @override
  State<SitterRegistrationStep2Screen> createState() =>
      _SitterRegistrationStep2ScreenState();
}

class _SitterRegistrationStep2ScreenState
    extends State<SitterRegistrationStep2Screen> {
  late TextEditingController _rateController;
  late TextEditingController _languageController;

  final List<String> _daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  final List<String> _rateOptions = ['Hourly', 'Daily', 'Weekly', 'Monthly'];

  late Set<String> _selectedDays;
  late Set<String> _selectedLanguages;
  late String _selectedRateType;
  late String _selectedPaymentMethod;
  final String _currencyCode = 'UGX';

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController(
      text: widget.registrationData.hourlyRate ?? '',
    );
    _languageController = TextEditingController();

    // Initialize from registration data or defaults
    _selectedDays =
        (widget.registrationData.availableDays ?? ['Mon', 'Tue', 'Wed'])
            .toSet();
    _selectedLanguages = (widget.registrationData.languages ?? ['English'])
        .toSet();
    _selectedRateType =
      (widget.registrationData.rateType ?? 'hourly').toLowerCase() == 'daily'
      ? 'Daily'
      : (widget.registrationData.rateType ?? 'hourly').toLowerCase() ==
          'weekly'
      ? 'Weekly'
      : (widget.registrationData.rateType ?? 'hourly').toLowerCase() ==
          'monthly'
      ? 'Monthly'
      : 'Hourly';
    _selectedPaymentMethod =
        widget.registrationData.paymentMethod ?? 'Mobile Money';
  }

  @override
  void dispose() {
    _rateController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _addLanguage() {
    final lang = _languageController.text.trim();
    if (lang.isNotEmpty && !_selectedLanguages.contains(lang)) {
      setState(() {
        _selectedLanguages.add(lang);
        _languageController.clear();
      });
    }
  }

  void _removeLanguage(String lang) {
    setState(() {
      _selectedLanguages.remove(lang);
    });
  }

  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  void _onNextPressed() {
    // Save data
    widget.registrationData.availableDays = _selectedDays.toList();
    widget.registrationData.rateType = _selectedRateType.toLowerCase();
    widget.registrationData.hourlyRate = _rateController.text;
    widget.registrationData.currency = _currencyCode;
    widget.registrationData.languages = _selectedLanguages.toList();
    widget.registrationData.paymentMethod = _selectedPaymentMethod;

    if (_selectedDays.isEmpty ||
        _rateController.text.isEmpty ||
        _selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SitterRegistrationStep3Screen(
          registrationData: widget.registrationData,
        ),
      ),
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

                    // Progress Bar (66%)
                    _buildProgressBar(),

                    const SizedBox(height: 32),

                    // Availability Section
                    _buildAvailabilitySection(),

                    const SizedBox(height: 32),

                    // Rates Section
                    _buildRatesSection(),

                    const SizedBox(height: 32),

                    // Languages Section
                    _buildLanguagesSection(),

                    const SizedBox(height: 32),

                    // Payment Method Section
                    _buildPaymentMethodSection(),

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
            'Work Preferences',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: BabyCareTheme.primaryBerry,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Set your availability and rates',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: BabyCareTheme.darkGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Progress bar showing 66% completion
  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step 2 of 3',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: BabyCareTheme.darkGrey),
            ),
            Text(
              '66%',
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
            value: 0.66,
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

  /// Availability section with day pills
  Widget _buildAvailabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, color: BabyCareTheme.primaryBerry),
            const SizedBox(width: 8),
            Text(
              'Availability',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: BabyCareTheme.darkGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _daysOfWeek.map((day) {
            final isSelected = _selectedDays.contains(day);
            return GestureDetector(
              onTap: () => _toggleDay(day),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? BabyCareTheme.primaryBerry
                      : BabyCareTheme.lightGrey,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? BabyCareTheme.primaryBerry
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  day,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: isSelected
                        ? BabyCareTheme.universalWhite
                        : BabyCareTheme.darkGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Rates section with type and amount
  Widget _buildRatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_atm, color: BabyCareTheme.primaryBerry),
            const SizedBox(width: 8),
            Text(
              'Rates',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: BabyCareTheme.darkGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Rate Type Dropdown
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.darkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: BabyCareTheme.lightGrey,
                      borderRadius: BorderRadius.circular(
                        BabyCareTheme.radiusLarge,
                      ),
                      border: Border.all(color: BabyCareTheme.lightGrey),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedRateType,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      icon: const Icon(
                        Icons.expand_more,
                        color: BabyCareTheme.primaryBerry,
                      ),
                      items: _rateOptions.map((String rate) {
                        return DropdownMenuItem<String>(
                          value: rate,
                          child: Text(
                            rate,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedRateType = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Amount Input
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.darkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _rateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '5000',
                      hintStyle: TextStyle(
                        color: BabyCareTheme.darkGrey.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: BabyCareTheme.lightGrey,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          BabyCareTheme.radiusLarge,
                        ),
                        borderSide: const BorderSide(
                          color: BabyCareTheme.lightGrey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          BabyCareTheme.radiusLarge,
                        ),
                        borderSide: const BorderSide(
                          color: BabyCareTheme.primaryBerry,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Currency
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Currency',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.darkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: BabyCareTheme.lightGrey,
                      borderRadius: BorderRadius.circular(
                        BabyCareTheme.radiusLarge,
                      ),
                      border: Border.all(color: BabyCareTheme.lightGrey),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _currencyCode,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Languages section with tag input
  Widget _buildLanguagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.language, color: BabyCareTheme.primaryBerry),
            const SizedBox(width: 8),
            Text(
              'Languages',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: BabyCareTheme.darkGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Language chips
        if (_selectedLanguages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedLanguages.map((lang) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: BabyCareTheme.primaryBerry,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lang,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: BabyCareTheme.universalWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removeLanguage(lang),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: BabyCareTheme.universalWhite,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

        // Language input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _languageController,
                decoration: InputDecoration(
                  hintText: 'Add language (English, Luganda, ...)',
                  hintStyle: TextStyle(
                    color: BabyCareTheme.darkGrey.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: BabyCareTheme.lightGrey,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      BabyCareTheme.radiusLarge,
                    ),
                    borderSide: const BorderSide(
                      color: BabyCareTheme.lightGrey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      BabyCareTheme.radiusLarge,
                    ),
                    borderSide: const BorderSide(
                      color: BabyCareTheme.primaryBerry,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _addLanguage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: BabyCareTheme.primaryBerry,
                  borderRadius: BorderRadius.circular(
                    BabyCareTheme.radiusLarge,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.add, color: BabyCareTheme.universalWhite),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Payment method section
  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.payment, color: BabyCareTheme.primaryBerry),
            const SizedBox(width: 8),
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: BabyCareTheme.darkGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: BabyCareTheme.lightGrey,
            borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
            border: Border.all(color: BabyCareTheme.lightGrey),
          ),
          child: Column(
            children: [
              _buildPaymentRadioOption('Mobile Money'),
              Divider(
                color: BabyCareTheme.universalWhite,
                thickness: 1,
                height: 12,
              ),
              _buildPaymentRadioOption('Cash'),
              Divider(
                color: BabyCareTheme.universalWhite,
                thickness: 1,
                height: 12,
              ),
              _buildPaymentRadioOption('Bank/Visa Card'),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper widget for payment radio option
  Widget _buildPaymentRadioOption(String method) {
    return Row(
      children: [
        Radio<String>(
          value: method,
          groupValue: _selectedPaymentMethod,
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            }
          },
          activeColor: BabyCareTheme.primaryBerry,
        ),
        const SizedBox(width: 8),
        Text(
          method,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: BabyCareTheme.darkGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Sticky footer navigation
  Widget _buildStickyFooter() {
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

            // Next Button
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: BabyCareTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(
                    BabyCareTheme.radiusLarge,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'NEXT: UPLOAD',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: BabyCareTheme.universalWhite,
                      fontWeight: FontWeight.bold,
                    ),
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
