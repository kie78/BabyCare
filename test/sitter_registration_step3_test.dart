import 'package:babycare/models/sitter_registration.dart';
import 'package:babycare/providers/auth_provider.dart';
import 'package:babycare/screens/sitter_login.dart';
import 'package:babycare/screens/sitter_registration_step3.dart';
import 'package:babycare/services/api_client.dart';
import 'package:babycare/services/auth_service.dart';
import 'package:babycare/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'submits babysitter registration and navigates to login on success',
    (WidgetTester tester) async {
      final authService = _FakeAuthService();
      final authProvider = AuthProvider(authService: authService);
      final registrationData = _buildRegistrationData();

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: SitterRegistrationStep3Screen(
              registrationData: registrationData,
            ),
          ),
        ),
      );

      await tester.tap(find.text('COMPLETE'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(authService.submittedData, same(registrationData));
      expect(find.byType(SitterLoginScreen), findsOneWidget);
      expect(
        find.text(
          'Registration submitted successfully. You can sign in after approval.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows backend error and stays on step 3 when submission fails',
    (WidgetTester tester) async {
      final authService = _FakeAuthService(
        error: ApiException(
          statusCode: 400,
          message: 'Registration data could not be submitted.',
        ),
      );
      final authProvider = AuthProvider(authService: authService);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: SitterRegistrationStep3Screen(
              registrationData: _buildRegistrationData(),
            ),
          ),
        ),
      );

      await tester.tap(find.text('COMPLETE'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(SitterRegistrationStep3Screen), findsOneWidget);
      expect(find.byType(SitterLoginScreen), findsNothing);
      expect(
        find.text('Registration data could not be submitted.'),
        findsOneWidget,
      );
    },
  );
}

SitterRegistrationData _buildRegistrationData() {
  return SitterRegistrationData()
    ..fullName = 'Test Babysitter'
    ..email = 'sitter@example.com'
    ..gender = 'female'
    ..phone = '+256700000000'
    ..location = 'Kampala'
    ..password = 'strong-password'
    ..availableDays = const ['Mon', 'Tue', 'Wed']
    ..rateType = 'hourly'
    ..hourlyRate = '15000'
    ..currency = 'UGX'
    ..languages = const ['English']
    ..paymentMethod = 'Mobile Money'
    ..profilePicturePath = '/tmp/profile.jpg'
    ..nationalIdPath = '/tmp/national-id.pdf'
    ..lciLetterPath = '/tmp/lci-letter.pdf'
    ..resumeCvPath = '/tmp/resume.pdf';
}

class _FakeAuthService extends AuthService {
  _FakeAuthService({this.error})
    : super(
        apiClient: ApiClient(baseUrl: 'http://localhost'),
        storage: SecureStorageService(),
      );

  final ApiException? error;
  SitterRegistrationData? submittedData;

  @override
  Future<Map<String, dynamic>> registerBabysitter({
    required SitterRegistrationData data,
  }) async {
    submittedData = data;

    if (error != null) {
      throw error!;
    }

    return <String, dynamic>{'message': 'ok'};
  }
}