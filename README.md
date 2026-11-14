# FinTrust Digital Bank — Premium Android UI and biometric prototype

This is an improved **14-screen Flutter/Dart Android app** for the FinTrust UI/UX assignment.
It uses a navy/blue banking design, quick actions, cards, simulated transfers and bill payments,
a review sheet, sample receipts, dark mode, and an Android biometric confirmation flow.

## IMPORTANT
- **Android fingerprint / supported face unlock:** Uses the Android system biometric prompt
  through `local_auth`. The phone must have supported biometric hardware and an enrolled biometric.
  Android decides which enrolled biometric method is offered; the app cannot force Face ID.
- **Chrome:** You can preview the UI, but Chrome does NOT run Android's system biometric prompt.
- **Demo only:** There is no banking backend. Login with the demo button; no real money moves.
- **Verification:** Source and ZIP structure have been inspected, but this package has not been
  compiled in this environment. Run it and report any compiler errors for correction.

## Android setup on your Windows laptop
1. Install Android Studio, open SDK Manager and install Android SDK + Platform Tools.
2. Connect an Android phone with USB debugging enabled or start an Android emulator.
3. In the *project root* (where pubspec.yaml is), run:
   ```
   flutter doctor
   flutter doctor --android-licenses
   flutter pub get
   flutter devices
   flutter run -d <your-android-device-id>
   ```
4. If Flutter says Gradle wrapper/platform files are missing, run:
   ```
   flutter create . --platforms=android,web --org com.fintrust --project-name fintrust_digital_bank
   flutter pub get
   flutter run
   ```
5. To build an installable Android APK:
   ```
   flutter build apk --debug
   ```
   Find the APK in `build/app/outputs/flutter-apk/app-debug.apk`.

## Testing biometrics
- On a real Android phone, enrol a fingerprint or supported face unlock under Android Settings.
- Open FinTrust and tap Fingerprint or Face unlock. Android should show its native prompt.
- For payment confirmation, open Pay Bills or Transfer, enter a valid amount, review it,
  and choose biometric confirmation.
- Some Android phones support face unlock for screen unlock but do not expose it to apps
  as a sufficiently strong biometric. On those devices, fingerprint may be offered instead.
- Do not treat a successful demo biometric check as real bank identity verification.

## Folder structure
- `lib/main.dart`: 14 screens and biometric integration
- `android/`: Android configuration, permission, FragmentActivity
- `web/`: web preview
- `test/`: Flutter widget tests
- `evidence/`: screenshots checklist; Figma reference is **not** a runtime screenshot
