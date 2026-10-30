# Atelier

A visual notes studio for Flutter. Notes are personal objects — cards, sticky pages, posters, sketchbook sheets — not plain documents.

**Write it. Style it. Make it yours.**

## Run

```bash
cd ~/Documents/Phito/atelier
flutter pub get
flutter run
```

Chrome and macOS work for UI development. An Android device (`S81` was detected in this environment) can run the real home-screen widget.

iOS WidgetKit is not bundled yet: this machine does not have a complete Xcode install, and iOS does not allow an app to place a widget on the Home Screen automatically. The Dart `HomeWidgetGateway` is ready for a WidgetKit extension later.

## What works

- Create, edit, save, persist, delete notes
- Style presets with live previews of your actual words
- Per-note fonts, typography, and visual themes (paper, color, artistic)
- Mixed text + freehand drawing (pen, pencil, marker, highlighter, eraser)
- Gallery home with grid / list / large cards that keep each note’s look
- Search, pin, favorite, archive, tags, share, backup import/export
- Onboarding, settings, ad placeholders, premium entitlement hook
- Android home-screen widget (pin request + tap-to-open the note)

Ads are mock/sponsored cards in the gallery only. The editor stays quiet.
