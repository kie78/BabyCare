## Plan: Babysitter-First API Integration

Implement backend connectivity in phased order, starting with babysitter registration, login, dashboard/profile, and messaging before parent/admin work. This de-risks core marketplace supply first while establishing a reusable service/auth architecture for the rest of the app.

**Steps**
1. Phase 1 - Foundation and Architecture
2. Add dependencies in `pubspec.yaml`: `http`, `flutter_secure_storage`, `provider` (and `image_picker`/`file_picker` if not already present for sitter documents).
3. Create API foundation in `lib/services`: `api_client.dart` (base URL, bearer header injection, timeout/error mapping), `secure_storage_service.dart` (JWT persistence), `auth_service.dart` (login/logout and role extraction).
4. Add core typed models used immediately by sitter flow: `auth_user.dart`, `auth_session.dart`, `babysitter_profile.dart`, `conversation.dart`, `message.dart`. Keep model parsing tolerant to optional API fields.
5. Add state layer in `lib/providers`: `auth_provider.dart` and `babysitter_provider.dart` to manage auth state, sitter profile, availability toggle, and loading/error states. *depends on 3-4*
6. Wire app bootstrap in `lib/main.dart` with `MultiProvider` and startup session rehydration from secure storage. *depends on 3, parallel with 4-5 once interfaces are stable*
7. Phase 2 - Babysitter Registration and Login
8. Refactor the 3-step sitter registration flow to produce a single payload object and submit multipart form data to `POST /api/v1/auth/register/babysitter` from step 3, including all required files and text fields.
9. Add registration submission states: idle/loading/success/error, plus explicit validation and per-field error messaging for missing documents and malformed values.
10. Update sitter login screen to call `POST /api/v1/auth/login`, enforce role=`babysitter`, handle approval-related `403`, persist token, and route authenticated users to sitter dashboard. *depends on 3,5*
11. Add a small “pending approval” screen/state for newly registered sitters who cannot log in until approved.
12. Phase 3 - Babysitter Dashboard, Profile, and Work Status
13. Implement sitter data service methods: fetch own profile, update profile (multipart), fetch profile views, fetch weekly views, update work status (`PUT /api/v1/babysitters/work-status`).
14. Replace mock sitter dashboard data with live provider-backed data, including pull-to-refresh and resilient empty/error states.
15. Connect sitter account screen save actions to profile update endpoint and map API success/errors into user-friendly feedback.
16. Add availability toggle on dashboard/account backed by work-status endpoint with optimistic UI + rollback on failure.
17. Phase 4 - Babysitter Messaging
18. Implement messaging service methods for `GET /api/v1/conversations`, `GET /api/v1/conversations/:id/messages`, and `POST /api/v1/conversations/:id/messages`.
19. Replace mock sitter messages list with API-backed conversation list and unread/empty/error handling.
20. Add sitter chat thread screen with periodic refresh (polling), message send state, and scroll-to-latest behavior.
21. Phase 5 - Hardening and Parent/Admin Follow-on
22. Add reusable unauthorized handling (401/403): clear session, redirect to login, and preserve actionable error copy.
23. Add lightweight unit/widget tests for auth provider, sitter registration submission, login approval handling, work-status toggle, and conversation loading.
24. After sitter flow is stable, start parent flow integration (discover, save babysitters, initiate conversations) reusing the same API client/provider patterns.

**Relevant files**
- `/home/el/Flttr/BabyCare/pubspec.yaml` - add networking/storage/state dependencies.
- `/home/el/Flttr/BabyCare/lib/main.dart` - bootstrap providers and auth rehydration.
- `/home/el/Flttr/BabyCare/lib/models/sitter_registration.dart` - reuse/extend registration aggregate data model.
- `/home/el/Flttr/BabyCare/lib/screens/sitter_registration_step1.dart` - input validation and state handoff.
- `/home/el/Flttr/BabyCare/lib/screens/sitter_registration_step2.dart` - availability/language/rate collection.
- `/home/el/Flttr/BabyCare/lib/screens/sitter_registration_step3.dart` - multipart submission + document validation.
- `/home/el/Flttr/BabyCare/lib/screens/sitter_login.dart` - real auth integration and approval error handling.
- `/home/el/Flttr/BabyCare/lib/screens/sitter_dashboard.dart` - live analytics and status UI.
- `/home/el/Flttr/BabyCare/lib/screens/sitter_account.dart` - profile update wiring.
- `/home/el/Flttr/BabyCare/lib/screens/sitter_messages.dart` - API-backed conversation list.
- `/home/el/Flttr/BabyCare/lib/screens/sitter_profile_parent_view.dart` - verify any sitter profile display mapping still matches model changes.
- `/home/el/Flttr/BabyCare/lib/services/api_client.dart` - new base HTTP abstraction.
- `/home/el/Flttr/BabyCare/lib/services/auth_service.dart` - new auth endpoint integration.
- `/home/el/Flttr/BabyCare/lib/services/babysitter_service.dart` - new sitter endpoint integration.
- `/home/el/Flttr/BabyCare/lib/services/messaging_service.dart` - new messaging endpoint integration.
- `/home/el/Flttr/BabyCare/lib/services/secure_storage_service.dart` - new token persistence wrapper.
- `/home/el/Flttr/BabyCare/lib/providers/auth_provider.dart` - new auth state management.
- `/home/el/Flttr/BabyCare/lib/providers/babysitter_provider.dart` - new sitter state management.
- `/home/el/Flttr/BabyCare/lib/providers/messaging_provider.dart` - new conversation/message state management.
- `/home/el/Flttr/BabyCare/lib/screens/sitter_chat_thread.dart` - new conversation detail UI.

**Verification**
1. Run `flutter pub get` and `flutter analyze` to ensure dependency and static analysis health.
2. Registration E2E: complete 3 sitter steps with valid files and verify successful API response plus pending-approval UX.
3. Login E2E: verify approved sitter can log in and token persists across app restart.
4. Approval guard: verify unapproved sitter receives correct 403 UX and no authenticated navigation occurs.
5. Dashboard/profile E2E: verify profile/views/work-status endpoints update UI and survive refresh.
6. Messaging E2E: verify conversations load, thread opens, send message succeeds, and poll refresh receives new messages.
7. Failure-path checks: offline/timeout, invalid token, and backend validation errors surface clear messages without crashes.

**Decisions**
- Included scope: babysitter flows first (registration, auth, dashboard/profile, messaging), then parent follow-on.
- Excluded for this pass: admin UI integration and advanced realtime Stream SDK migration; polling-based messaging is sufficient initially.
- Technical direction: Provider + service layer (low friction for this current codebase) with strongly-typed models and centralized API error handling.

**Further Considerations**
1. File upload package choice recommendation: `file_picker` for docs + images in one API surface, unless camera/gallery capture is required (then combine with `image_picker`).
2. Polling interval recommendation for chat: start at 5-8 seconds with manual refresh fallback to balance responsiveness and API cost.
3. Add request logging interceptor in debug mode only to accelerate integration debugging without exposing sensitive tokens in release builds.
