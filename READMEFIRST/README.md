# READMEFIRST

## What this is

Product Simulation is a Flutter app prototype for browsing products from the public DummyJSON API. It uses live product data and local device preferences; it is not a production commerce application.

## Documents

| File | Answers |
| --- | --- |
| [ARCHITECTURE_NOTES.md](ARCHITECTURE_NOTES.md) | Beginner guide to Riverpod/Freezed, architecture layers, request flow, common changes, and verification. |
| [TESTER_NOTES.md](TESTER_NOTES.md) | Debug APK download, install instructions, and device verification checklist. |

## Current state

- Riverpod/Freezed code generation completed successfully and dependencies resolve with FVM Flutter 3.47.5 / Dart 3.13.4.
- `fvm dart analyze` reports no errors and one non-blocking style info in the copied `tool/theme_guard.dart`.
- All 18 Flutter tests pass.
- `fvm flutter build web` succeeds and writes `build/web`; browser interaction has not been verified.
- Latest Android build: [ProductSimulation-DEBUG-v1.0.0-20261001.apk](builds/ProductSimulation-DEBUG-v1.0.0-20261001.apk); debug build, not for production distribution.
- Latest APK smoke test passed on Samsung SM A526B / Android 14, including the Product Simulation name/icon, recent-search rerun, clear, and persistence after relaunch. The five-item cap and duplicate promotion are covered by automated tests.
- API target: `https://dummyjson.com`; no app flavors or login flow are configured.

## If you are…

- **Running the app:** use the commands in the root [README](../README.md); code generation has already run.
- **Picking up the code:** read [ARCHITECTURE_NOTES.md](ARCHITECTURE_NOTES.md) and follow the synced `AGENTS.md` / `.github` instructions.
- **Testing:** run `fvm dart analyze` and `fvm flutter test` after changes.
- **Cutting a release:** this prototype has no signing or release setup.

## What is not done

- Android was smoke-tested on one physical device. Browser interaction and iOS have not been verified.
- Favorites and recent searches use SharedPreferences and are not encrypted; they contain no credentials or sensitive data.