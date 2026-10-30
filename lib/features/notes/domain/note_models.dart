import 'package:flutter/material.dart';

enum ElementKind { text, drawing, image, shape, sticker }

enum DrawTool { pen, pencil, marker, highlighter, eraser }

enum HomeViewMode { grid, list, large }

enum AppThemeMode { light, dark, system }

enum CreateIntent { blank, styled, handwritten, drawing, quick }

enum NoteStyleKind {
  handwritten,
  journal,
  editorial,
  typewriter,
  playful,
  minimal,
  dark,
  colorful,
  vintage,
  artistic,
}

enum NoteThemeId {
  whitePaper,
  creamPaper,
  gridPaper,
  ruledPaper,
  notebook,
  tornPaper,
  kraftPaper,
  softYellow,
  pink,
  blue,
  green,
  lavender,
  orange,
  black,
  paint,
  grain,
  gradient,
  doodle,
  vintage,
  newspaper,
  film,
  polaroid,
}

enum FontCategory { handwritten, editorial, typewriter, modern, playful, classic }

enum TextAlignKind { left, center, right, justify }

enum NoteFilter { all, pinned, favorites, archived }

int colorToArgb(Color color) => color.toARGB32();

Color argbToColor(int value) => Color(value);

FontWeight fontWeightFrom(int weight) {
  final index = ((weight / 100).round().clamp(1, 9)) - 1;
  return FontWeight.values[index];
}

int fontWeightToInt(FontWeight weight) => weight.value;

TextAlign textAlignFrom(TextAlignKind kind) {
  return switch (kind) {
    TextAlignKind.left => TextAlign.left,
    TextAlignKind.center => TextAlign.center,
    TextAlignKind.right => TextAlign.right,
    TextAlignKind.justify => TextAlign.justify,
  };
}

class StrokePoint {
  const StrokePoint(this.x, this.y, [this.pressure = 1]);

  final double x;
  final double y;
  final double pressure;

  Offset get offset => Offset(x, y);

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'p': pressure};

  factory StrokePoint.fromJson(Map<String, dynamic> json) {
    return StrokePoint(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
      (json['p'] as num?)?.toDouble() ?? 1,
    );
  }
}

class Stroke {
  Stroke({
    required this.id,
    required this.tool,
    required this.color,
    required this.width,
    required this.points,
    this.opacity = 1,
  });

  final String id;
  final DrawTool tool;
  final int color;
  final double width;
  final List<StrokePoint> points;
  final double opacity;

