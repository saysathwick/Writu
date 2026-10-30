import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ads/ad_service.dart';
import '../../../core/media/note_image.dart';
import '../../../core/persistence/local_store.dart';
import '../../../core/platform/home_widget_gateway.dart';
import '../../../core/premium/entitlements.dart';
import '../data/note_repository.dart';
import '../domain/note_models.dart';

final localStoreProvider = Provider<LocalStore>((ref) {
  throw StateError('LocalStore must be overridden in main()');
});

final initialSettingsProvider = Provider<AppSettings>((ref) => AppSettings());

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(ref.watch(localStoreProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(localStoreProvider));
});

final entitlementsProvider = Provider<Entitlements>((ref) {
  return LocalEntitlements();
});

final adServiceProvider = Provider<MockAdService>((ref) {
  final settings = ref.watch(settingsProvider);
  final premium = ref.watch(entitlementsProvider);
  return MockAdService(adsEnabled: settings.adsEnabled && premium.adsEnabled);
});

final homeWidgetGatewayProvider = Provider<HomeWidgetGateway>((ref) {
  return HomeWidgetGateway.create();
});

final noteImageStoreProvider = Provider<NoteImageStore>((ref) {
  return NoteImageStore(ref.watch(localStoreProvider));
});

class NotesState {
  const NotesState({
    required this.notes,
    this.loading = false,
    this.filter = NoteFilter.all,
    this.viewMode = HomeViewMode.grid,
    this.selectedTag,
    this.error,
  });

  final List<Note> notes;
  final bool loading;
  final NoteFilter filter;
  final HomeViewMode viewMode;
  final String? selectedTag;
  final String? error;

  List<Note> get visible {
    Iterable<Note> list = notes;
    switch (filter) {
      case NoteFilter.all:
        list = list.where((n) => !n.isArchived);
      case NoteFilter.pinned:
        list = list.where((n) => n.isPinned && !n.isArchived);
      case NoteFilter.favorites:
        list = list.where((n) => n.isFavorite && !n.isArchived);
      case NoteFilter.archived:
        list = list.where((n) => n.isArchived);
    }
    if (selectedTag != null) {
      list = list.where((n) => n.tags.contains(selectedTag));
    }
    return list.toList();
  }

  List<String> get allTags {
    final tags = <String>{};
    for (final note in notes) {
      tags.addAll(note.tags);
    }
    final sorted = tags.toList()..sort();
    return sorted;
  }

  NotesState copyWith({
    List<Note>? notes,
    bool? loading,
    NoteFilter? filter,
    HomeViewMode? viewMode,
    String? selectedTag,
    String? error,
    bool clearTag = false,
    bool clearError = false,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      loading: loading ?? this.loading,
      filter: filter ?? this.filter,
      viewMode: viewMode ?? this.viewMode,
      selectedTag: clearTag ? null : selectedTag ?? this.selectedTag,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class NotesNotifier extends Notifier<NotesState> {
  NoteRepository get _repo => ref.read(noteRepositoryProvider);

  @override
  NotesState build() {
    Future.microtask(reload);
    return const NotesState(notes: [], loading: true);
  }

  Future<void> reload() async {
    try {
      final notes = await _repo.loadAll();
      final settings = ref.read(settingsProvider);
      state = state.copyWith(
        notes: notes,
        loading: false,
        viewMode: settings.defaultView,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Could not load notes.');
    }
  }

  Note? byId(String id) {
    return state.notes.where((n) => n.id == id).firstOrNull;
  }

  Future<void> upsert(Note note) async {
    await _repo.save(note);
    final next = [...state.notes];
    final index = next.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      next[index] = note;
    } else {
      next.insert(0, note);
    }
    next.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    state = state.copyWith(notes: next);
    if (note.homeWidgetEnabled) {
      await ref.read(homeWidgetGatewayProvider).publish(note);
    }
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    state = state.copyWith(
      notes: state.notes.where((n) => n.id != id).toList(),
    );
  }

  Future<Note> duplicate(Note note) async {
    final copy = note.duplicate(
      'note-${DateTime.now().microsecondsSinceEpoch}',
    );
    await upsert(copy);
    return copy;
  }

  void setFilter(NoteFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setViewMode(HomeViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void setTag(String? tag) {
    state = state.copyWith(selectedTag: tag, clearTag: tag == null);
  }

  List<Note> search(String query) {
    return state.notes
        .where((n) => !n.isArchived && n.matchesQuery(query))
        .toList();
  }
}

final notesProvider = NotifierProvider<NotesNotifier, NotesState>(
  NotesNotifier.new,
);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(initialSettingsProvider);

  Future<void> update(AppSettings settings) async {
    state = settings;
    await ref.read(settingsRepositoryProvider).save(settings);
  }

  Future<void> patch({
    AppThemeMode? themeMode,
    NoteStyleKind? defaultStyle,
    String? defaultFontId,
    NoteThemeId? defaultTheme,
    HomeViewMode? defaultView,
    bool? hasCompletedOnboarding,
    bool? reduceMotion,
    bool? adsEnabled,
  }) {
    return update(
      state.copyWith(
        themeMode: themeMode,
        defaultStyle: defaultStyle,
        defaultFontId: defaultFontId,
        defaultTheme: defaultTheme,
        defaultView: defaultView,
        hasCompletedOnboarding: hasCompletedOnboarding,
        reduceMotion: reduceMotion,
        adsEnabled: adsEnabled,
      ),
    );
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
