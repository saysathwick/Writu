import '../../../core/persistence/local_store.dart';
import '../domain/note_models.dart';

class NoteRepository {
  NoteRepository(this._store);

  final LocalStore _store;

  Future<List<Note>> loadAll() async {
    final maps = await _store.readAllNotes();
    final notes = <Note>[];
    for (final map in maps) {
      try {
        notes.add(Note.fromJson(map));
      } catch (_) {
        // Ignore malformed records.
      }
    }
    notes.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return notes;
  }

  Future<void> save(Note note) {
    note.updatedAt = DateTime.now();
    return _store.writeNote(note.id, note.toJson());
  }

  Future<void> delete(String id) => _store.deleteNote(id);

  Future<String> exportAll() => _store.exportBundle();

  Future<int> importAll(String raw) => _store.importBundle(raw);

  Future<int> storageBytes() => _store.estimatedBytes();
}

class SettingsRepository {
  SettingsRepository(this._store);

  final LocalStore _store;

  Future<AppSettings> load() async {
    final map = await _store.readSettings();
    if (map == null) return AppSettings();
    try {
      return AppSettings.fromJson(map);
    } catch (_) {
      return AppSettings();
    }
  }

  Future<void> save(AppSettings settings) {
    return _store.writeSettings(settings.toJson());
  }
}