  Stroke copyWith({List<StrokePoint>? points}) {
    return Stroke(
      id: id,
      tool: tool,
      color: color,
      width: width,
      points: points ?? this.points,
      opacity: opacity,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tool': tool.name,
        'color': color,
        'width': width,
        'opacity': opacity,
        'points': points.map((p) => p.toJson()).toList(),
      };

  factory Stroke.fromJson(Map<String, dynamic> json) {
    return Stroke(
      id: json['id'] as String,
      tool: DrawTool.values.byName(json['tool'] as String),
      color: json['color'] as int,
      width: (json['width'] as num).toDouble(),
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
      points: (json['points'] as List<dynamic>)
          .map((e) => StrokePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

sealed class NoteElement {
  NoteElement({
    required this.id,
    required this.kind,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0,
    this.zIndex = 0,
  });

  final String id;
  final ElementKind kind;
  double x;
  double y;
  double width;
  double height;
  double rotation;
  int zIndex;

  Map<String, dynamic> toJson();

  factory NoteElement.fromJson(Map<String, dynamic> json) {
    final kind = ElementKind.values.byName(json['kind'] as String);
    return switch (kind) {
      ElementKind.text => TextElement.fromJson(json),
      ElementKind.drawing => DrawingElement.fromJson(json),
      ElementKind.image => ImageElement.fromJson(json),
      ElementKind.shape => ShapeElement.fromJson(json),
      ElementKind.sticker => StickerElement.fromJson(json),
    };
  }
}

class TextElement extends NoteElement {
  TextElement({
    required super.id,
    required this.content,
    required this.fontId,
    required this.fontSize,
    required this.color,
    super.x = 0,
    super.y = 0,
    super.width = 400,
    super.height = 560,
    super.rotation,
    super.zIndex,
    this.fontWeight = 400,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.letterSpacing = 0,
    this.lineHeight = 1.35,
    this.align = TextAlignKind.left,
  }) : super(kind: ElementKind.text);

  String content;
  String fontId;
  double fontSize;
  int fontWeight;
  bool italic;
  bool underline;
  bool strikethrough;
  double letterSpacing;
  double lineHeight;
  TextAlignKind align;
  int color;

  TextElement copyWith({
    String? content,
    String? fontId,
    double? fontSize,
    int? fontWeight,
    bool? italic,
    bool? underline,
    bool? strikethrough,
    double? letterSpacing,
    double? lineHeight,
    TextAlignKind? align,
    int? color,
  }) {
    return TextElement(
      id: id,
      content: content ?? this.content,
      fontId: fontId ?? this.fontId,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      align: align ?? this.align,
      color: color ?? this.color,
      x: x,
      y: y,
      width: width,
      height: height,
      rotation: rotation,
      zIndex: zIndex,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'rotation': rotation,
        'zIndex': zIndex,
        'content': content,
        'fontId': fontId,
        'fontSize': fontSize,
        'fontWeight': fontWeight,
        'italic': italic,
        'underline': underline,
        'strikethrough': strikethrough,
        'letterSpacing': letterSpacing,
        'lineHeight': lineHeight,
        'align': align.name,
        'color': color,
      };

  factory TextElement.fromJson(Map<String, dynamic> json) {
    return TextElement(
      id: json['id'] as String,
      content: json['content'] as String? ?? '',
      fontId: json['fontId'] as String? ?? 'outfit',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 18,
      fontWeight: json['fontWeight'] as int? ?? 400,
      italic: json['italic'] as bool? ?? false,
      underline: json['underline'] as bool? ?? false,
      strikethrough: json['strikethrough'] as bool? ?? false,
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 0,
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.35,
      align: TextAlignKind.values.byName(json['align'] as String? ?? 'left'),
      color: json['color'] as int? ?? 0xFF1C1410,
      x: (json['x'] as num?)?.toDouble() ?? 24,
      y: (json['y'] as num?)?.toDouble() ?? 28,
      width: (json['width'] as num?)?.toDouble() ?? 352,
      height: (json['height'] as num?)?.toDouble() ?? 480,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      zIndex: json['zIndex'] as int? ?? 0,
    );
  }
}

class DrawingElement extends NoteElement {
  DrawingElement({
    required super.id,
    List<Stroke>? strokes,
    super.x = 0,
    super.y = 0,
    super.width = 400,
    super.height = 560,
    super.rotation,
    super.zIndex = 2,
  })  : strokes = strokes ?? <Stroke>[],
        super(kind: ElementKind.drawing);

  final List<Stroke> strokes;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'rotation': rotation,
        'zIndex': zIndex,
        'strokes': strokes.map((s) => s.toJson()).toList(),
      };

  factory DrawingElement.fromJson(Map<String, dynamic> json) {
    return DrawingElement(
      id: json['id'] as String,
      strokes: (json['strokes'] as List<dynamic>? ?? [])
          .map((e) => Stroke.fromJson(e as Map<String, dynamic>))
          .toList(),
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble() ?? 400,
      height: (json['height'] as num?)?.toDouble() ?? 560,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      zIndex: json['zIndex'] as int? ?? 2,
    );
  }
}

class ImageElement extends NoteElement {
  ImageElement({
    required super.id,
    required this.assetPath,
    super.x = 40,
    super.y = 80,
    super.width = 240,
    super.height = 180,
    super.rotation,
    super.zIndex = 1,
  }) : super(kind: ElementKind.image);

  final String assetPath;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'rotation': rotation,
        'zIndex': zIndex,
        'assetPath': assetPath,
      };

  factory ImageElement.fromJson(Map<String, dynamic> json) {
    return ImageElement(
      id: json['id'] as String,
      assetPath: json['assetPath'] as String? ?? '',
      x: (json['x'] as num?)?.toDouble() ?? 40,
      y: (json['y'] as num?)?.toDouble() ?? 80,
      width: (json['width'] as num?)?.toDouble() ?? 240,
      height: (json['height'] as num?)?.toDouble() ?? 180,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      zIndex: json['zIndex'] as int? ?? 1,
    );
  }
}

class ShapeElement extends NoteElement {
  ShapeElement({
    required super.id,
    required this.shape,
    required this.color,
    super.x = 40,
    super.y = 40,
    super.width = 80,
    super.height = 80,
    super.rotation,
    super.zIndex = 1,
  }) : super(kind: ElementKind.shape);

  final String shape;
  final int color;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'rotation': rotation,
        'zIndex': zIndex,
        'shape': shape,
        'color': color,
      };

  factory ShapeElement.fromJson(Map<String, dynamic> json) {
    return ShapeElement(
      id: json['id'] as String,
      shape: json['shape'] as String? ?? 'rect',
      color: json['color'] as int? ?? 0xFFC45C26,
      x: (json['x'] as num?)?.toDouble() ?? 40,
      y: (json['y'] as num?)?.toDouble() ?? 40,
      width: (json['width'] as num?)?.toDouble() ?? 80,
      height: (json['height'] as num?)?.toDouble() ?? 80,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      zIndex: json['zIndex'] as int? ?? 1,
    );
  }
}

class StickerElement extends NoteElement {
  StickerElement({
    required super.id,
    required this.glyph,
    super.x = 280,
    super.y = 40,
    super.width = 64,
    super.height = 64,
    super.rotation,
    super.zIndex = 3,
  }) : super(kind: ElementKind.sticker);

  final String glyph;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'rotation': rotation,
        'zIndex': zIndex,
        'glyph': glyph,
      };

  factory StickerElement.fromJson(Map<String, dynamic> json) {
    return StickerElement(
      id: json['id'] as String,
      glyph: json['glyph'] as String? ?? '✦',
      x: (json['x'] as num?)?.toDouble() ?? 280,
      y: (json['y'] as num?)?.toDouble() ?? 40,
      width: (json['width'] as num?)?.toDouble() ?? 64,
      height: (json['height'] as num?)?.toDouble() ?? 64,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      zIndex: json['zIndex'] as int? ?? 3,
    );
  }
}

class Note {
  Note({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.themeId,
    required this.style,
    required this.elements,
    this.title = '',
    this.tags = const [],
    this.isPinned = false,
    this.isFavorite = false,
    this.isArchived = false,
    this.homeWidgetEnabled = false,
    this.canvasWidth = 400,
    this.canvasHeight = 560,
  });

  final String id;
  String title;
  DateTime createdAt;
  DateTime updatedAt;
  NoteThemeId themeId;
  NoteStyleKind style;
  List<NoteElement> elements;
  List<String> tags;
  bool isPinned;
  bool isFavorite;
  bool isArchived;
  bool homeWidgetEnabled;
  double canvasWidth;
  double canvasHeight;

  TextElement? get primaryText {
    final texts = elements.whereType<TextElement>().toList();
    if (texts.isEmpty) return null;
    texts.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return texts.first;
  }

  DrawingElement get drawingLayer {
    final existing = elements.whereType<DrawingElement>().firstOrNull;
    if (existing != null) return existing;
    final layer = DrawingElement(id: 'drawing-$id');
    elements.add(layer);
    return layer;
  }

  String get body => primaryText?.content ?? '';

  String get previewTitle {
    if (title.trim().isNotEmpty) return title.trim();
    final body = this.body.trim();
    if (body.isEmpty) return 'Untitled';
    final line = body.split('\n').first.trim();
    return line.length > 28 ? '${line.substring(0, 28)}…' : line;
  }

  String get searchableText {
    return [
      title,
      body,
      ...tags,
      style.name,
      themeId.name,
      if (elements.whereType<ImageElement>().isNotEmpty) 'photo image',
    ].join(' ').toLowerCase();
  }

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return searchableText.contains(q);
  }

  Note duplicate(String newId) {
    final json = toJson();
    json['id'] = newId;
    json['title'] = title.trim().isEmpty ? title : '$title copy';
    json['createdAt'] = DateTime.now().toIso8601String();
    json['updatedAt'] = DateTime.now().toIso8601String();
    json['isPinned'] = false;
    json['homeWidgetEnabled'] = false;
    return Note.fromJson(json);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'themeId': themeId.name,
        'style': style.name,
        'elements': elements.map((e) => e.toJson()).toList(),
        'tags': tags,
        'isPinned': isPinned,
        'isFavorite': isFavorite,
        'isArchived': isArchived,
        'homeWidgetEnabled': homeWidgetEnabled,
        'canvasWidth': canvasWidth,
        'canvasHeight': canvasHeight,
      };

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      themeId: NoteThemeId.values.byName(json['themeId'] as String),
      style: NoteStyleKind.values.byName(json['style'] as String),
      elements: (json['elements'] as List<dynamic>? ?? [])
          .map((e) => NoteElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
      isPinned: json['isPinned'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      homeWidgetEnabled: json['homeWidgetEnabled'] as bool? ?? false,
      canvasWidth: (json['canvasWidth'] as num?)?.toDouble() ?? 400,
      canvasHeight: (json['canvasHeight'] as num?)?.toDouble() ?? 560,
    );
  }
}

class AppSettings {
  AppSettings({
    this.themeMode = AppThemeMode.system,
    this.defaultStyle = NoteStyleKind.journal,
    this.defaultFontId = 'lora',
    this.defaultTheme = NoteThemeId.creamPaper,
    this.defaultView = HomeViewMode.grid,
    this.hasCompletedOnboarding = false,
    this.reduceMotion = false,
    this.adsEnabled = true,
  });

