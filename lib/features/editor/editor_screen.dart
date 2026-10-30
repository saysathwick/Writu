import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../core/ads/ad_service.dart';
import '../../core/media/note_image.dart';
import '../../core/ocr/image_text_reader.dart';
import '../../core/speech/note_speech.dart';
import '../../core/speech/voice_sheet.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/motion.dart';
import '../home/widgets/note_actions_sheet.dart';
import '../notes/domain/note_models.dart';
import '../notes/domain/note_styles.dart';
import '../notes/domain/note_themes.dart';
import '../notes/presentation/note_surface.dart';
import '../notes/state/notes_controller.dart';
import 'widgets/drawing_toolbar.dart';
import 'widgets/style_picker.dart';
import 'widgets/theme_browser.dart';
import 'widgets/typography_panel.dart';

enum EditorMode { text, draw }

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({
    super.key,
    this.existing,
    this.intent = CreateIntent.blank,
  });

  final Note? existing;
  final CreateIntent intent;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late Note _note;
  late TextEditingController _controller;
  late FocusNode _focus;
  EditorMode _mode = EditorMode.text;
  bool _showStylePrompt = false;
  bool _dirty = false;
  bool _savedOnce = false;
  bool _readingPhoto = false;
  bool _listening = false;
  final _speech = NoteSpeech();

  DrawTool _tool = DrawTool.pen;
  Color _drawColor = const Color(0xFF1C1410);
  double _thickness = 3.5;
  Stroke? _current;
  final List<List<Stroke>> _undo = [];
  final List<List<Stroke>> _redo = [];

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _note = widget.existing ??
        NoteStyles.create(
          id: const Uuid().v4(),
          intent: widget.intent,
          style: settings.defaultStyle,
          theme: settings.defaultTheme,
          fontId: settings.defaultFontId,
        );
    if (widget.intent == CreateIntent.drawing) {
      _mode = EditorMode.draw;
    }
    if (widget.intent == CreateIntent.styled && widget.existing == null) {
      _showStylePrompt = true;
    }
    _controller = TextEditingController(text: _note.body);
    _focus = FocusNode();
    _drawColor = argbToColor(_note.primaryText?.color ?? colorToArgb(NoteThemes.byId(_note.themeId).ink));
    if (widget.existing == null && widget.intent != CreateIntent.drawing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _mode == EditorMode.text) _focus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  TextElement get _text => _note.primaryText!;

  bool get _hasImages => _note.elements.whereType<ImageElement>().isNotEmpty;

  bool get _isBlankDraft =>
      _controller.text.trim().isEmpty &&
      _note.drawingLayer.strokes.isEmpty &&
      !_hasImages;

  Future<void> _persist({bool popAfter = false}) async {
    _text.content = _controller.text;
    _note.title = _deriveTitle(_controller.text);
    await ref.read(notesProvider.notifier).upsert(_note);
    _dirty = false;
    _savedOnce = true;
    if (popAfter && mounted) Navigator.of(context).pop();
  }

  String _deriveTitle(String body) {
    final line = body.trim().split('\n').firstWhere(
          (s) => s.trim().isNotEmpty,
          orElse: () => '',
        );
    return line.length > 42 ? line.substring(0, 42) : line;
  }

  void _onTextChanged(String value) {
    _text.content = value;
    _dirty = true;
    final shouldPrompt = widget.existing == null &&
        !_showStylePrompt &&
        value.trim().length >= 12 &&
        widget.intent != CreateIntent.handwritten &&
        widget.intent != CreateIntent.drawing;
    if (shouldPrompt) {
      setState(() => _showStylePrompt = true);
    } else {
      setState(() {});
    }
  }

  void _applyStyle(StylePreset preset) {
    preset.applyTo(_note);
    _drawColor = argbToColor(_text.color);
    _dirty = true;
    setState(() => _showStylePrompt = false);
    HapticFeedback.selectionClick();
    if (_savedOnce || widget.existing != null) {
      _persist();
    }
  }

  void _startStroke(Offset p) {
    if (_tool == DrawTool.eraser) {
      _eraseAt(p);
      return;
    }
    _current = Stroke(
      id: const Uuid().v4(),
      tool: _tool,
      color: colorToArgb(_drawColor),
      width: _widthForTool(),
      opacity: _opacityForTool(),
      points: [StrokePoint(p.dx, p.dy)],
    );
    setState(() {});
  }

  void _updateStroke(Offset p) {
    if (_tool == DrawTool.eraser) {
      _eraseAt(p);
      return;
    }
    final current = _current;
    if (current == null) return;
    current.points.add(StrokePoint(p.dx, p.dy));
    setState(() {});
  }

  void _endStroke() {
    final current = _current;
    if (current == null) return;
    final layer = _note.drawingLayer;
    _undo.add(List.of(layer.strokes));
    _redo.clear();
    layer.strokes.add(current);
    _current = null;
    _dirty = true;
    setState(() {});
  }

  void _eraseAt(Offset p) {
    final layer = _note.drawingLayer;
    final next = layer.strokes.where((s) {
      return !s.points.any((pt) => (pt.offset - p).distance <= _thickness + s.width);
    }).toList();
    if (next.length != layer.strokes.length) {
      _undo.add(List.of(layer.strokes));
      _redo.clear();
      layer.strokes
        ..clear()
        ..addAll(next);
      _dirty = true;
      setState(() {});
    }
  }

  double _widthForTool() {
    return switch (_tool) {
      DrawTool.pen => _thickness,
      DrawTool.pencil => _thickness * 0.8,
      DrawTool.marker => _thickness * 2.1,
      DrawTool.highlighter => _thickness * 3.2,
      DrawTool.eraser => _thickness * 2,
    };
  }

  double _opacityForTool() {
    return switch (_tool) {
      DrawTool.pencil => 0.72,
      DrawTool.highlighter => 0.35,
      _ => 1,
    };
  }

  void _undoStroke() {
    if (_undo.isEmpty) return;
    final layer = _note.drawingLayer;
    _redo.add(List.of(layer.strokes));
    final prev = _undo.removeLast();
    layer.strokes
      ..clear()
      ..addAll(prev);
    _dirty = true;
    setState(() {});
  }

  void _redoStroke() {
    if (_redo.isEmpty) return;
    final layer = _note.drawingLayer;
    _undo.add(List.of(layer.strokes));
    final next = _redo.removeLast();
    layer.strokes
      ..clear()
      ..addAll(next);
    _dirty = true;
    setState(() {});
  }

  void _placeImage(String path) {
    final count = _note.elements.whereType<ImageElement>().length;
    _note.elements.add(
      ImageElement(
        id: const Uuid().v4(),
        assetPath: path,
        x: 40 + (count % 3) * 12,
        y: 200 + count * 24,
        width: 280,
        height: 190,
      ),
    );
    _dirty = true;
    setState(() {});
  }

  void _removeImage(String id) {
    _note.elements.removeWhere((e) => e is ImageElement && e.id == id);
    _dirty = true;
    setState(() {});
  }

  void _setBody(String next) {
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    _onTextChanged(next);
  }

  Future<void> _toggleSpeak() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    _focus.unfocus();
    setState(() => _listening = true);
    await _speech.start(
      existingText: _controller.text,
      onLive: (text) {
        if (!mounted) return;
        _setBody(text);
      },
      onError: (message) {
        if (!mounted) return;
        setState(() => _listening = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      },
    );
  }

  Future<void> _fromRecording() async {
    if (_listening) await _speech.stop();
    if (!mounted) return;
    setState(() => _listening = false);
    final text = await showVoiceSheet(
      context,
      mode: VoiceSheetMode.recording,
      existingText: _controller.text,
    );
    if (text == null || !mounted) return;
    _setBody(text);
  }

  Future<void> _addPhoto() async {
    final picked = await pickNoteImage(
      context,
      ref.read(noteImageStoreProvider),
      intent: ImagePickIntent.attach,
    );
    if (picked == null || !mounted) return;
    _placeImage(picked.path);
  }

  Future<void> _readTextFromPhoto({bool alsoAttach = false}) async {
    final reader = ImageTextReader();
    if (!reader.isSupported) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reading text from photos works on Android and iPhone.'),
        ),
      );
      return;
    }
    final picked = await pickNoteImage(
      context,
      ref.read(noteImageStoreProvider),
      intent: ImagePickIntent.readText,
    );
    if (picked == null || !mounted) return;
    setState(() => _readingPhoto = true);
    try {
      final scanned = await reader.read(picked.path);
      if (!mounted) return;
      if (scanned.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No words found in that photo.')),
        );
      } else {
        final existing = _controller.text.trim();
        final next = existing.isEmpty ? scanned : '$existing\n\n$scanned';
        _controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
        _onTextChanged(next);
      }
      if (alsoAttach) _placeImage(picked.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read text from that photo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _readingPhoto = false);
    }
  }

  Future<void> _close() async {
    if (_isBlankDraft && !_savedOnce) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final navigator = Navigator.of(context);
    final ads = ref.read(adServiceProvider);
    final isNew = widget.existing == null;
    if (_dirty || !_savedOnce) {
      await _persist();
    }
    if (!navigator.mounted) return;
    navigator.pop();
    final placement = isNew ? AdPlacement.afterCreate : AdPlacement.afterSave;
    if (navigator.mounted) {
      await ads.maybeShowInterstitial(placement, context: navigator.context);
    }
  }

  Future<void> _share() async {
    _text.content = _controller.text;
    await SharePlus.instance.share(
      ShareParams(text: '${_note.previewTitle}\n\n${_note.body}'),
    );
    if (!mounted) return;
    await ref.read(adServiceProvider).maybeShowInterstitial(
          AdPlacement.afterShare,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final spec = NoteThemes.byId(_note.themeId);
    final bg = Color.lerp(spec.background, AppColors.paper, 0.35)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _close();
      },
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                note: _note,
                onClose: _close,
                onShare: _share,
                onMore: () => showNoteActions(
                  context,
                  ref,
                  _note,
                  onChanged: () => setState(() {}),
                ),
                onFavorite: () async {
                  _note.isFavorite = !_note.isFavorite;
                  await _persist();
                  setState(() {});
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: GestureDetector(
                    onLongPress: _mode == EditorMode.text
                        ? () {
                            HapticFeedback.mediumImpact();
                            showStylePeek(
                              context,
                              note: _note,
                              liveText: _controller.text,
                              onSelect: _applyStyle,
                            );
                          }
                        : null,
                    child: Hero(
                      tag: 'note-${_note.id}',
                      child: Material(
                        color: Colors.transparent,
                        elevation: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 28,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              AnimatedSwitcher(
                                duration: Motion.of(context, Motion.med),
                                child: NoteSurface(
                                  key: ValueKey('${_note.themeId}-${_text.fontId}'),
                                  note: _note,
                                  interactive: true,
                                  drawMode: _mode == EditorMode.draw,
                                  textController: _controller,
                                  focusNode: _focus,
                                  onTextChanged: _onTextChanged,
                                  currentStroke: _current,
                                  onDrawStart: _startStroke,
                                  onDrawUpdate: _updateStroke,
                                  onDrawEnd: _endStroke,
                                  onRemoveImage: _removeImage,
                                ),
                              ),
                              if (_mode == EditorMode.text)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: 36,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onLongPress: () {
                                      HapticFeedback.mediumImpact();
                                      showStylePeek(
                                        context,
                                        note: _note,
                                        liveText: _controller.text,
                                        onSelect: _applyStyle,
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_showStylePrompt)
                StylePicker(
                  note: _note,
                  liveText: _controller.text,
                  onSelect: _applyStyle,
                  onDismiss: () => setState(() => _showStylePrompt = false),
                ),
              if (_listening)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Material(
                    color: AppColors.copper.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    child: ListTile(
                      leading: const Icon(Icons.mic_rounded, color: AppColors.copper),
                      title: Text(
                        'Listening… tap Speak to stop',
                        style: GoogleFonts.figtree(fontWeight: FontWeight.w600),
                      ),
                      trailing: TextButton(
                        onPressed: _toggleSpeak,
                        child: const Text('Stop'),
                      ),
                    ),
                  ),
                ),
              if (_mode == EditorMode.draw)
                DrawingToolbar(
                  tool: _tool,
                  color: _drawColor,
                  thickness: _thickness,
                  canUndo: _undo.isNotEmpty,
                  canRedo: _redo.isNotEmpty,
                  onTool: (t) => setState(() => _tool = t),
                  onColor: (c) => setState(() => _drawColor = c),
                  onThickness: (v) => setState(() => _thickness = v),
                  onUndo: _undoStroke,
                  onRedo: _redoStroke,
                ),
              _BottomBar(
                mode: _mode,
                reading: _readingPhoto,
                listening: _listening,
                onMode: (m) {
                  setState(() => _mode = m);
                  if (m == EditorMode.text) {
                    _focus.requestFocus();
                  } else {
                    _focus.unfocus();
                  }
                },
                onSpeak: _toggleSpeak,
                onRecord: _fromRecording,
                onPhoto: _addPhoto,
                onScan: () => _readTextFromPhoto(),
                onType: () => showTypographyPanel(
                  context,
                  text: _text,
                  onChanged: () {
                    _dirty = true;
                    setState(() {});
                  },
                ),
                onTheme: () => showThemeBrowser(
                  context,
                  selected: _note.themeId,
                  onSelect: (id) {
                    _note.themeId = id;
                    _text.color = colorToArgb(NoteThemes.byId(id).ink);
                    _drawColor = argbToColor(_text.color);
                    _dirty = true;
                    setState(() {});
                  },
                ),
                onStyle: () {
                  setState(() => _showStylePrompt = !_showStylePrompt);
                },
                onHomeScreen: () async {
                  final gateway = ref.read(homeWidgetGatewayProvider);
                  _note.homeWidgetEnabled = true;
                  await _persist();
                  if (!context.mounted) return;
                  final result = await gateway.placeNote(_note);
                  if (!context.mounted) return;
                  await showHomeWidgetResult(context, result);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.note,
    required this.onClose,
    required this.onShare,
    required this.onMore,
    required this.onFavorite,
  });

  final Note note;
  final VoidCallback onClose;
  final VoidCallback onShare;
  final VoidCallback onMore;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
          ),
          Expanded(
            child: Text(
              note.previewTitle == 'Untitled' ? 'New note' : note.previewTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.fraunces(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            tooltip: note.isFavorite ? 'Unfavorite' : 'Favorite',
            onPressed: onFavorite,
            icon: Icon(
              note.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: note.isFavorite ? AppColors.blush : null,
            ),
          ),
          IconButton(
            tooltip: 'Share',
            onPressed: onShare,
            icon: const Icon(Icons.ios_share_rounded),
          ),
          IconButton(
            tooltip: 'More',
            onPressed: onMore,
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.mode,
    required this.reading,
    required this.listening,
    required this.onMode,
    required this.onSpeak,
    required this.onRecord,
    required this.onPhoto,
    required this.onScan,
    required this.onType,
    required this.onTheme,
    required this.onStyle,
    required this.onHomeScreen,
  });

  final EditorMode mode;
  final bool reading;
  final bool listening;
  final ValueChanged<EditorMode> onMode;
  final VoidCallback onSpeak;
  final VoidCallback onRecord;
  final VoidCallback onPhoto;
  final VoidCallback onScan;
  final VoidCallback onType;
  final VoidCallback onTheme;
  final VoidCallback onStyle;
  final VoidCallback onHomeScreen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Seg(
              selected: mode == EditorMode.text,
              icon: Icons.text_fields_rounded,
              label: 'Write',
              onTap: () => onMode(EditorMode.text),
            ),
            const SizedBox(width: 6),
            _Seg(
              selected: mode == EditorMode.draw,
              icon: Icons.brush_rounded,
              label: 'Draw',
              onTap: () => onMode(EditorMode.draw),
            ),
            const SizedBox(width: 8),
            _Ghost(
              icon: listening ? Icons.mic_rounded : Icons.mic_none_rounded,
              label: 'Speak',
              onTap: reading ? null : onSpeak,
            ),
            _Ghost(
              icon: Icons.graphic_eq_rounded,
              label: 'Record',
              onTap: reading ? null : onRecord,
            ),
            _Ghost(
              icon: Icons.add_photo_alternate_outlined,
              label: 'Photo',
              onTap: reading ? null : onPhoto,
            ),
            _Ghost(
              icon: reading
                  ? Icons.hourglass_top_rounded
                  : Icons.document_scanner_outlined,
              label: 'Scan',
              onTap: reading ? null : onScan,
            ),
            _Ghost(icon: Icons.font_download_rounded, label: 'Type', onTap: onType),
            _Ghost(icon: Icons.palette_outlined, label: 'Theme', onTap: onTheme),
            _Ghost(icon: Icons.auto_awesome_outlined, label: 'Feel', onTap: onStyle),
            _Ghost(icon: Icons.add_to_home_screen_rounded, label: 'Home', onTap: onHomeScreen),
          ],
        ),
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Motion.of(context, Motion.fast),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? ink.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: ink),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.figtree(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ghost extends StatelessWidget {
  const _Ghost({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      onPressed: onTap,
      icon: Icon(icon, size: 22),
    );
  }
}
