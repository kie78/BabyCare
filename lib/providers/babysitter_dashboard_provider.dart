import 'package:flutter/foundation.dart';

import '../models/babysitter_profile.dart';
import '../models/parent_public_profile.dart';
import '../models/profile_view.dart';
import '../services/api_client.dart';
import '../services/babysitter_service.dart';

class BabysitterDashboardProvider extends ChangeNotifier {
  BabysitterDashboardProvider({required BabysitterService babysitterService})
    : _babysitterService = babysitterService;

  final BabysitterService _babysitterService;

  BabysitterProfile? _profile;
  List<ProfileView> _profileViews = const <ProfileView>[];
  final Map<String, ParentPublicProfile> _parentProfileCache =
      <String, ParentPublicProfile>{};
  int _weeklyViews = 0;
  bool _isLoading = false;
  bool _isUpdatingAvailability = false;
  bool _isUpdatingProfile = false;
  String? _errorMessage;
  String? _successMessage;
  int? _lastStatusCode;

  BabysitterProfile? get profile => _profile;
  List<ProfileView> get profileViews => _profileViews;
  int get weeklyViews => _weeklyViews;
  bool get isLoading => _isLoading;
  bool get isUpdatingAvailability => _isUpdatingAvailability;
  bool get isUpdatingProfile => _isUpdatingProfile;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  int? get lastStatusCode => _lastStatusCode;
  bool get isAvailable => _profile?.isAvailable ?? false;

