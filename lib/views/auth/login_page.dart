import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginPage extends StatefulWidget {
  final String? redirectMessage;

  const LoginPage({super.key, this.redirectMessage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

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
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
    _animationController.reset();
    _animationController.forward();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    final authViewModel = AuthViewModel();

    if (_isLogin) {
      // Login işlemi
      final success = await authViewModel.login(
        userName: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        HapticFeedback.heavyImpact();
        Navigator.pop(context, true);
      } else if (mounted) {
        // API'den gelen hata mesajını göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage ?? 'Giriş başarısız'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        );
      }
    } else {
      // Register işlemi - TODO: API entegrasyonu yapılacak
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Kayıt işlemi henüz aktif değil'),
            backgroundColor: AppColors.warning,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/logo.png',
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 60,
                          width: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: AppRadius.borderRadiusMD,
                          ),
                          child: Center(
                            child: Text(
                              'SARAÇOĞLU',
                              style: AppTypography.h4.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: AppSpacing.xxl),

                  // Başlık
                  Text(
                    _isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                    style: AppTypography.h2,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: AppSpacing.sm),

                  Text(
                    _isLogin
                        ? 'Hesabınıza giriş yaparak alışverişe başlayın'
                        : 'Yeni bir hesap oluşturarak avantajlardan yararlanın',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: AppSpacing.xxl),

                  // Ad Soyad (Sadece kayıt için)
                  if (!_isLogin) ...[
                    _buildTextField(
                      controller: _nameController,
                      label: 'Ad Soyad',
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: AppSpacing.md),
                  ],

                  // E-posta
                  _buildTextField(
                    controller: _emailController,
                    label: 'Kullanıcı Adı',
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.text,
                  ),

                  SizedBox(height: AppSpacing.md),

                  // Telefon (Sadece kayıt için)
                  if (!_isLogin) ...[
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Telefon',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: AppSpacing.md),
                  ],

                  // Şifre
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Şifre',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),

                  // Şifre Tekrar (Sadece kayıt için)
                  if (!_isLogin) ...[
                    SizedBox(height: AppSpacing.md),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Şifre Tekrar',
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: AppSpacing.md),

                  // Beni Hatırla & Şifremi Unuttum (Sadece giriş için)
                  if (_isLogin) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) => setState(
                                  () => _rememberMe = value ?? false,
                                ),
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Text(
                              'Beni Hatırla',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text(
                            'Şifremi Unuttum',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                  ],

                  SizedBox(height: AppSpacing.md),

                  // Giriş/Kayıt Butonu
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusMD,
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              _isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                              style: AppTypography.buttonLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.xl),

                  // Ayırıcı
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          'veya',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),

                  SizedBox(height: AppSpacing.xl),

                  // Sosyal Giriş Butonları
                  _buildSocialButton(
                    icon: Icons.g_mobiledata,
                    label: 'Google ile devam et',
                    onPressed: () {
                      // TODO: Google Sign In
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Google ile giriş yakında aktif olacak',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),

                  SizedBox(height: AppSpacing.md),

                  _buildSocialButton(
                    icon: Icons.apple,
                    label: 'Apple ile devam et',
                    onPressed: () {
                      // TODO: Apple Sign In
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Apple ile giriş yakında aktif olacak'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),

                  SizedBox(height: AppSpacing.xxl),

                  // Mod değiştirme
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? 'Hesabınız yok mu?'
                            : 'Zaten hesabınız var mı?',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: _toggleMode,
                        child: Text(
                          _isLogin ? 'Kayıt Ol' : 'Giriş Yap',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface,
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
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMD,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMD,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMD),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTypography.buttonMedium),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMD),
        title: Text('Şifre Sıfırlama', style: AppTypography.h4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'E-posta adresinizi girin, şifre sıfırlama bağlantısı göndereceğiz.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(
                  borderRadius: AppRadius.borderRadiusSM,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                Navigator.pop(context);
               
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        
                             'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi'
                             'Bir hata oluştu',
                      ),
                      backgroundColor: 
                       AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Gönder'),
          ),
        ],
      ),
    );
  }
}
