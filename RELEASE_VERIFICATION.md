# DryCare release verification — 23 October 2026

Signed artifact: `build/app/outputs/bundle/release/app-release.aab` (48.3 MB).

SHA-256: `1210888AFD2A7ED4200787D185FC03A1C9F75BE2ED9AB0D53EEA7129E0A56332`

- `flutter pub get`: passed after upgrading google_fonts from 6.3.0 to 6.3.3.
- `flutter analyze`: no issues.
- `flutter test`: all 4 tests passed.
- `flutter build appbundle --release`: passed, exit code 0.
- Google bundletool 1.18.3 validation: passed, exit code 0.
- Cryptographic verification: all 90 non-META-INF file entries verified and matched the configured upload certificate; certificate valid and not Android Debug.
- Upload certificate SHA-256: `c00aa86183e92cfc2b6ffe3902fea6c43c77b5c9b888a75a41c357b3a46cfba7`.
- Embedded bundle manifest and current merged release manifest agree: package `com.drycare.drycare`, version name `1.0.0`, version code `1`, target SDK `36`, minimum SDK `24`.
- No debuggable flag enabled. Backup disabled.
- Only requested permission: `com.drycare.drycare.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (signature-protected AndroidX permission).
- No INTERNET, notification, boot, or exact-alarm permission in the bundle.

The current merged manifest is `build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml`. Older manifests at other paths in build/ are stale.

## Build fixes

Google Fonts 6.3.0 failed release compilation because of a const FontWeight-keyed map. Patch release 6.3.3 contains the compatibility fix, retaining the same app typography API.

Flutter's post-build apkanalyzer invocation failed on the Android SDK path containing spaces. The successful command used the same installed SDK's existing Windows short path, scoped to the build shell:

```powershell
$fs = New-Object -ComObject Scripting.FileSystemObject
$env:ANDROID_HOME = $fs.GetFolder('C:\Users\PC BEST 0755669979\AppData\Local\Android\sdk').ShortPath
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
flutter build appbundle --release
```

Credentials remain in ignored local files. Do not publish them. The signed bundle is suitable for the next internal-testing upload; device QA and the outstanding privacy, health, audience, and store-listing tasks remain separate publication gates. Google Fonts asset bundling/offline rendering has not been verified by device testing.
