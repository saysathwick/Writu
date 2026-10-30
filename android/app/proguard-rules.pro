# google_mlkit_text_recognition references optional script packs we do not
# ship. U-write only uses Latin OCR. R8 must not fail the release build.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.text.latin.** { *; }
