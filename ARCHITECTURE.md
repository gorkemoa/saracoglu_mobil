# Saraçoğlu Mobile - Mimari Kuralları

## 🏗️ Genel Mimari

```
lib/
├── core/
│   └── constants/
│       └── api_constants.dart    # Tüm API endpoint'leri
├── models/
│   ├── auth/                     # Auth modelleri
│   ├── base/                     # Base modeller
│   └── user/                     # User modelleri
├── services/
│   ├── auth_service.dart         # Auth servisi
│   └── network_service.dart      # HTTP işlemleri
├── viewmodels/
│   └── auth_viewmodel.dart       # Auth ViewModel
└── views/
    └── auth/                     # Auth sayfaları
```

## 📋 Kurallar

### 1. API Endpoints
- **Tüm endpoint'ler** `lib/core/constants/api_constants.dart` içinde tanımlanır
- Asla view veya service içinde hardcode endpoint yazmayın
- Base URL değişikliği tek yerden yapılabilir

### 2. Models
- Her API isteği için **Request** ve **Response** modeli oluşturun
- `toJson()` ve `fromJson()` metodlarını ekleyin
- Modeller `lib/models/` altında kategorize edilir

### 3. Services
- API çağrıları sadece **Service** sınıflarında yapılır
- Her domain için ayrı service (AuthService, ProductService, etc.)
- Singleton pattern kullanın

### 4. ViewModels
- UI mantığı ve state yönetimi **ViewModel**'lerde yapılır
- View ile Service arasında köprü görevi görür
- `ChangeNotifier` extend eder

### 5. Error Handling
- **ASLA** statik hata mesajları yazmayın
- **417 status code** = Backend validation hatası
- Hata geldiğinde API'den gelen `message` alanını kullanıcıya gösterin
- Validator kullanmayın, backend'den gelen mesajları gösterin

```dart
// ✅ DOĞRU
if (response.statusCode == 417) {
  showError(response.data['message']);
}

// ❌ YANLIŞ
if (response.statusCode == 417) {
  showError('Kullanıcı adı veya şifre hatalı'); // Statik mesaj
}
```

### 6. Örnek Kullanım

#### Login Endpoint
```
POST {{BASE_URL}}service/auth/login

Request:
{
  "user_name": "ridvan",
  "password": "123"
}

Response (Success):
{
  "error": false,
  "success": true,
  "data": {
    "status": "success",
    "message": "Giriş Başarılı!",
    "userID": 2,
    "token": "ntc7P9L4YbmphYgCmuiaiCnuQDa6uYyY"
  },
  "200": "OK"
}
```

## 🔑 Hatırlatmalar

1. ✅ Endpoint'ler tek yerde (api_constants.dart)
2. ✅ Model'ler models/ klasöründe
3. ✅ API çağrıları services/ içinde
4. ✅ State yönetimi viewmodels/ içinde
5. ✅ 417 hatası = Backend mesajını göster
6. ✅ Profil sayfalarına her girişte kullanıcı bilgilerini yenile (getUser)
7. ❌ Statik hata mesajı yazma
8. ❌ Validator kullanma (backend validation)

## 📱 Sayfa Davranışları

### Profil Sayfaları
- **ProfilePage**: Her açılışta `getUser` API çağrısı yapılır
- **ProfileInfoPage**: Her açılışta `getUser` API çağrısı yapılır
- Kullanıcı bilgileri güncellenmiş olabilir, her zaman en güncel veriyi göster
- Loading state ile kullanıcıya yüklenme durumu gösterilir

```dart
// ✅ DOĞRU - Her girişte yenile
@override
void initState() {
  super.initState();
  _refreshUserData(); // Her zaman güncel veri
}

// ❌ YANLIŞ - Sadece bir kez çek
@override
void initState() {
  super.initState();
  if (_user == null) {
    _fetchUser(); // Sadece null ise çek
  }
}
```
