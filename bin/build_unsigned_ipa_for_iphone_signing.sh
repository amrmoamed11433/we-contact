#!/usr/bin/env bash
set -euo pipefail

# Builds an unsigned IPA that can be signed later with your own Apple certificate/profile.
# Usage:
#   ./bin/build_unsigned_ipa_for_iphone_signing.sh [org] [bundle_id] [app_display_name]
# Example:
#   ./bin/build_unsigned_ipa_for_iphone_signing.sh com.yourname com.yourname.wepackagesmanager "WE Packages Manager"

ORG="${1:-com.wepackages}"
BUNDLE_ID="${2:-com.wepackages.manager}"
APP_DISPLAY_NAME="${3:-WE Packages Manager}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: Building an iOS IPA requires macOS with Xcode installed."
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "Error: Flutter is not installed or not available in PATH."
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "Error: Xcode command-line tools are not available. Install Xcode first."
  exit 1
fi

if [[ ! -d ios || ! -f ios/Runner.xcodeproj/project.pbxproj ]]; then
  echo "iOS folder not found. Generating it now with flutter create..."
  ./bin/bootstrap_ios.sh "$ORG"
fi

PBX="ios/Runner.xcodeproj/project.pbxproj"
INFO_PLIST="ios/Runner/Info.plist"

# Make the bundle id predictable for later signing.
export BUNDLE_ID
/usr/bin/perl -0pi -e 's/PRODUCT_BUNDLE_IDENTIFIER = [^;]+;/PRODUCT_BUNDLE_IDENTIFIER = $ENV{BUNDLE_ID};/g' "$PBX"

# Set the visible iPhone app name.
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $APP_DISPLAY_NAME" "$INFO_PLIST" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string $APP_DISPLAY_NAME" "$INFO_PLIST"

# Keep CFBundleName short and safe.
/usr/libexec/PlistBuddy -c "Set :CFBundleName WEPackages" "$INFO_PLIST" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Add :CFBundleName string WEPackages" "$INFO_PLIST"

./bin/configure_ios_contacts_permission.sh "$INFO_PLIST"

flutter clean
flutter pub get
flutter gen-l10n

# Build the iOS app without code signing. This creates build/ios/iphoneos/Runner.app.
flutter build ios --release --no-codesign

APP_PATH="build/ios/iphoneos/Runner.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "Error: $APP_PATH was not created. Check the Flutter/Xcode build output above."
  exit 1
fi

OUT_WORK="build/ios/unsigned_ipa_work"
OUT_IPA_DIR="build/ios/ipa"
OUT_IPA="$OUT_IPA_DIR/WE_Packages_Manager_unsigned.ipa"

rm -rf "$OUT_WORK"
mkdir -p "$OUT_WORK/Payload" "$OUT_IPA_DIR"
cp -R "$APP_PATH" "$OUT_WORK/Payload/Runner.app"

# Remove any stale signing files so the IPA can be signed cleanly later.
find "$OUT_WORK/Payload/Runner.app" -name "_CodeSignature" -type d -prune -exec rm -rf {} + 2>/dev/null || true
rm -f "$OUT_WORK/Payload/Runner.app/embedded.mobileprovision"

rm -f "$OUT_IPA"
(
  cd "$OUT_WORK"
  /usr/bin/zip -qry "$ROOT/$OUT_IPA" Payload
)

echo ""
echo "Unsigned IPA created:"
echo "$ROOT/$OUT_IPA"
echo ""
echo "Bundle ID: $BUNDLE_ID"
echo "App name:  $APP_DISPLAY_NAME"
echo "Sign this IPA with your own valid Apple certificate and provisioning profile before installing it on iPhone."
