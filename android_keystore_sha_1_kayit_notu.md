ANDROID KEYSTORE & GOOGLE AUTH KAYIT DOSYASI

=========================================

BU DOSYA NE İÇİN?
- Google Login (Android) için SHA-1 / SHA-256 bilgilerini KAYBETMEMEK
- Google Cloud Console (OAuth Client) ve Play Console ayarlarında tekrar kullanmak

-----------------------------------------

UYGULAMA BİLGİLERİ

Uygulama Adı:
Prof Saracoglu

Platform:
Android (Release / Upload)

-----------------------------------------

KEYSTORE BİLGİLERİ (UPLOAD / RELEASE)

Keystore Dosyası:
android/app/upload.keystore

Alias:
upload

Store Password:
office701

Key Password:
office701

DNAME:
C=TR, ST=Izmir, L=Izmir, O=Office701, OU=Software, CN=Prof Saracoglu

Oluşturulma Tarihi:
15 Aralık 2025

Geçerlilik:
02 Mayıs 2053 tarihine kadar

-----------------------------------------

SERTİFİKA PARMAK İZLERİ

SHA-1 (GOOGLE AUTH İÇİN KULLANILACAK):
28:6B:40:34:CE:BA:9F:4C:50:58:40:01:92:C2:4A:3F:2F:A1:04:91

SHA-256:
F2:C7:33:9F:F0:78:D0:32:39:C1:59:17:0F:35:82:25:7C:16:41:34:9C:AE:46:8C:FF:05:C8:31:E5:7B:EE:A8

-----------------------------------------

SHA-1 NASIL ALINDI?

Komut:
keytool -list -v \
-keystore android/app/upload.keystore \
-alias upload \
-storepass office701 \
-keypass office701

-----------------------------------------

GOOGLE CLOUD CONSOLE KULLANIMI

Google Cloud Console → APIs & Services → Credentials

OAuth Client ID oluştururken:
- Application Type: Android
- Package Name: AndroidManifest.xml içindeki GERÇEK package name
- SHA-1: Yukarıdaki SHA-1 değeri

-----------------------------------------

ÖNEMLİ NOTLAR

- Bu keystore RELEASE (UPLOAD) içindir
- Debug build için debug.keystore AYRIDIR
- Play Console'da "Google Play App Signing" açıksa:
  - Play Console SHA-1 için AYRI bir OAuth Client daha oluşturulmalıdır
- Bu dosyayı güvenli bir yerde mutlaka sakla

=========================================
