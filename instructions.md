# Hello World App — Run & Test Instructions

Flutter app running on Android, iOS, and Web. Text under "Hello World!" is fetched live from `https://api.github.com/zen`.

---

## 1. Setup (already done on this PC)

| Tool | Location / Note |
|------|-----------------|
| Flutter SDK 3.47.9 | `C:\dev\flutter` (already on PATH) |
| Android SDK | `C:\dev\android-sdk` (`ANDROID_HOME` is set) |
| JDK 17 | `JAVA_HOME` is set |
| GitHub CLI | config at `C:\Users\Arefin\Scripts\App Test\.gh-config` (see §7) |
| Repo | https://github.com/arefinglossyit/hello_world |

Quick health check:

```powershell
flutter doctor
```

All items should be ✔ except "Visual Studio" (only needed for Windows desktop apps — not our target).

---

## 2. Run on a real Android phone (recommended)

1. Phone: **Settings → About phone → tap "Build number" 7 times**
2. **Settings → System → Developer options → enable USB debugging**
3. Connect phone via USB → allow the "USB debugging?" popup
4. Verify the phone is detected:

```powershell
cd "c:\Users\Arefin\Scripts\App Test\hello_world"
adb devices
```

You should see your device with state `device` (e.g. `545d1a4d   device`).

5. Run with **hot reload**:

```powershell
flutter run -d 545d1a4d      # replace with your device id from `adb devices`
```

or simply `flutter run` if the phone is the only connected device.

### Hot reload keys (while `flutter run` is active)

| Key | Action |
|-----|--------|
| `r` | Hot reload — apply code changes instantly, keeps state |
| `R` | Hot restart — restart app, keeps it installed |
| `q` | Quit (app stays installed on the phone) |
| `h` | Help / list all keys |

> Editing `lib/main.dart` in your editor + pressing `r` shows changes in ~1 second — no reinstall.

---

## 3. Run on the Android emulator

```powershell
emulator -avd pixel
```

- Wait for full boot (~1–2 min first time), then:

```powershell
cd "c:\Users\Arefin\Scripts\App Test\hello_world"
flutter run
```

- Select the emulator when prompted (or `flutter run -d emulator-5554`).

### Emulator troubleshooting (this PC)

- **Window frozen / shows stale image**: the Intel UHD 630 GPU struggles with the default renderer. Restart with:

```powershell
emulator -avd pixel -gpu host
```

- Internally the emulator usually still works even when the window looks frozen — verify with:

```powershell
adb shell screencap -p /sdcard/s.png ; adb pull /sdcard/s.png
```

- To wipe and cold-boot:

```powershell
emulator -avd pixel -no-snapshot
```

---

## 4. Quick preview in the browser

```powershell
cd "c:\Users\Arefin\Scripts\App Test\hello_world"
flutter run -d chrome
```

(If `chrome` is not listed, run `flutter create --platforms web .` once.)

---

## 5. Run the tests

```powershell
cd "c:\Users\Arefin\Scripts\App Test\hello_world"

flutter analyze                          # static analysis — should be "No issues found"

flutter test                             # unit + widget tests (API is mocked)

flutter test integration_test -d <device-id>   # integration test on emulator/phone
                                         # hits the REAL API and asserts it succeeds
```

---

## 6. Test on iPhone simulator (via GitHub Actions)

iOS simulators only run on macOS, so we use GitHub's free macOS runners.

1. Push a commit (or just edit any file and save the workflow below):

```powershell
cd "c:\Users\Arefin\Scripts\App Test\hello_world"
git add -A
git commit -m "your message"
git push
```

2. The workflow `.github/workflows/ios-sim.yml` runs automatically: boots an iPhone simulator, runs the integration test, installs the app, and captures a screenshot.

3. Watch it / get the screenshot:

- Browser: https://github.com/arefinglossyit/hello_world/actions → click the run → **Artifacts** → `ios-screenshot`

- Or with GitHub CLI (PowerShell):

```powershell
$env:GH_CONFIG_DIR = "C:\Users\Arefin\Scripts\App Test\.gh-config"
gh run list --repo arefinglossyit/hello_world --limit 3        # get run id + status
gh run download <run-id> --repo arefinglossyit/hello_world --name ios-screenshot --dir ios-screenshot
```

> NOTE: `GH_CONFIG_DIR` must be set in every new terminal (our sandbox setup stores gh's config outside the default location). Takes ~10–15 min per run. Free for public repos.

---

## 7. Building installable APKs

```powershell
cd "c:\Users\Arefin\Scripts\App Test\hello_world"

# Debug APK — for quick testing on any device
flutter build apk --debug --target-platform android-arm,android-arm64,android-x64

# Release APK — for sharing / Play Store (AAB is preferred for the store)
flutter build apk --release
flutter build appbundle    # .aab file for Google Play upload
```

Install an APK on the connected phone:

```powershell
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

> ⚠️ Gotcha: if you build while targeting one device type, the APK may contain only that ABI
> (e.g. x86_64 for the emulator → `INSTALL_FAILED_NO_MATCHING_ABIS` on a real phone).
> Fix: rebuild with `--target-platform android-arm,android-arm64,android-x64` as shown above.

---

## 8. Common commands cheat sheet

| Task | Command |
|------|---------|
| List devices | `flutter devices` or `adb devices` |
| Run app (choose device) | `flutter run` |
| Hot reload | `r` (in the running `flutter run` session) |
| Get dependencies | `flutter pub get` |
| Clean build cache | `flutter clean` |
| Take screenshot (device) | `adb shell screencap -p /sdcard/s.png; adb pull /sdcard/s.png` |
| Launch app manually | `adb shell am start -n com.example.hello_world/.MainActivity` |
| Stop emulator gracefully | `adb emu kill` |
| Flutter logs | `flutter logs` or `adb logcat -s flutter` |

---

## 9. Project layout

```
hello_world/
├── lib/main.dart                  # App code (Hello World + API text)
├── test/widget_test.dart          # Unit/widget tests (mocked API)
├── integration_test/app_test.dart # Real-device test (real API)
├── .github/workflows/ios-sim.yml  # iOS simulator CI (GitHub Actions)
├── android/                       # Android project
└── ios/                           # iOS project (build on Mac/CI only)
```
