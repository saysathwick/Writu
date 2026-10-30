import '../../features/notes/domain/note_models.dart';
import 'home_widget_gateway_stub.dart'
    if (dart.library.io) 'home_widget_io.dart';

enum HomeWidgetCapability {
  /// Android 8+ can request a pin of a real app widget.
  pinAppWidget,

  /// iOS WidgetKit: the user adds the widget from the gallery.
  /// The app can publish data via App Groups but cannot place it.
  publishSnapshot,

  unsupported,
}

class HomeWidgetResult {
  const HomeWidgetResult({
    required this.ok,
    required this.message,
    this.capability = HomeWidgetCapability.unsupported,
  });

  final bool ok;
  final String message;
  final HomeWidgetCapability capability;
}

abstract class HomeWidgetGateway {
  HomeWidgetCapability get capability;

  Future<HomeWidgetResult> placeNote(Note note);

  Future<void> publish(Note note);

  Future<String?> consumeLaunchNoteId();

  Stream<String> get noteOpens;

  static HomeWidgetGateway create() => createHomeWidgetGateway();
}
