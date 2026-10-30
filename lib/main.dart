import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/ads/ad_service.dart';
import 'core/persistence/local_store.dart';
import 'features/notes/data/note_repository.dart';
import 'features/notes/state/notes_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAds();
  final store = await LocalStore.open();
  final settings = await SettingsRepository(store).load();
  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        initialSettingsProvider.overrideWithValue(settings),
      ],
      child: const UwriteApp(),
    ),
  );
}
