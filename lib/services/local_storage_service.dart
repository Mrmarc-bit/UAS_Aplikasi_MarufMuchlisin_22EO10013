import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/savings_model.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  static const String _storageKey = 'saku_nabung_data';

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  SharedPreferences? _prefs;

  // Initialize shared preferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save a new record or update existing one
  Future<void> saveSavingsRecord(SavingsRecord record) async {
    await _ensureInitialized();
    List<SavingsRecord> currentRecords = await getAllSavingsRecords();

    final index = currentRecords.indexWhere((item) => item.id == record.id);
    if (index >= 0) {
      currentRecords[index] = record;
    } else {
      currentRecords.add(record);
    }

    await _saveRecordsToStorage(currentRecords);
  }

  // Delete a record
  Future<void> deleteSavingsRecord(String id) async {
    await _ensureInitialized();
    List<SavingsRecord> currentRecords = await getAllSavingsRecords();
    currentRecords.removeWhere((item) => item.id == id);
    await _saveRecordsToStorage(currentRecords);
  }

  // Get all records sorted by date (newest first)
  Future<List<SavingsRecord>> getAllSavingsRecords() async {
    await _ensureInitialized();
    final String? data = _prefs!.getString(_storageKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      List<dynamic> jsonList = json.decode(data);
      List<SavingsRecord> records =
          jsonList.map((item) => SavingsRecord.fromMap(item)).toList();

      // Sort: Newest first
      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    } catch (e) {
      print('Error parsing savings data: $e');
      return [];
    }
  }

  // Get total savings amount
  Future<double> getTotalSavings() async {
    List<SavingsRecord> records = await getAllSavingsRecords();
    return records.fold<double>(
        0.0, (double sum, SavingsRecord item) => sum + item.amount);
  }

  // Helper to save list to storage
  Future<void> _saveRecordsToStorage(List<SavingsRecord> records) async {
    String jsonString = json.encode(records.map((e) => e.toMap()).toList());
    await _prefs!.setString(_storageKey, jsonString);
  }

  static const String _userProfileKey = 'saku_nabung_user_profile';

  // ... existing init ...

  // User Profile Methods
  Future<Map<String, String>> getUserProfile() async {
    await _ensureInitialized();
    final String? data = _prefs!.getString(_userProfileKey);
    if (data == null) {
      return {'name': 'Maruf Muchlisin', 'email': 'maruf@example.com'};
    }
    return Map<String, String>.from(json.decode(data));
  }

  Future<void> saveUserProfile(String name, String email) async {
    await _ensureInitialized();
    final map = {'name': name, 'email': email};
    await _prefs!.setString(_userProfileKey, json.encode(map));
  }

  static const String _userProfileImageKey = 'saku_nabung_user_profile_image';

  // ... existing code ...

  // Profile Image Methods
  Future<String?> getProfileImage() async {
    await _ensureInitialized();
    return _prefs!.getString(_userProfileImageKey);
  }

  Future<void> saveProfileImage(String base64Image) async {
    await _ensureInitialized();
    await _prefs!.setString(_userProfileImageKey, base64Image);
  }

  // Clear all savings data
  Future<void> clearAllSavings() async {
    await _ensureInitialized();
    await _prefs!.remove(_storageKey);
    // Optional: Keep profile data or clear it? Keeping it for now as "savings data" implies records.
  }

  // Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }
}
