# AGENTS.md

## Cursor Cloud specific instructions

### Overview

This is a Flutter (Dart) cross-platform application scaffolded with `flutter create`. The `.gitignore` covers Flutter, Android, iOS, macOS, Windows, and Linux targets.

### Prerequisites

- **Flutter SDK** is installed at `/opt/flutter` and added to `PATH` via `~/.bashrc`.
- System dependencies for Linux desktop/web builds (GTK3, clang, cmake, ninja-build, pkg-config) are pre-installed.
- `git config --global safe.directory /opt/flutter` is required for the Flutter SDK to work.

### Common commands

| Task | Command |
|------|---------|
| Install/update deps | `flutter pub get` |
| Lint / static analysis | `flutter analyze` |
| Run tests | `flutter test` |
| Run web dev server | `flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0` |
| Build web release | `flutter build web` |

### Caveats

- This VM has no physical display, so `flutter run -d linux` won't work. Use `web-server` device for dev testing.
- Hot reload (`r`) and hot restart (`R`) work in the `flutter run` interactive session.
- The web dev server listens on port 8080 by default; open `http://localhost:8080` in Chrome to test.