  AppThemeMode themeMode;
  NoteStyleKind defaultStyle;
  String defaultFontId;
  NoteThemeId defaultTheme;
  HomeViewMode defaultView;
  bool hasCompletedOnboarding;
  bool reduceMotion;
  bool adsEnabled;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    NoteStyleKind? defaultStyle,
    String? defaultFontId,
    NoteThemeId? defaultTheme,
    HomeViewMode? defaultView,
    bool? hasCompletedOnboarding,
    bool? reduceMotion,
    bool? adsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      defaultStyle: defaultStyle ?? this.defaultStyle,
      defaultFontId: defaultFontId ?? this.defaultFontId,
      defaultTheme: defaultTheme ?? this.defaultTheme,
      defaultView: defaultView ?? this.defaultView,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      adsEnabled: adsEnabled ?? this.adsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'defaultStyle': defaultStyle.name,
        'defaultFontId': defaultFontId,
        'defaultTheme': defaultTheme.name,
        'defaultView': defaultView.name,
        'hasCompletedOnboarding': hasCompletedOnboarding,
        'reduceMotion': reduceMotion,
        'adsEnabled': adsEnabled,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: AppThemeMode.values.byName(json['themeMode'] as String? ?? 'system'),
      defaultStyle:
          NoteStyleKind.values.byName(json['defaultStyle'] as String? ?? 'journal'),
      defaultFontId: json['defaultFontId'] as String? ?? 'lora',
      defaultTheme:
          NoteThemeId.values.byName(json['defaultTheme'] as String? ?? 'creamPaper'),
      defaultView:
          HomeViewMode.values.byName(json['defaultView'] as String? ?? 'grid'),
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      reduceMotion: json['reduceMotion'] as bool? ?? false,
      adsEnabled: json['adsEnabled'] as bool? ?? true,
    );
  }
}
