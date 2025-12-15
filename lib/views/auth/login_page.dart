import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/auth_service.dart';
import '../main_screen.dart';
import 'register_page.dart';
import 'code_verification_page.dart';

class LoginPage extends StatefulWidget {
  final String? redirectMessage;
  final bool fromSessionExpired;

  const LoginPage({
    super.key,
    this.redirectMessage,
    this.fromSessionExpired = false,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    // Yönlendirme mesajını göster
    if (widget.redirectMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.redirectMessage!),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Boş alan kontrolü
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen tüm alanları doldurun'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    final authViewModel = AuthViewModel();

    final success = await authViewModel.login(
      userName: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      HapticFeedback.heavyImpact();

      // Oturum süresi dolmuşsa MainScreen'e yönlendir, değilse pop yap
      if (widget.fromSessionExpired) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      } else {
        Navigator.pop(context, true);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Giriş başarısız'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.xxl * 3),

                // Logo
                Image.asset('assets/logo.png', height: 50, fit: BoxFit.contain),

                SizedBox(height: AppSpacing.xxl + AppSpacing.lg),

                // Kullanıcı adı
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Kullanıcı Adı',
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.borderRadiusMD,
                    boxShadow: AppShadows.shadowSM,
                  ),
                  child: TextField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    style: AppTypography.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Kullanıcı adınızı girin',
                      hintStyle: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md + 4,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.borderRadiusMD,
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.borderRadiusMD,
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.borderRadiusMD,
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.lg),

                // Şifre
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Şifre',
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.borderRadiusMD,
                    boxShadow: AppShadows.shadowSM,
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _login(),
                    style: AppTypography.bodyLarge,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md + 4,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.borderRadiusMD,
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.borderRadiusMD,
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.borderRadiusMD,
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.md),

                // Şifremi unuttum
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordSheet,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppColors.primary,
                    ),
                    child: Text(
                      'Şifremi Unuttum',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.xxl),

                // Giriş Yap Butonu
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.borderRadiusMD,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusMD,
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Giriş Yap',
                            style: AppTypography.buttonLarge.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: AppSpacing.xxl),

                // Sosyal Medya Ayırıcı
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, AppColors.border],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'veya',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.border, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.xl),

                // Google ile Giriş
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.borderRadiusMD,
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppShadows.shadowSM,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              // AuthViewModel yeni instance oluşturuluyor, bu sayfada provider yoksa mecbur.
                              // Eğer main.dart'ta provider varsa context.read<AuthViewModel> yapılmalı ama
                              // burada setState kullanılmış ve viewmodel yerel gibi duruyor.
                              // AuthViewModel login sayfasında nasıl kullanılmış?
                              // Line 79: final authViewModel = AuthViewModel();
                              // Evet yerel oluşturuluyor.
                              final authViewModel = AuthViewModel();
                              final success = await authViewModel
                                  .loginWithGoogle();
                              setState(() => _isLoading = false);

                              if (success && mounted) {
                                Navigator.pop(context, true);
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      authViewModel.errorMessage ??
                                          'Google ile giriş başarısız',
                                    ),
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(AppSpacing.md),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.borderRadiusSM,
                                    ),
                                  ),
                                );
                              }
                            },
                      borderRadius: AppRadius.borderRadiusMD,
                      child: Container(
                        height: 56,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/google.png',
                              width: 40,
                              height: 40,
                            ),
                            SizedBox(width: AppSpacing.md),
                            Text(
                              'Google ile Giriş Yap',
                              style: AppTypography.buttonMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                if (Platform.isIOS) ...[
                  SizedBox(height: AppSpacing.md),
                  // Apple ile Giriş
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: AppRadius.borderRadiusMD,
                      boxShadow: AppShadows.shadowSM,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);
                                final authViewModel = AuthViewModel();
                                final success = await authViewModel
                                    .loginWithApple();
                                setState(() => _isLoading = false);

                                if (success && mounted) {
                                  Navigator.pop(context, true);
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        authViewModel.errorMessage ??
                                            'Apple ile giriş başarısız',
                                      ),
                                      backgroundColor: AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(AppSpacing.md),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: AppRadius.borderRadiusSM,
                                      ),
                                    ),
                                  );
                                }
                              },
                        borderRadius: AppRadius.borderRadiusMD,
                        child: Container(
                          height: 56,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.apple, color: Colors.white, size: 28),
                              SizedBox(width: AppSpacing.md),
                              Text(
                                'Apple ile Giriş Yap',
                                style: AppTypography.buttonMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: AppSpacing.xxl),

                // Kayıt ol linki
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hesabınız yok mu? ',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );

                          if (result == true && mounted) {
                            // Kayıt başarılı, login sayfasını da kapat
                            Navigator.pop(context, true);
                          }
                        },
                        child: Text(
                          'Kayıt Ol',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordSheet() {
    final emailController = TextEditingController();
    bool isLoading = false;
    final authService = AuthService();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: AppRadius.borderRadiusRound,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  Text('Şifre Sıfırlama', style: AppTypography.h3),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'E-posta adresinizi girin, şifre sıfırlama doğrulama kodu göndereceğiz.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  SizedBox(height: AppSpacing.xl),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTypography.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'E-posta adresiniz',
                      hintStyle: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md + 4,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.borderRadiusMD,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.borderRadiusMD,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.borderRadiusMD,
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (emailController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Lütfen e-posta adresinizi girin',
                                    ),
                                    backgroundColor: AppColors.warning,
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(AppSpacing.md),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.borderRadiusSM,
                                    ),
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isLoading = true);

                              final response = await authService.forgotPassword(
                                emailController.text.trim(),
                              );

                              setModalState(() => isLoading = false);

                              if (response.isSuccess && context.mounted) {
                                // Bottom sheet'i kapat
                                Navigator.pop(context);

                                // Kapat sonra mesaj göster
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        response.message ??
                                            'Doğrulama kodu gönderildi',
                                      ),
                                      backgroundColor: AppColors.success,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(AppSpacing.md),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: AppRadius.borderRadiusSM,
                                      ),
                                    ),
                                  );
                                }

                                // Doğrulama sayfasına yönlendir
                                if (mounted) {
                                  final verified = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CodeVerificationPage(
                                            email: emailController.text.trim(),
                                            verificationType:
                                                VerificationType.forgotPassword,
                                          ),
                                    ),
                                  );

                                  if (verified == true && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Şifreniz sıfırlandı. Yeni şifreniz e-posta adresinize gönderildi.',
                                        ),
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(AppSpacing.md),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              AppRadius.borderRadiusSM,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              } else if (context.mounted) {
                                // API'den gelen hata mesajını göster (417, 400 vs.)
                                // Bottom sheet'i kapat
                                Navigator.pop(context);

                                // Kapat sonra mesaj göster
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        response.message ?? 'İşlem başarısız',
                                      ),
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
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusMD,
                        ),
                        disabledBackgroundColor: AppColors.primary.withOpacity(
                          0.6,
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Gönder',
                              style: AppTypography.buttonMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.md),

                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Vazgeç',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
