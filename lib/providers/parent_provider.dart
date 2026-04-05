import 'package:flutter/foundation.dart';

import '../models/babysitter_profile.dart';
import '../models/parent_profile.dart';
import '../services/api_client.dart';
import '../services/babysitter_service.dart';
import '../services/parent_service.dart';

class ParentProvider extends ChangeNotifier {
  ParentProvider({
    required ParentService parentService,
    required BabysitterService babysitterService,
  }) : _parentService = parentService,
       _babysitterService = babysitterService;

  final ParentService _parentService;
  final BabysitterService _babysitterService;

  List<BabysitterProfile> _sitters = const <BabysitterProfile>[];
  List<BabysitterProfile> _savedSitters = const <BabysitterProfile>[];
  final Map<String, BabysitterProfile> _babysitterCache =
      <String, BabysitterProfile>{};
  ParentProfile? _profile;
  BabysitterProfile? _selectedSitter;
  String _searchQuery = '';
  bool _isLoadingSitters = false;
  bool _isLoadingSavedSitters = false;
  bool _isLoadingProfile = false;
  bool _isUpdatingProfile = false;
  bool _isTogglingSave = false;
  bool _isLoadingSelectedSitter = false;
  String? _errorMessage;
  String? _successMessage;
  int? _lastStatusCode;

  List<BabysitterProfile> get sitters => _sitters;
  List<BabysitterProfile> get savedSitters => _savedSitters;
  ParentProfile? get profile => _profile;
  BabysitterProfile? get selectedSitter => _selectedSitter;
  bool get isLoadingSitters => _isLoadingSitters;
  bool get isLoadingSavedSitters => _isLoadingSavedSitters;
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isUpdatingProfile => _isUpdatingProfile;
  bool get isTogglingSave => _isTogglingSave;
  bool get isLoadingSelectedSitter => _isLoadingSelectedSitter;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  int? get lastStatusCode => _lastStatusCode;

  List<BabysitterProfile> get filteredSitters {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _sitters;
    }

    return _sitters.where((sitter) {
      return sitter.fullName.toLowerCase().contains(query) ||
          (sitter.location ?? '').toLowerCase().contains(query) ||
          sitter.languages.any(
            (language) => language.toLowerCase().contains(query),
          );
    }).toList();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  bool isSaved(String babysitterId) {
    return _savedSitters.any((sitter) => sitter.id == babysitterId);
  }

  BabysitterProfile? cachedBabysitter(String babysitterId) {
    final normalizedId = babysitterId.trim();
    if (normalizedId.isEmpty) {
      return null;
    }

    final cached = _babysitterCache[normalizedId];
    if (cached != null) {
      return cached;
    }

    for (final sitter in _sitters) {
      if (sitter.id == normalizedId) {
        return sitter;
      }
    }

    for (final sitter in _savedSitters) {
      if (sitter.id == normalizedId) {
        return sitter;
      }
    }

    return null;
  }

  BabysitterProfile? cachedBabysitterByName(String fullName) {
    final normalizedFullName = fullName.trim().toLowerCase();
    if (normalizedFullName.isEmpty) {
      return null;
    }

    for (final sitter in _babysitterCache.values) {
      if (sitter.fullName.trim().toLowerCase() == normalizedFullName) {
        return sitter;
      }
    }

    for (final sitter in _sitters) {
      if (sitter.fullName.trim().toLowerCase() == normalizedFullName) {
        return sitter;
      }
    }

    for (final sitter in _savedSitters) {
      if (sitter.fullName.trim().toLowerCase() == normalizedFullName) {
        return sitter;
      }
    }

    return null;
  }

  Future<BabysitterProfile?> fetchBabysitterById(String babysitterId) async {
    final normalizedId = babysitterId.trim();
    if (normalizedId.isEmpty) {
      return null;
    }

    final cached = cachedBabysitter(normalizedId);
    if (cached != null) {
      return cached;
    }

    try {
      final babysitter = await _babysitterService.getBabysitterById(normalizedId);
      _babysitterCache[normalizedId] = babysitter;
      return babysitter;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadSitters() async {
    _isLoadingSitters = true;
    _errorMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      _sitters = await _babysitterService.getBabysitters();
      for (final sitter in _sitters) {
        _babysitterCache[sitter.id] = sitter;
      }
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load babysitters right now.';
    } finally {
      _isLoadingSitters = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedSitters() async {
    _isLoadingSavedSitters = true;
    _errorMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      _savedSitters = await _parentService.getSavedBabysitters();
      for (final sitter in _savedSitters) {
        _babysitterCache[sitter.id] = sitter;
      }
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load your saved sitters right now.';
    } finally {
      _isLoadingSavedSitters = false;
      notifyListeners();
    }
  }

  Future<void> loadParentProfile({bool silent = false}) async {
    if (!silent) {
      _isLoadingProfile = true;
      _errorMessage = null;
      _lastStatusCode = null;
      notifyListeners();
    }

    try {
      _profile = await _parentService.getProfile();
      _lastStatusCode = null;
      notifyListeners();
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      if (!silent) {
        _errorMessage = error.message;
      }
    } catch (_) {
      if (!silent) {
        _errorMessage = 'Unable to load your profile right now.';
      }
    } finally {
      if (!silent) {
        _isLoadingProfile = false;
        notifyListeners();
      }
    }
  }

  Future<bool> updateParentProfile(
    ParentProfile profile, {
    String? profilePicturePath,
  }) async {
    _isUpdatingProfile = true;
    _errorMessage = null;
    _successMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      _profile = await _parentService.updateProfileWithImage(
        profile: profile,
        profilePicturePath: profilePicturePath,
      );
      _successMessage = 'Your profile has been updated successfully.';
      return true;
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to save your profile right now.';
      return false;
    } finally {
      _isUpdatingProfile = false;
      notifyListeners();
    }
  }

  Future<void> loadBabysitter(String babysitterId) async {
    _isLoadingSelectedSitter = true;
    _errorMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      _selectedSitter = await _babysitterService.getBabysitterById(
        babysitterId,
      );
      if (_selectedSitter != null) {
        _babysitterCache[_selectedSitter!.id] = _selectedSitter!;
      }
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load this sitter profile right now.';
    } finally {
      _isLoadingSelectedSitter = false;
      notifyListeners();
    }
  }

  Future<bool> toggleSavedSitter(BabysitterProfile babysitter) async {
    _isTogglingSave = true;
    _errorMessage = null;
    _successMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    final alreadySaved = isSaved(babysitter.id);

    try {
      if (alreadySaved) {
        await _parentService.deleteSavedBabysitter(babysitter.id);
        _savedSitters = _savedSitters
            .where((sitter) => sitter.id != babysitter.id)
            .toList();
        _successMessage = 'Removed ${babysitter.fullName} from saved sitters.';
      } else {
        await _parentService.saveBabysitter(babysitter.id);
        _savedSitters = [..._savedSitters, babysitter];
        _successMessage = 'Saved ${babysitter.fullName} successfully.';
      }
      return true;
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to update saved sitters right now.';
      return false;
    } finally {
      _isTogglingSave = false;
      notifyListeners();
    }
  }
}
