# Unsigned IPA package guide

This project includes `bin/build_unsigned_ipa.sh`.

Run it on macOS with Flutter and Xcode installed:

```bash
cd we_packages_manager
chmod +x bin/build_unsigned_ipa.sh
./bin/build_unsigned_ipa.sh com.yourname.wepackagesmanager
```

The script will:

1. Generate the Flutter iOS project if the `ios/` folder does not exist.
2. Set the iOS bundle identifier.
3. Build the Flutter iOS release app without code signing.
4. Package `build/ios/iphoneos/Runner.app` into:

```text
build/ios/unsigned_ipa/WEPackagesManager_unsigned.ipa
```

The IPA is unsigned. To install it on an iPhone, it must be signed with a valid Apple certificate and provisioning profile. You can sign it using a trusted iOS signing tool or a normal Apple/Xcode signing workflow.

Important notes:

- You cannot build a real Flutter iOS IPA on Windows or Linux because the iOS toolchain requires macOS and Xcode.
- The IPA must contain compiled iOS binaries, not only Flutter source code.
- If the signing tool asks for a bundle identifier, use the same value you passed to the script.
- Example bundle identifier: `com.yourname.wepackagesmanager`.
