#!/usr/bin/env bash
set -euo pipefail

# Build an unsigned iOS IPA from this Flutter project.
# Run this script on macOS with Flutter and Xcode installed.
# Output: build/ios/unsigned_ipa/WEPackagesManager_unsigned.ipa
# The resulting IPA is intended for later signing with your own valid iOS certificate/provisioning profile.

BUNDLE_ID="${1:-com.example.wepackagesmanager}"
ORG_DEFAULT="com.example"
APP_NAME="WE Packages Manager"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_NAME="we_packages_manager"
IPA_BASENAME="WEPackagesManager_unsigned.ipa"
OUT_DIR="$ROOT/build/ios/unsigned_ipa"
PAYLOAD_DIR="$OUT_DIR/Payload"
APP_PATH="$ROOT/build/ios/iphoneos/Runner.app"
PBXPROJ="$ROOT/ios/Runner.xcodeproj/project.pbxproj"
INFO_PLIST="$ROOT/ios/Runner/Info.plist"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_command flutter
require_command xcodebuild
require_command zip

cd "$ROOT"

if [ ! -d "$ROOT/ios" ]; then
  echo "ios directory not found. Generating iOS project with Flutter..."
  if [ -x "$ROOT/bin/bootstrap_ios.sh" ]; then
    "$ROOT/bin/bootstrap_ios.sh" "$ORG_DEFAULT"
  else
    flutter create . --platforms=ios --org "$ORG_DEFAULT" --project-name "$PROJECT_NAME"
  fi
fi

if [ -f "$PBXPROJ" ]; then
  echo "Setting PRODUCT_BUNDLE_IDENTIFIER to $BUNDLE_ID"
  /usr/bin/perl -0pi -e "s/PRODUCT_BUNDLE_IDENTIFIER = [^;]+;/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID;/g" "$PBXPROJ"
fi

if [ -f "$INFO_PLIST" ] && [ -x /usr/libexec/PlistBuddy ]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $APP_NAME" "$INFO_PLIST" >/dev/null 2>&1 || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string $APP_NAME" "$INFO_PLIST"
  /usr/libexec/PlistBuddy -c "Set :CFBundleName $APP_NAME" "$INFO_PLIST" >/dev/null 2>&1 || true
fi

if [ -f "$INFO_PLIST" ]; then
  "$ROOT/bin/configure_ios_contacts_permission.sh" "$INFO_PLIST"
fi

flutter pub get
flutter gen-l10n || true

echo "Building unsigned iOS release app..."
flutter build ios --release --no-codesign

if [ ! -d "$APP_PATH" ]; then
  echo "Runner.app was not found at: $APP_PATH" >&2
  exit 1
fi

rm -rf "$OUT_DIR"
mkdir -p "$PAYLOAD_DIR"
cp -R "$APP_PATH" "$PAYLOAD_DIR/Runner.app"
xattr -cr "$PAYLOAD_DIR/Runner.app" >/dev/null 2>&1 || true

cd "$OUT_DIR"
zip -qry "$IPA_BASENAME" Payload

echo "Done. Unsigned IPA created at:"
echo "$OUT_DIR/$IPA_BASENAME"
echo "Copy this IPA to your iPhone and sign it with your own valid certificate/provisioning profile."
