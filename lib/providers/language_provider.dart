import 'package:flutter/material.dart';

import '../services/settings_service.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageProvider(this._settingsService);

  final SettingsService _settingsService;
  Locale _locale = const Locale('ar');
  bool _isLoaded = false;

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isLoaded => _isLoaded;
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;

  Future<void> loadSavedLanguage() async {
    final code = _settingsService.getLanguageCode();
    _locale = Locale(code == 'en' ? 'en' : 'ar');
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> changeLanguage(Locale locale) async {
    final code = locale.languageCode == 'en' ? 'en' : 'ar';
    if (_locale.languageCode == code) {
      return;
    }
    _locale = Locale(code);
    await _settingsService.setLanguageCode(code);
    notifyListeners();
  }
}
