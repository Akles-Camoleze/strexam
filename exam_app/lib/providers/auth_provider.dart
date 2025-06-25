import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/request_models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    _currentUser = _storageService.getCurrentUser();
    notifyListeners();
  }

  Future<bool> createUser(String username, String email, String fullName) async {
    _setLoading(true);
    _clearError();

    try {
      final request = UserCreateRequest(
        username: username,
        email: email,
        fullName: fullName,
      );

      final user = await _apiService.createUser(request);
      await _setCurrentUser(user);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithUsername(String username) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _apiService.getUserByUsername(username);
      await _setCurrentUser(user);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storageService.removeCurrentUser();
    await _storageService.removeCurrentSession();
    notifyListeners();
  }

  Future<void> _setCurrentUser(User user) async {
    _currentUser = user;
    await _storageService.saveCurrentUser(user);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}