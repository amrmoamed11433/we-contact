import 'local_database_service.dart';

class SettingsService {
  SettingsService(this._database);

  static const String languageCodeKey = 'language_code';
  static const String demoDataCreatedKey = 'demo_data_created';

  final LocalDatabaseService _database;

  String getLanguageCode() {
    return _database.getSetting<String>(languageCodeKey) ?? 'ar';
  }

  Future<void> setLanguageCode(String code) {
    return _database.setSetting<String>(languageCodeKey, code);
  }

  bool getDemoDataCreated() {
    return _database.getSetting<bool>(demoDataCreatedKey) ?? false;
  }

  Future<void> setDemoDataCreated(bool value) {
    return _database.setSetting<bool>(demoDataCreatedKey, value);
  }
}
