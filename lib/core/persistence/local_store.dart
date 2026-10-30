import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// JSON-file store. One file per note plus a settings document.
/// Cloud sync can later replace or wrap this layer without touching UI.
class LocalStore {
  LocalStore(this.root);

  final Directory root;

  Directory get notesDir => Directory(p.join(root.path, 'notes'));

  Directory get imagesDir => Directory(p.join(root.path, 'images'));

  File get settingsFile => File(p.join(root.path, 'settings.json'));

  static Future<LocalStore> open({Directory? root}) async {
    final Directory dir;
    if (root != null) {
      dir = root;
    } else {
      final docs = await getApplicationDocumentsDirectory();
      dir = Directory(p.join(docs.path, 'atelier'));
    }
    await dir.create(recursive: true);
    await Directory(p.join(dir.path, 'notes')).create(recursive: true);
    await Directory(p.join(dir.path, 'images')).create(recursive: true);
    return LocalStore(dir);
  }

  Future<List<Map<String, dynamic>>> readAllNotes() async {
    if (!await notesDir.exists()) return [];
    final files = notesDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();
    final notes = <Map<String, dynamic>>[];
    for (final file in files) {
      try {
        final map = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        notes.add(map);
      } catch (_) {
        // Skip unreadable files rather than crashing the gallery.
      }
    }
    return notes;
  }

  Future<void> writeNote(String id, Map<String, dynamic> json) async {
    await notesDir.create(recursive: true);
    final file = File(p.join(notesDir.path, '$id.json'));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  }

  Future<void> deleteNote(String id) async {
    final file = File(p.join(notesDir.path, '$id.json'));
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Map<String, dynamic>?> readSettings() async {
    if (!await settingsFile.exists()) return null;
    try {
      return jsonDecode(await settingsFile.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> writeSettings(Map<String, dynamic> json) async {
    await settingsFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(json),
    );
  }

  Future<int> estimatedBytes() async {
    var total = 0;
    if (await notesDir.exists()) {
      for (final file in notesDir.listSync().whereType<File>()) {
        total += await file.length();
      }
    }
    if (await imagesDir.exists()) {
      for (final file in imagesDir.listSync().whereType<File>()) {
        total += await file.length();
      }
    }
    if (await settingsFile.exists()) {
      total += await settingsFile.length();
    }
    return total;
  }

  Future<String> exportBundle() async {
    final notes = await readAllNotes();
    final settings = await readSettings();
    return const JsonEncoder.withIndent('  ').convert({
      'format': 'atelier.backup.v1',
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings,
      'notes': notes,
    });
  }

  Future<int> importBundle(String raw) async {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final notes = (map['notes'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    for (final note in notes) {
      final id = note['id'] as String?;
      if (id == null) continue;
      await writeNote(id, note);
    }
    if (map['settings'] is Map<String, dynamic>) {
      await writeSettings(map['settings'] as Map<String, dynamic>);
    }
    return notes.length;
  }
}
