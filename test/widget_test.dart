import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:atelier/core/persistence/local_store.dart';
import 'package:atelier/features/notes/data/note_repository.dart';
import 'package:atelier/features/notes/domain/note_models.dart';
import 'package:atelier/features/notes/domain/note_styles.dart';

void main() {
  test('local store and repository persist a note', () async {
    final dir = await Directory.systemTemp.createTemp('atelier-binding');
    addTearDown(() => dir.delete(recursive: true));
    final store = await LocalStore.open(root: dir);
    final repo = NoteRepository(store);
    final note = NoteStyles.create(id: 'w1', intent: CreateIntent.blank);
    note.primaryText?.content = 'A quiet page';
    await repo.save(note);

    final loaded = await repo.loadAll();
    expect(loaded.single.body, 'A quiet page');
    expect(loaded.single.previewTitle, 'A quiet page');
  });
}
