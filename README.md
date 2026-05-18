# WE Packages Manager

Offline Flutter iPhone app for a WE package reseller. The app manages exactly three package groups, up to six active customers per group, current-cycle payments, company cost, automatic cycle reset, and monthly history snapshots.

## What is included

- Flutter Material 3 app source code.
- Arabic and English localization with ARB files.
- Default Arabic locale with runtime language switch.
- RTL layout for Arabic and LTR layout for English.
- Hive local storage only; no Firebase, backend, login, or internet dependency.
- Provider state management.
- Monthly cycle helpers for renewal day 1 and renewal day 16.
- Automatic monthly reset that saves history before resetting customer payment status.
- Premium mobile-first dashboard UI with cards, chips, progress bars, swipe actions, haptics, and safe areas.
- Contact picker integration on iOS/Android: choose a device contact and auto-fill customer name and phone number.

## Project structure

```text
lib/
  main.dart
  app.dart
  models/
    group_model.dart
    customer_model.dart
    monthly_history_model.dart
    customer_snapshot_model.dart
  screens/
    splash_screen.dart
    dashboard_screen.dart
    groups_screen.dart
    group_details_screen.dart
    add_edit_customer_screen.dart
    edit_group_screen.dart
    history_screen.dart
    history_details_screen.dart
    settings_screen.dart
  services/
    local_database_service.dart
    cycle_service.dart
    history_service.dart
    settings_service.dart
  providers/
    app_provider.dart
    language_provider.dart
  widgets/
    summary_card.dart
    group_card.dart
    customer_card.dart
    empty_state.dart
  utils/
    date_utils.dart
    currency_utils.dart
    validators.dart
  l10n/
    app_ar.arb
    app_en.arb
```

## Requirements

- macOS for iOS development.
- Flutter stable.
- Xcode.
- CocoaPods if your Flutter/iOS setup requires it.
- iOS Simulator or a real iPhone.

## Generate the iOS native folder

This package contains the app source code and a bootstrap script. Because generated Flutter iOS runner files are version-specific, generate them locally with your installed Flutter stable version.

From the project root:

```bash
chmod +x bin/bootstrap_ios.sh
bin/bootstrap_ios.sh com.yourcompany
```

The script safely backs up `lib/`, `pubspec.yaml`, `l10n.yaml`, and `analysis_options.yaml`, runs Flutter's iOS project generator, restores the app source, then runs `flutter pub get`.

Manual alternative:

```bash
flutter create . --platforms=ios --org com.yourcompany --project-name we_packages_manager
flutter pub get
```

If Flutter overwrites any source files, restore the files from this package.

## Run on iOS Simulator

```bash
open -a Simulator
flutter pub get
flutter gen-l10n
flutter run
```

You can list devices with:

```bash
flutter devices
```

Then run a specific simulator:

```bash
flutter run -d "iPhone 15"
```

## Run on a real iPhone

1. Connect the iPhone to your Mac with USB.
2. Trust the Mac on the device.
3. Open `ios/Runner.xcworkspace` in Xcode.
4. Select the Runner target.
5. Set your Team under **Signing & Capabilities**.
6. Make sure the bundle identifier is unique, for example `com.yourcompany.wepackagesmanager`.
7. Run from Xcode or use:

```bash
flutter run -d <device-id>
```

## Localization

Localization is generated from:

```text
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
```

The app uses `flutter_localizations` and generated `AppLocalizations`. All labels, buttons, alerts, bottom navigation text, screen titles, validation messages, and settings text come from the ARB files.

Default language is Arabic. The settings page lets the user switch between Arabic and English. Arabic uses RTL; English uses LTR.


## Contacts import

The Add/Edit Customer screen includes a **Choose from contacts** card. On iPhone, the app asks for Contacts permission, lists contacts that have phone numbers, lets the user search, then fills the customer name and phone number fields automatically.

The project uses `flutter_contacts`. The iOS permission text is written automatically to `ios/Runner/Info.plist` by:

```text
bin/configure_ios_contacts_permission.sh
```

This script is called by the iOS bootstrap and IPA build scripts, so cloud builds also include `NSContactsUsageDescription`.

## Local storage

The app stores data in Hive boxes:

- `groups`
- `customers`
- `monthly_history`
- `settings`

No network access, backend, or account is required.

## Cycle reset logic

The reset logic is in:

```text
lib/providers/app_provider.dart
```

On startup:

1. The app calculates the current cycle start date for each group.
2. It compares that date with `lastResetCycleStartDate`.
3. If different, it saves a `MonthlyHistory` snapshot for the previous cycle.
4. It resets active customers in that group to unpaid.
5. It updates `currentCycleStartDate` and `lastResetCycleStartDate`.
6. Because `lastResetCycleStartDate` is updated immediately, the same cycle cannot reset twice.

## Change the app name

After generating the iOS folder, update:

```text
ios/Runner/Info.plist
```

Set:

```xml
<key>CFBundleDisplayName</key>
<string>WE Packages Manager</string>
```

Also update `appName` in the ARB files if you want a different displayed name inside the app.

## Change the app icon

Recommended approach:

1. Create a 1024x1024 PNG app icon.
2. Use Xcode to update `ios/Runner/Assets.xcassets/AppIcon.appiconset`.
3. Alternatively, add `flutter_launcher_icons` as a dev dependency and configure it in `pubspec.yaml`.

## Fonts

The app is configured to fall back to `Cairo`, `SF Pro Display`, `Arial`, and `Helvetica`. Cairo font files are not included in this package. To use Cairo locally, add your licensed Cairo font files under `assets/fonts/` and uncomment the font section in `pubspec.yaml`.

## Useful commands

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
flutter build ios --release
```

## Notes

- Users cannot create or delete package groups.
- The app creates exactly three groups on first launch.
- Demo customers are editable and deletable.
- Customer delete is implemented as inactive data so current active lists and totals update safely.
- The History screen records immutable previous-cycle snapshots.

## Build an unsigned IPA for later signing

On macOS with Flutter and Xcode installed:

```bash
chmod +x bin/*.sh
./bin/build_unsigned_ipa_for_iphone_signing.sh com.yourname com.yourname.wepackagesmanager "WE Packages Manager"
```

Output:

```text
build/ios/ipa/WE_Packages_Manager_unsigned.ipa
```

Sign the IPA later with a valid Apple certificate and provisioning profile that match the same Bundle ID.

Arabic guide: `IPA_SIGNING_GUIDE_AR.md`.

## Windows cloud IPA build

If you only have Windows, you cannot build the iOS IPA locally because iOS builds require macOS and Xcode. This package includes two cloud-build options:

- `.github/workflows/build-ios-unsigned-ipa.yml` for GitHub Actions on a macOS runner.
- `codemagic.yaml` for Codemagic.

See `WINDOWS_IPA_BUILD_GUIDE_AR.md` for Arabic step-by-step instructions.
# we-contact
