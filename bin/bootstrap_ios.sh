#!/usr/bin/env bash
set -euo pipefail

ORG="${1:-com.example}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP="$(mktemp -d)"

cd "$ROOT"

cp -R lib "$BACKUP/lib"
cp pubspec.yaml "$BACKUP/pubspec.yaml"
cp l10n.yaml "$BACKUP/l10n.yaml"
cp analysis_options.yaml "$BACKUP/analysis_options.yaml"

flutter create . --platforms=ios --org "$ORG" --project-name we_packages_manager

./bin/configure_ios_contacts_permission.sh

rm -rf lib
cp -R "$BACKUP/lib" lib
cp "$BACKUP/pubspec.yaml" pubspec.yaml
cp "$BACKUP/l10n.yaml" l10n.yaml
cp "$BACKUP/analysis_options.yaml" analysis_options.yaml

flutter pub get

echo "iOS project generated. Open ios/Runner.xcworkspace or run flutter run."
