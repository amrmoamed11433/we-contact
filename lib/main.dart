import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/app_provider.dart';
import 'providers/language_provider.dart';
import 'services/local_database_service.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = LocalDatabaseService();
  await database.init();
  final settingsService = SettingsService(database);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(settingsService),
        ),
        ChangeNotifierProvider(
          create: (_) => AppProvider(
            database: database,
            settingsService: settingsService,
          ),
        ),
      ],
      child: const WEPackagesApp(),
    ),
  );
}
