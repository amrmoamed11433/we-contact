# تشغيل وبناء IPA وأنت على Windows

هذا المشروع Flutter لتطبيق iPhone، لذلك لا يمكن تحويله إلى ملف `.ipa` مباشرة من Windows؛ بناء iOS يحتاج macOS و Xcode. لكن يمكنك استخدام Windows لرفع المشروع إلى خدمة بناء سحابية تعمل على macOS وتحمّل منها ملف IPA.

## المطلوب منك

- حساب GitHub.
- المشروع مرفوع على GitHub repository.
- Bundle ID ثابت، مثال: `com.yourname.wepackagesmanager`.
- للتثبيت على iPhone: لازم توقيع Apple صالح. ملف IPA غير الموقّع لا يثبت على iPhone قبل التوقيع.

## الطريقة 1: GitHub Actions

1. فك ضغط المشروع على Windows.
2. افتح GitHub وأنشئ repository جديد.
3. ارفع كل ملفات المشروع، بما فيها فولدر `.github`.
4. افتح تبويب **Actions**.
5. اختار workflow باسم **Build unsigned iOS IPA**.
6. اضغط **Run workflow**.
7. اكتب:
   - `org`: مثال `com.yourname`
   - `bundle_id`: مثال `com.yourname.wepackagesmanager`
   - `app_name`: `WE Packages Manager`
8. بعد انتهاء التشغيل، افتح صفحة الـ run وحمّل artifact باسم:

```text
WE_Packages_Manager_unsigned_ipa
```

داخله هتلاقي ملف:

```text
WE_Packages_Manager_unsigned.ipa
```

## الطريقة 2: Codemagic

1. ارفع المشروع على GitHub.
2. افتح Codemagic واربط حساب GitHub.
3. اختار المشروع.
4. Codemagic سيقرأ ملف `codemagic.yaml` الموجود في المشروع.
5. قبل التشغيل غيّر المتغيرات في `codemagic.yaml` لو حابب:

```yaml
ORG: com.yourname
BUNDLE_ID: com.yourname.wepackagesmanager
APP_DISPLAY_NAME: WE Packages Manager
```

6. شغّل workflow باسم **Build unsigned iOS IPA**.
7. حمّل ملف IPA من Artifacts بعد انتهاء البناء.

## بعد ما تحصل على IPA

الملف الناتج **غير موقّع**. للتثبيت على iPhone لازم توقّعه باستخدام شهادة Apple و provisioning profile متطابقين مع نفس Bundle ID.

الاختيارات القانونية/المضمونة عادة هي:

- توقيع Development أو Ad Hoc من Apple Developer Program.
- TestFlight أو App Store لو هتوزعه رسميًا.
- خدمة CI موثوقة تدعم code signing باستخدام شهادتك أنت.

مهم: لا تستخدم شهادات مجهولة أو مسروقة أو enterprise certificates ليست ملكك؛ ممكن التطبيق يتوقف أو حسابك/جهازك يتعرض لمشاكل.

## تقدر تجرّب التطبيق على Windows؟

بعد إضافة اختيار جهات الاتصال، أفضل تجربة محلية من Windows تكون على Android Emulator لأن إضافة `flutter_contacts` موجهة للموبايل و iOS/Android/macOS، وليست لتجربة Web/Windows Desktop.

```bash
flutter create . --platforms=android --org com.yourname --project-name we_packages_manager
flutter pub get
flutter gen-l10n
flutter run
```

أما بناء iOS/IPA النهائي فيظل محتاج macOS/Xcode أو Cloud macOS من GitHub Actions/Codemagic.
