# تجهيز WE Packages Manager كملف IPA للتوقيع والتثبيت على iPhone

## المهم

لا يمكن تحويل مشروع Flutter إلى ملف IPA حقيقي من السورس فقط بدون macOS و Xcode، لأن الـ IPA لازم يحتوي على تطبيق iOS مترجم فعليًا داخل `Payload/Runner.app`.

هذه النسخة تحتوي على سكريبتين:

1. `bin/build_unsigned_ipa_for_iphone_signing.sh`
   - يبني التطبيق بدون توقيع.
   - يخرج ملف:
     `build/ios/ipa/WE_Packages_Manager_unsigned.ipa`
   - هذا هو الملف المناسب للتوقيع لاحقًا بشهادتك و provisioning profile صالحين.

2. `bin/build_signed_ipa_with_xcode_signing.sh`
   - يبني IPA موقّع من Xcode مباشرة باستخدام Apple Developer signing.
   - يحتاج ضبط Team داخل Xcode أولًا.

---

## الطريقة الأولى: IPA غير موقّع جاهز للتوقيع لاحقًا

من Mac داخل فولدر المشروع:

```bash
chmod +x bin/*.sh
./bin/build_unsigned_ipa_for_iphone_signing.sh com.yourname com.yourname.wepackagesmanager "WE Packages Manager"
```

الناتج سيكون هنا:

```text
build/ios/ipa/WE_Packages_Manager_unsigned.ipa
```

بعدها وقّع هذا الملف باستخدام شهادة Apple صالحة و provisioning profile يطابق نفس Bundle ID:

```text
com.yourname.wepackagesmanager
```

لازم الـ Bundle ID المستخدم في التوقيع يكون نفس الـ Bundle ID الذي بنيت به التطبيق.

---

## الطريقة الثانية: IPA موقّع مباشرة من Xcode

1. افتح المشروع في Xcode:

```bash
open ios/Runner.xcworkspace
```

2. اختار:

```text
Runner > Signing & Capabilities
```

3. فعّل:

```text
Automatically manage signing
```

4. اختار Apple Team.

5. ارجع للـ Terminal وشغّل:

```bash
./bin/build_signed_ipa_with_xcode_signing.sh development
```

أو لو عندك Apple Developer Program وعايز Ad Hoc لأجهزة مسجلة:

```bash
./bin/build_signed_ipa_with_xcode_signing.sh ad-hoc
```

الناتج سيكون داخل:

```text
build/ios/ipa
```

---

## ملاحظات مهمة

- iOS يحتاج توقيع صالح قبل التثبيت على iPhone.
- لو هتستخدم توقيع Development أو Ad Hoc، لازم الـ provisioning profile يكون مناسب للـ Bundle ID والجهاز.
- لو ظهر خطأ signing، افتح Xcode واضبط Team و Bundle Identifier.
- لو ظهر خطأ CocoaPods، نفّذ:

```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

