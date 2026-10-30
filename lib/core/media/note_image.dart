import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../theme/app_colors.dart';
import '../persistence/local_store.dart';

class NoteImageStore {
  NoteImageStore(this._store);

  final LocalStore _store;

  Future<String> importPath(String sourcePath) async {
    await _store.imagesDir.create(recursive: true);
    final ext = p.extension(sourcePath);
    final safeExt = ext.isEmpty ? '.jpg' : ext.toLowerCase();
    final dest = File(p.join(_store.imagesDir.path, '${const Uuid().v4()}$safeExt'));
    await File(sourcePath).copy(dest.path);
    return dest.path;
  }
}

enum ImagePickIntent { attach, readText }

class PickedNoteImage {
  const PickedNoteImage(this.path);

  final String path;
}

Future<PickedNoteImage?> pickNoteImage(
  BuildContext context,
  NoteImageStore store, {
  required ImagePickIntent intent,
}) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final title = intent == ImagePickIntent.readText
          ? 'Read text from a photo'
          : 'Add a photo';
      final blurb = intent == ImagePickIntent.readText
          ? 'Camera or library. Words on the page become a note.'
          : 'Place a picture on this note.';
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.ink.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: GoogleFonts.fraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(blurb, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: const Icon(Icons.photo_camera_outlined),
                      title: const Text('Camera'),
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: const Icon(Icons.photo_outlined),
                      title: const Text('Photo library'),
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
  if (source == null) return null;
  final picked = await ImagePicker().pickImage(
    source: source,
    imageQuality: 88,
    maxWidth: 2400,
  );
  if (picked == null) return null;
  if (kIsWeb) return PickedNoteImage(picked.path);
  final stored = await store.importPath(picked.path);
  return PickedNoteImage(stored);
}
