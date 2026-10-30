import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../features/notes/domain/note_models.dart';
import '../../features/notes/domain/note_themes.dart';
import 'home_widget_gateway.dart';

HomeWidgetGateway createHomeWidgetGateway() => IoHomeWidgetGateway();

class IoHomeWidgetGateway implements HomeWidgetGateway {
  static const _channel = MethodChannel('atelier/home_widget');

  final _opens = StreamController<String>.broadcast();

  IoHomeWidgetGateway() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'opened' && call.arguments is String) {
        _opens.add(call.arguments as String);
      }
    });
  }

  @override
  HomeWidgetCapability get capability {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => HomeWidgetCapability.pinAppWidget,
      TargetPlatform.iOS => HomeWidgetCapability.publishSnapshot,
      _ => HomeWidgetCapability.unsupported,
    };
  }

  @override
  Future<HomeWidgetResult> placeNote(Note note) async {
    await publish(note);
    switch (capability) {
      case HomeWidgetCapability.pinAppWidget:
        try {
          await _channel.invokeMethod('pin');
          return const HomeWidgetResult(
            ok: true,
            capability: HomeWidgetCapability.pinAppWidget,
            message:
                'If your launcher supports it, pin the U-write note widget. Otherwise add it from the widget picker.',
          );
        } on PlatformException catch (e) {
          return HomeWidgetResult(
            ok: false,
            capability: capability,
            message: e.message ?? 'Could not pin the widget.',
          );
        } on MissingPluginException {
          return const HomeWidgetResult(
            ok: false,
            message: 'Home screen widgets are not available on this device.',
          );
        }
      case HomeWidgetCapability.publishSnapshot:
        return const HomeWidgetResult(
          ok: true,
          capability: HomeWidgetCapability.publishSnapshot,
          message:
              'iOS does not allow apps to place widgets automatically. A WidgetKit extension can be added when Xcode is available. For now, add widgets from the Home Screen gallery once that extension ships.',
        );
      case HomeWidgetCapability.unsupported:
        return const HomeWidgetResult(
          ok: false,
          message: 'Home screen widgets are not available on this device.',
        );
    }
  }

  @override
  Future<void> publish(Note note) async {
    if (capability == HomeWidgetCapability.unsupported) return;
    try {
      await _channel.invokeMethod('save', {
        'note_id': note.id,
        'title': note.previewTitle,
        'body': note.body.trim().isEmpty ? 'Open to keep writing' : note.body.trim(),
        'ink': _inkFor(note),
        'paper': _paperFor(note),
        'muted': NoteThemes.byId(note.themeId).muted.toARGB32(),
        'style': note.style.name,
        'tilt': (note.id.hashCode % 7) - 3,
      });
    } on MissingPluginException {
      // Desktop/web IO builds without the Android channel.
    }
  }

  int _inkFor(Note note) {
    return note.primaryText?.color ?? NoteThemes.byId(note.themeId).ink.toARGB32();
  }

  int _paperFor(Note note) {
    return NoteThemes.byId(note.themeId).background.toARGB32();
  }

  @override
  Future<String?> consumeLaunchNoteId() async {
    if (capability == HomeWidgetCapability.unsupported) return null;
    try {
      return await _channel.invokeMethod<String>('consumeLaunch');
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<String> get noteOpens => _opens.stream;
}
