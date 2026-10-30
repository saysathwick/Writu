import '../../features/notes/domain/note_models.dart';
import 'home_widget_gateway.dart';

HomeWidgetGateway createHomeWidgetGateway() => StubHomeWidgetGateway();

class StubHomeWidgetGateway implements HomeWidgetGateway {
  @override
  HomeWidgetCapability get capability => HomeWidgetCapability.unsupported;

  @override
  Future<HomeWidgetResult> placeNote(Note note) async {
    return const HomeWidgetResult(
      ok: false,
      message:
          'Home screen widgets are available on Android phones. This platform cannot pin a real widget.',
    );
  }

  @override
  Future<void> publish(Note note) async {}

  @override
  Future<String?> consumeLaunchNoteId() async => null;

  @override
  Stream<String> get noteOpens => const Stream.empty();
}
