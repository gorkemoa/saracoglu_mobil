import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../models/auth/send_verification_code_model.dart';
import 'auth/login_page.dart';
import 'auth/code_verification_page.dart';
import 'profile/orders_page.dart';
import 'profile/cargo_tracking_page.dart';
import 'profile/returns_page.dart';
import 'profile/profile_info_page.dart';
import 'profile/addresses_page.dart';
import 'profile/saved_cards_page.dart';
import 'profile/change_password_page.dart';
import 'profile/help_support_page.dart';
import 'profile/legal_info_page.dart';
import 'profile/about_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  bool _isLoadingUser = false;

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthChanged);
    // Eğer kullanıcı giriş yapmışsa bilgileri getir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserIfNeeded();
    });
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  /// Kullanıcı bilgilerini getir (her zaman güncel bilgi için)
  Future<void> _fetchUserIfNeeded() async {
    // Yükleme devam ediyorsa çık
    if (_isLoadingUser) return;
    
    if (_authService.isLoggedIn && _authService.currentUser != null) {
      await _fetchUser();
    }
  }

  /// Kullanıcı bilgilerini API'den getir
  Future<void> _fetchUser() async {
    final userId = _authService.currentUser?.id;
    if (userId == null || _isLoadingUser) return;

    setState(() => _isLoadingUser = true);

    await _authService.getUser(userId);

    if (mounted) {
      setState(() => _isLoadingUser = false);
    }
  }

  Future<void> _navigateToLogin() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
    if (result == true && mounted) {
      setState(() {});
      // Login başarılı, user bilgilerini getir
      _fetchUser();
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMD),
        title: Text('Çıkış Yap', style: AppTypography.h4),
        content: Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Başarıyla çıkış yapıldı'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMD),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: AppSpacing.sm),
            Text('Hesabı Sil', style: AppTypography.h4),
          ],
        ),
        content: Text(
          'Hesabınızı silmek istediğinize emin misiniz?\n\nBu işlem geri alınamaz ve tüm verileriniz kalıcı olarak silinecektir.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await _authService.deleteUser();
      
      if (mounted) {
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Hesabınız başarıyla silindi'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderRadiusSM,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Hesap silinemedi'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderRadiusSM,
              ),
            ),
          );
        }
      }
    }
  }

  /// E-posta doğrulama başlat
  Future<void> _startEmailVerification(dynamic user) async {
    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderRadiusMD,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: AppSpacing.md),
              Text('Doğrulama kodu gönderiliyor...', style: AppTypography.bodyMedium),
            ],
          ),
        ),
      ),
    );

    // Kod gönder
    final response = await _authService.sendVerificationCode(SendCodeType.email);

    // Loading kapat
    if (mounted) Navigator.pop(context);

    if (response.isSuccess && mounted) {
      // Doğrulama sayfasına git
      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => CodeVerificationPage(
            email: user.email ?? '',
            verificationType: VerificationType.emailVerification,
          ),
        ),
      );

      if (verified == true && mounted) {
        // Başarılı doğrulama, kullanıcı bilgilerini yenile
        _fetchUser();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('E-posta adresiniz doğrulandı!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Kod gönderilemedi'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusSM,
          ),
        ),
      );
    }
  }

  Future<void> _navigateWithAuthCheck(
    BuildContext context,
    Widget page,
    String message,
  ) async {
    if (!_authService.isLoggedIn) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => LoginPage(redirectMessage: message)),
      );
      if (result != true || !mounted) return;
    }

    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Hesabım',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Ayarlar
            },
            icon: Icon(Icons.settings_outlined, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Kullanıcı bilgileri
            _buildUserHeader(context),
            SizedBox(height: AppSpacing.md),
            // Menü öğeleri
            _buildMenuSection(
              title: 'Siparişlerim',
              items: [
                _MenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Siparişlerim',
                  onTap: () => _navigateWithAuthCheck(
                    context,
                    const OrdersPage(),
                    'Siparişlerinizi görmek için giriş yapın',
                  ),
                ),
                _MenuItem(
                  icon: Icons.local_shipping_outlined,
                  title: 'Kargo Takibi',
                  onTap: () => _navigateWithAuthCheck(
                    context,
                    const CargoTrackingPage(),
                    'Kargo takibi için giriş yapın',
                  ),
                ),
                _MenuItem(
                  icon: Icons.replay,
                  title: 'İade Taleplerim',
                  onTap: () => _navigateWithAuthCheck(
                    context,
                    const ReturnsPage(),
                    'İade taleplerinizi görmek için giriş yapın',
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            _buildMenuSection(
              title: 'Hesap Bilgilerim',
              items: [
                _MenuItem(
                  icon: Icons.person_outline,
                  title: 'Profil Bilgilerim',
                  onTap: () => _navigateWithAuthCheck(
                    context,
                    const ProfileInfoPage(),
                    'Profil bilgilerinizi görmek için giriş yapın',
                  ),
                ),
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Adreslerim',
                  onTap: () => _navigateWithAuthCheck(
                    context,
                    const AddressesPage(),
                    'Adreslerinizi görmek için giriş yapın',
                  ),
                ),
                _MenuItem(
                  icon: Icons.credit_card_outlined,
                  title: 'Kayıtlı Kartlarım',
                  onTap: () => _navigateWithAuthCheck(
                    context,
                    const SavedCardsPage(),
                    'Kayıtlı kartlarınızı görmek için giriş yapın',
                  ),
                ),
                _MenuItem(
                  icon: Icons.lock_outline,
                  title: 'Şifre Değiştir',
                  onTap: () => _navigateWithAuthCheck(
                    context,
                    const ChangePasswordPage(),
                    'Şifre değiştirmek için giriş yapın',
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            _buildMenuSection(
              title: 'Diğer',
              items: [
                _MenuItem(
                  icon: Icons.help_outline,
                  title: 'Yardım & Destek',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpSupportPage()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.description_outlined,
                  title: 'Yasal Bilgiler',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LegalInfoPage()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.info_outline,
                  title: 'Hakkımızda',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutPage()),
                  ),
                ),
                if (_authService.isLoggedIn)
                  _MenuItem(
                    icon: Icons.delete_forever_outlined,
                    title: 'Hesabı Sil',
                    onTap: _deleteAccount,
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            // Çıkış yap butonu
            _buildLogoutButton(context),
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    final isLoggedIn = _authService.isLoggedIn;
    final user = _authService.currentUser;

    // Görüntülenecek isim
    String displayName = 'Kullanıcı';
    if (user != null) {
      displayName = user.displayName;
    }

    // Görüntülenecek email/telefon
    String subtitle = 'Giriş yaparak siparişlerinizi takip edebilirsiniz.';
    if (isLoggedIn && user != null) {
      subtitle = user.email ?? user.phone ?? '';
    }

    // Profil fotoğrafı için baş harf
    String initial = 'K';
    if (user?.fullName != null && user!.fullName!.isNotEmpty) {
      initial = user.fullName!.substring(0, 1).toUpperCase();
    } else if (user?.userName != null && user!.userName!.isNotEmpty) {
      initial = user.userName!.substring(0, 1).toUpperCase();
    }

    return GestureDetector(
      onTap: () {
        if (isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileInfoPage()),
          );
        } else {
          _navigateToLogin();
        }
      },
      child: Container(
        color: AppColors.surface,
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: _isLoadingUser
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : isLoggedIn
                  ? (user?.profilePhoto != null &&
                            user!.profilePhoto!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              user.profilePhoto!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  initial,
                                  style: AppTypography.h2.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initial,
                              style: AppTypography.h2.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ))
                  : Icon(Icons.person, size: 36, color: AppColors.primary),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _isLoadingUser
                      ? Container(
                          width: 120,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: AppRadius.borderRadiusSM,
                          ),
                        )
                      : Text(
                          isLoggedIn ? displayName : 'Giriş Yap',
                          style: AppTypography.h4,
                        ),
                  SizedBox(height: AppSpacing.xs),
                  _isLoadingUser
                      ? Container(
                          width: 180,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: AppRadius.borderRadiusSM,
                          ),
                        )
                      : Text(
                          subtitle,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                 if (user?.isApproved != null) ...[
            SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: user!.isApproved! ? null : () => _startEmailVerification(user),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: user.isApproved! ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                  borderRadius: AppRadius.borderRadiusSM,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      user.isApproved! ? Icons.verified : Icons.warning_amber_rounded,
                      size: 16,
                      color: user.isApproved! ? AppColors.success : AppColors.warning,
                    ),
                    SizedBox(width: 4),
                    Text(
                      user.isApproved! ? 'E-posta Doğrulandı' : 'E-posta Doğrulanmadı',
                      style: AppTypography.labelSmall.copyWith(
                        color: user.isApproved! ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!user.isApproved!) ...[
                      SizedBox(width: 4),
                      Icon(
                        Icons.touch_app,
                        size: 14,
                        color: AppColors.warning,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
                ],
              ),
            ),
            Icon(
              isLoggedIn ? Icons.chevron_right : Icons.login,
              color: isLoggedIn ? AppColors.textTertiary : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...items.map((item) => _buildMenuItem(item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(borderRadius: AppRadius.borderRadiusSM),
              child: Icon(item.icon, color: AppColors.textSecondary, size: 20),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(child: Text(item.title, style: AppTypography.bodyMedium)),
            SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final isLoggedIn = _authService.isLoggedIn;

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        child: isLoggedIn
            ? OutlinedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout, color: AppColors.error),
                label: Text(
                  'Çıkış Yap',
                  style: AppTypography.buttonMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  side: BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusSM,
                  ),
                ),
              )
            : ElevatedButton.icon(
                onPressed: _navigateToLogin,
                icon: const Icon(Icons.login, color: Colors.white),
                label: Text(
                  'Giriş Yap',
                  style: AppTypography.buttonMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusSM,
                  ),
                ),
              ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem({required this.icon, required this.title, required this.onTap});
}
