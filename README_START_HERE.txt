FINTRUST DIGITAL BANK - FLUTTER PROJECT
======================================
This is your FinTrust Flutter UI demonstration project, with 14 screens,
navigation, forms, validation, payment review and demo receipts.

1. Extract this ZIP into C:\Users\DELL\Desktop\
   You should have C:\Users\DELL\Desktop\fintrust_flutter\pubspec.yaml

2. Open PowerShell:
   cd "C:\Users\DELL\Desktop\fintrust_flutter"
   $env:Path += ";C:\Users\DELL\Downloads\flutter\bin"
   flutter pub get
   flutter create . --platforms=android,web
   flutter run -d chrome

3. For Android emulator:
   Install Android Studio and Android SDK, create and start an emulator.
   flutter doctor
   flutter devices
   flutter run -d <device-id>

4. Tests:
   flutter test

IMPORTANT:
- The app is a DEMO. It does not transfer real money.
- Android biometrics require a supported configured Android device or emulator.
- Chrome does not provide the native Android biometric confirmation.
- This package is source code, not a compiled APK.
- You need Flutter, and Android SDK for an Android emulator or APK build.