  int _extractCount(dynamic payload) {
    if (payload is int) {
      return payload;
    }

    if (payload is num) {
      return payload.toInt();
    }

    if (payload is List) {
      return payload.length;
    }

    if (payload is! Map<String, dynamic>) {
      return 0;
    }

    final nestedStats = payload['data'] is Map<String, dynamic>
        ? payload['data'] as Map<String, dynamic>
        : payload['stats'] is Map<String, dynamic>
        ? payload['stats'] as Map<String, dynamic>
        : payload['meta'] is Map<String, dynamic>
        ? payload['meta'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final candidates = <dynamic>[
      payload['count'],
      payload['total'],
      payload['weekly_views'],
      payload['views'],
      payload['weeklyReach'],
      payload['weekly_reach'],
      payload['this_week_views'],
      nestedStats['count'],
      nestedStats['total'],
      nestedStats['weekly_views'],
      nestedStats['views'],
      nestedStats['weekly_reach'],
      nestedStats['this_week_views'],
    ];

    for (final candidate in candidates) {
      final value = int.tryParse((candidate ?? '').toString());
      if (value != null) {
        return value;
      }
    }

    final extractedViews = _extractViews(payload);
    if (extractedViews.isNotEmpty) {
      return extractedViews.length;
    }

    return 0;
  }

  List<ProfileView> _extractViews(dynamic payload) {
    if (payload is List) {
      return payload
          .whereType<Map<String, dynamic>>()
          .map(ProfileView.fromJson)
          .toList();
    }

    if (payload is! Map<String, dynamic>) {
      return const <ProfileView>[];
    }

    final data = payload['data'];
    final rawList = data is List
        ? data
        : payload['items'] ??
              payload['views'] ??
              payload['profile_views'] ??
              payload['recent_visitors'] ??
              payload['visitors'] ??
              (data is Map<String, dynamic>
                  ? data['items'] ??
                        data['views'] ??
                        data['profile_views'] ??
                        data['recent_visitors'] ??
                        data['visitors']
                  : null);
    if (rawList is! List) {
      return const <ProfileView>[];
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(ProfileView.fromJson)
        .toList();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> _enrichProfileViews() async {
    if (_profileViews.isEmpty) {
      return;
    }

    final enrichedViews = <ProfileView>[];
    for (final view in _profileViews) {
      final parentId = view.id.trim();
      if (parentId.isEmpty) {
        enrichedViews.add(view);
        continue;
      }

      ParentPublicProfile? publicProfile = _parentProfileCache[parentId];
      if (publicProfile == null) {
        try {
          publicProfile = await _babysitterService.getParentPublicProfile(
            parentId,
          );
          _parentProfileCache[parentId] = publicProfile;
        } catch (_) {
          enrichedViews.add(view);
          continue;
        }
      }

      enrichedViews.add(
        view.copyWith(
          viewerName: publicProfile.fullName,
          occupation:
              (publicProfile.occupation ?? '').trim().isEmpty
                  ? view.occupation
                  : publicProfile.occupation,
          location:
              (publicProfile.primaryLocation ?? publicProfile.location ?? '')
                      .trim()
                      .isEmpty
                  ? view.location
                  : (publicProfile.primaryLocation ?? publicProfile.location),
          preferredHours:
              (publicProfile.preferredHours ?? '').trim().isEmpty
                  ? view.preferredHours
                  : publicProfile.preferredHours,
          profileImageUrl:
              (publicProfile.profilePictureUrl ?? '').trim().isEmpty
                  ? view.profileImageUrl
                  : publicProfile.profilePictureUrl,
        ),
      );
    }

    _profileViews = enrichedViews;
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      _profile = await _babysitterService.getMyProfile();

      try {
        final profileViewsResponse = await _babysitterService.getProfileViews();
        _profileViews = _extractViews(profileViewsResponse);
        await _enrichProfileViews();
      } catch (_) {
        _profileViews = const <ProfileView>[];
      }

      try {
        final weeklyViewsResponse = await _babysitterService.getWeeklyProfileViews();
        _weeklyViews = _extractCount(weeklyViewsResponse);
        if (_weeklyViews == 0 && _profileViews.isNotEmpty) {
          final now = DateTime.now();
          _weeklyViews = _profileViews.where((view) {
            final viewedAt = view.viewedAt;
            if (viewedAt == null) {
              return false;
            }
            return now.difference(viewedAt).inDays < 7;
          }).length;
        }
      } catch (_) {
        final now = DateTime.now();
        _weeklyViews = _profileViews.where((view) {
          final viewedAt = view.viewedAt;
          if (viewedAt == null) {
            return false;
          }
          return now.difference(viewedAt).inDays < 7;
        }).length;
      }
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load your dashboard right now.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAvailability(bool isAvailable) async {
    _isUpdatingAvailability = true;
    _errorMessage = null;
    _successMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      await _babysitterService.updateWorkStatus(isAvailable: isAvailable);
      if (_profile != null) {
        _profile = BabysitterProfile(
          id: _profile!.id,
          fullName: _profile!.fullName,
          email: _profile!.email,
          status: _profile!.status,
          phone: _profile!.phone,
          location: _profile!.location,
          gender: _profile!.gender,
          languages: _profile!.languages,
          availability: _profile!.availability,
          rateType: _profile!.rateType,
          rateAmount: _profile!.rateAmount,
          currency: _profile!.currency,
          paymentMethod: _profile!.paymentMethod,
          isAvailable: isAvailable,
          profilePictureUrl: _profile!.profilePictureUrl,
        );
      }
      _successMessage = isAvailable
          ? 'You are now marked as available.'
          : 'You are now marked as unavailable.';
      return true;
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to update your work status right now.';
      return false;
    } finally {
      _isUpdatingAvailability = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String location,
    required String rateType,
    required String rateAmount,
    required String currency,
    required String paymentMethod,
    required List<String> availability,
  }) async {
    _isUpdatingProfile = true;
    _errorMessage = null;
    _successMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      await _babysitterService.updateProfile(
        location: location,
        rateType: rateType,
        rateAmount: rateAmount,
        currency: currency,
        paymentMethod: paymentMethod,
        availability: availability,
      );
      _profile = await _babysitterService.getMyProfile();
      _successMessage = 'Your profile has been updated successfully.';
      return true;
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to update your profile right now.';
      return false;
    } finally {
      _isUpdatingProfile = false;
      notifyListeners();
    }
  }
}
