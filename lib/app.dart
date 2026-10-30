import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/notes/domain/note_models.dart';
import 'features/notes/state/notes_controller.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/editor/editor_screen.dart';

class UwriteApp extends ConsumerStatefulWidget {
  const UwriteApp({super.key});

  @override
  ConsumerState<UwriteApp> createState() => _UwriteAppState();
}

class _UwriteAppState extends ConsumerState<UwriteApp> {
  final _nav = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _listenWidgetLaunches());
  }

  Future<void> _listenWidgetLaunches() async {
    final gateway = ref.read(homeWidgetGatewayProvider);
    final initial = await gateway.consumeLaunchNoteId();
    if (initial != null) _openNote(initial);
    gateway.noteOpens.listen(_openNote);
  }

  void _openNote(String id) {
    final note = ref.read(notesProvider.notifier).byId(id);
    final nav = _nav.currentState;
    if (note == null || nav == null) return;
    nav.push(MaterialPageRoute(builder: (_) => EditorScreen(existing: note)));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      navigatorKey: _nav,
      title: 'U-write',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (settings.themeMode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      },
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            disableAnimations: mq.disableAnimations || settings.reduceMotion,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: settings.hasCompletedOnboarding
          ? const HomeScreen()
          : const OnboardingScreen(),
    );
  }
}
