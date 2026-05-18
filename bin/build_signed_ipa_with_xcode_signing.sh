#!/usr/bin/env bash
set -euo pipefail

# Builds a signed IPA using Xcode/Apple signing on a Mac.
# Before running, open ios/Runner.xcworkspace once and set Signing & Capabilities > Team.
# Usage:
#   ./bin/build_signed_ipa_with_xcode_signing.sh development
#   ./bin/build_signed_ipa_with_xcode_signing.sh ad-hoc

METHOD="${1:-development}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: Building an iOS IPA requires macOS with Xcode installed."
  exit 1
fi

case "$METHOD" in
  development|ad-hoc) ;;
  *) echo "Error: method must be development or ad-hoc"; exit 1 ;;
esac

if [[ ! -d ios || ! -f ios/Runner.xcodeproj/project.pbxproj ]]; then
  ./bin/bootstrap_ios.sh com.wepackages
fi

./bin/configure_ios_contacts_permission.sh

flutter clean
flutter pub get
flutter gen-l10n
flutter build ipa --release --export-options-plist="ios_export_options/ExportOptions-$METHOD.plist"

echo ""
echo "Signed IPA output folder: $ROOT/build/ios/ipa"
