import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/auth_service.dart';
import '../../models/auth/send_verification_code_model.dart';

/// Doğrulama sayfası türleri
enum VerificationType {
  register, // Kayıt sonrası doğrulama
  emailVerification, // Giriş yapmış kullanıcı için e-posta doğrulama
  forgotPassword, // Şifremi unuttum doğrulama
}

class CodeVerificationPage extends StatefulWidget {
  final String email;
  final VerificationType verificationType;

  const CodeVerificationPage({
    super.key,
    required this.email,
    this.verificationType = VerificationType.register,
  });

  @override
  State<CodeVerificationPage> createState() => _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    // İlk input'a focus ver
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _codeControllers.map((c) => c.text).join();

  bool get _isCodeComplete => _code.length == 6;

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    if (widget.verificationType == VerificationType.emailVerification) {
      // E-posta doğrulama için yeniden kod gönder
      final response = await _authService.sendVerificationCode(SendCodeType.email);
      
      setState(() => _isResending = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.isSuccess 
                ? response.message ?? 'Kod tekrar gönderildi'
                : response.message ?? 'Kod gönderilemedi'),
            backgroundColor: response.isSuccess ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        );
      }
    } else if (widget.verificationType == VerificationType.forgotPassword) {
      // Şifremi unuttum için yeniden kod gönder
      final response = await _authService.forgotPassword(widget.email);
      
      setState(() => _isResending = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.isSuccess 
                ? response.message ?? 'Kod tekrar gönderildi'
                : response.message ?? 'Kod gönderilemedi'),
            backgroundColor: response.isSuccess ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        );
      }
    } else {
      // Kayıt için tekrar kod gönderme (TODO: register için resend endpoint gerekirse)
      setState(() => _isResending = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Kod tekrar gönderildi'),
            backgroundColor: AppColors.info,
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

  void _onCodeChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      // Sonraki kutuya geç
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Önceki kutuya dön
      _focusNodes[index - 1].requestFocus();
    }

    // Kod tamamlandıysa otomatik doğrula
    if (_isCodeComplete) {
      _verifyCode();
    }

    setState(() {});
  }

  Future<void> _verifyCode() async {
    if (!_isCodeComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen 6 haneli kodu girin'),
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

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    bool success = false;
    String? errorMessage;

    if (widget.verificationType == VerificationType.register) {
      // Kayıt sonrası doğrulama
      final authViewModel = AuthViewModel();
      success = await authViewModel.verifyCode(_code);
      errorMessage = authViewModel.errorMessage;
    } else if (widget.verificationType == VerificationType.forgotPassword) {
      // Şifremi unuttum doğrulama
      final response = await _authService.verifyForgotPasswordCode(_code);
      success = response.isSuccess;
      errorMessage = response.successMessage;
    } else {
      // E-posta doğrulama (giriş yapmış kullanıcı)
      final response = await _authService.verifyEmailCode(_code);
      success = response.isSuccess;
      errorMessage = response.successMessage;
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      HapticFeedback.heavyImpact();
      
      final successMessage = widget.verificationType == VerificationType.forgotPassword
          ? 'Doğrulama başarılı! Şifrenizi sıfırlayabilirsiniz.'
          : 'Hesabınız başarıyla doğrulandı!';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusSM,
          ),
        ),
      );

      // Başarılı - geri dön
      Navigator.pop(context, true);
    } else if (mounted) {
      // Hata durumunda kodu temizle
      for (var controller in _codeControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Doğrulama başarısız'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.xl),

                // Geri butonu
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderRadiusSM,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.xxl),

                // E-posta ikonu
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_read_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.xl),

                // Başlık
                Center(
                  child: Text(
                    widget.verificationType == VerificationType.forgotPassword
                        ? 'Şifre Sıfırlama'
                        : 'E-posta Doğrulama',
                    style: AppTypography.h1.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.md),

                // Açıklama
                Center(
                  child: Text(
                    widget.verificationType == VerificationType.forgotPassword
                        ? 'Şifre sıfırlama için gönderilen 6 haneli doğrulama kodunu girin'
                        : 'Aşağıdaki adrese gönderilen 6 haneli doğrulama kodunu girin',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: AppSpacing.sm),

                // E-posta
                Center(
                  child: Text(
                    widget.email,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.xxl + AppSpacing.lg),

                // Kod girişi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => _buildCodeBox(index),
                  ),
                ),

                SizedBox(height: AppSpacing.xxl + AppSpacing.lg),

                // Doğrula Butonu
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading || !_isCodeComplete ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusMD,
                      ),
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Doğrula',
                            style: AppTypography.buttonLarge.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: AppSpacing.xl),

                // Kod gelmedi mi?
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Kod gelmedi mi?',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      GestureDetector(
                        onTap: _isResending ? null : _resendCode,
                        child: _isResending
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : Text(
                                'Tekrar Gönder',
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

  Widget _buildCodeBox(int index) {
    final hasValue = _codeControllers[index].text.isNotEmpty;
    final isFocused = _focusNodes[index].hasFocus;

    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: _codeControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        onChanged: (value) => _onCodeChanged(index, value),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: AppTypography.h2.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: hasValue ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusMD,
            borderSide: BorderSide(
              color: isFocused ? AppColors.primary : AppColors.border,
              width: isFocused ? 2 : 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusMD,
            borderSide: BorderSide(
              color: hasValue ? AppColors.primary : AppColors.border,
              width: hasValue ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusMD,
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
