import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:atelier/core/persistence/local_store.dart';
import 'package:atelier/core/speech/note_speech.dart';
import 'package:atelier/features/notes/data/note_repository.dart';
import 'package:atelier/features/notes/domain/note_models.dart';
import 'package:atelier/features/notes/domain/note_styles.dart';

void main() {
  test('note round-trips through JSON with text and drawing', () {
    final note = NoteStyles.create(id: 'n1', intent: CreateIntent.handwritten);
    note.primaryText?.content = 'Buy flowers';
    note.drawingLayer.strokes.add(
      Stroke(
        id: 's1',
        tool: DrawTool.pen,
        color: 0xFF1C1410,
        width: 3,
        points: const [StrokePoint(1, 2), StrokePoint(3, 4)],
      ),
    );
    note.tags = ['home'];
    note.isFavorite = true;

    final restored = Note.fromJson(
      jsonDecode(jsonEncode(note.toJson())) as Map<String, dynamic>,
    );

    expect(restored.body, 'Buy flowers');
    expect(restored.themeId, NoteThemeId.softYellow);
    expect(restored.drawingLayer.strokes.single.points.first.x, 1);
    expect(restored.tags, ['home']);
    expect(restored.isFavorite, isTrue);
    expect(restored.matchesQuery('flowers'), isTrue);
    expect(restored.matchesQuery('home'), isTrue);
  });

  test('image elements persist their path and size', () {
    final note = NoteStyles.create(id: 'n-img', intent: CreateIntent.blank);
    note.elements.add(
      ImageElement(
        id: 'img-1',
        assetPath: '/tmp/atelier/photo.jpg',
        x: 40,
        y: 80,
        width: 280,
        height: 190,
      ),
    );
    final restored = Note.fromJson(
      jsonDecode(jsonEncode(note.toJson())) as Map<String, dynamic>,
    );
    final image = restored.elements.whereType<ImageElement>().single;
    expect(image.assetPath, '/tmp/atelier/photo.jpg');
    expect(image.width, 280);
    expect(image.height, 190);
  });

  test('spoken words append to existing note text', () {
    expect(mergeSpoken('', 'hello'), 'hello');
    expect(mergeSpoken('Buy milk', 'and bread'), 'Buy milk and bread');
    expect(mergeSpoken('Line\n', 'next'), 'Line next');
  });

  test('style presets transform typography and theme', () {
    final note = NoteStyles.create(id: 'n2', intent: CreateIntent.blank);
    NoteStyles.byKind(NoteStyleKind.typewriter).applyTo(note);
    expect(note.style, NoteStyleKind.typewriter);
    expect(note.primaryText?.fontId, 'specialElite');
    expect(note.themeId, NoteThemeId.vintage);
  });

  test('repository persists notes on disk', () async {
    final dir = await Directory.systemTemp.createTemp('atelier-notes');
    addTearDown(() => dir.delete(recursive: true));
    final store = await LocalStore.open(root: dir);
    final repo = NoteRepository(store);
    final note = NoteStyles.create(id: 'persist-1', intent: CreateIntent.quick);
    note.primaryText?.content = 'Keep this';
    await repo.save(note);

    final loaded = await repo.loadAll();
    expect(loaded, hasLength(1));
    expect(loaded.single.body, 'Keep this');

    final bundle = await repo.exportAll();
    expect(bundle, contains('atelier.backup.v1'));
  });
}
