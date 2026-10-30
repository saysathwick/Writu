import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ImageTextReader {
  bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  Future<String> read(String path) async {
    if (!isSupported) {
      throw UnsupportedError(
        'Reading text from photos is available on Android and iOS.',
      );
    }
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(InputImage.fromFilePath(path));
      return result.text.trim();
    } finally {
      await recognizer.close();
    }
  }
}
