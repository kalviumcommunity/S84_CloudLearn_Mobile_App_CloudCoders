# CloudLearn: Deployment & Submission Guide

This guide covers the final steps for building and deploying your Flutter application for Sprint #2. The app is now feature-complete with Firebase Authentication, Firestore, Storage, Google Maps, and Provider state management.

## 1. Local Testing & Running the App
Before building for production, ensure the app runs correctly on your development machine.

### Prerequisites
- Flutter SDK installed and in `PATH`.
- Android Studio or VS Code set up.
- An Android Emulator (AVD) or a physical Android device connected via Debugging Mode.
- **IMPORTANT**: You must add your Google Maps API Key to `android/app/src/main/AndroidManifest.xml` where it says `YOUR_API_KEY_HERE`.

### Running on Emulator/Device
1.  Open a terminal in the project root:
    ```bash
    cd flut
    flutter pub get
    flutter run
    ```
2.  If multiple devices are connected, list them (`flutter devices`) and run specifically:
    ```bash
    flutter run -d <device-id>
    ```

---

## 2. Building the Release APK (Android)
Follow these steps to generate a signed APK that you can install on any Android phone.

### Step 2.1: Key Generation
If you don't have a keystore, generate one (example for Linux/Mac):
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
*   **Store Password**: Remember this password!
*   **Key Password**: Remember this too!

### Step 2.2: Configure Gradle
Create a file named `key.properties` in the `android/` folder (do NOT commit this file to Git):
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=<path-to-your-keystore-file>
```

Edit `android/app/build.gradle.kts` (or `build.gradle`) to use these properties for the `release` build type.

### Step 2.3: Build the APK
Run the build command:
```bash
flutter build apk --release
```
The output file will be at: `build/app/outputs/flutter-apk/app-release.apk`.

You can now copy this file to your phone and install it manually.

---

## 3. Building the App Bundle (Play Store)
Google Play requires an Android App Bundle (`.aab`) instead of an APK.

### Build Command
```bash
flutter build appbundle --release
```
The output file will be at: `build/app/outputs/bundle/release/app-release.aab`.

This file is what you upload to the Google Play Console for internal testing or production release.

---

## 4. Final Verification Checklist
Before submitting your project:

- [ ] **Auth Flow**: Can you sign up, log in, and log out successfully?
- [ ] **Profile**: Can you upload a profile picture and see it update?
- [ ] **Maps**: Does the map load and show your current location? (Check API Key!)
- [ ] **Tasks**: Can you add, complete, and delete learning goals?
- [ ] **Theme**: Does the app look good in both Light and Dark modes?
- [ ] **Persistence**: Do tasks and profile data persist after restarting the app?

## 5. Deployment Reflection
Deploying a cloud-connected mobile app involves coordinating multiple services:
1.  **Frontend**: Flutter UI logic.
2.  **Backend**: Firebase (Auth, Firestore, Storage) rules and configuration.
3.  **APIs**: Google Maps Platform configuration.
4.  **Hardware**: Android/iOS permissions (Camera, Location).

Successfully integrating all these components demonstrates a strong grasp of modern mobile development architectures.

---

**Congratulations on completing Sprint #2!**
