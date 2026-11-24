#!/usr/bin/env bash
# Build command for Cloudflare Pages. Its build machines have no Flutter, so
# fetch the same version used locally, then build the web app into build/web.
set -euo pipefail

FLUTTER_VERSION=3.50.1

git clone https://github.com/flutter/flutter.git \
  --branch "$FLUTTER_VERSION" --depth 1 "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"

flutter config --no-analytics
flutter pub get
flutter build web --release
