# THARINDU TYRE SCAN — Flutter starter

Android-first starter for capturing Dag tyre inventory. Records and image paths are stored locally on the device using SharedPreferences; camera photos are stored by the Android image picker.

## Current starter features
- Capture sidewall and tread photos (both required before saving)
- Manually enter brand, size, serial/DOT and condition notes
- Save records locally/offline and search by entered details
- Show saved sidewall photo in the stock list

## Important scope note
This starter does **not yet include OCR or automatic photo-based identity matching**. Those are the next implementation stages. Exact serial/DOT matching can be used as the strongest identifier when OCR is added; photo similarity alone should not be treated as guaranteed identity.

## Run
1. Install Flutter SDK and Android Studio.
2. In this folder run: `flutter create --platforms=android .`
3. Run: `flutter pub get`
4. Connect Android phone or start an emulator, then run: `flutter run`
5. Build APK: `flutter build apk --release`

The generated Android project requires Android camera permission configuration if your Flutter/image_picker version does not add it automatically. No cloud account is required for this starter.
