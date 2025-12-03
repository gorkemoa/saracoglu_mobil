import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../models/user/user_model.dart';
import '../../models/user/update_user_model.dart';
import '../../models/auth/send_verification_code_model.dart';
import '../auth/code_verification_page.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String? _selectedGender;
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _authService.addListener(_onUserChanged);
    // Her girişte güncel kullanıcı bilgilerini getir
    _refreshUserData();
  }

  /// Kullanıcı bilgilerini API'den yenile
  Future<void> _refreshUserData() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) return;
    
    setState(() => _isLoading = true);
    await _authService.getUser(userId);
    
    if (mounted) {
      _updateControllersFromUser();
      setState(() => _isLoading = false);
    }
  }

  void _initControllers() {
    final user = _authService.currentUser;

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _selectedGender = user?.gender;
    _selectedBirthDate = _parseBirthday(user?.birthday);
  }

  DateTime? _parseBirthday(String? birthday) {
    if (birthday == null || birthday.isEmpty) return null;
    try {
      // Format: "01.12.2025"
      final parts = birthday.split('.');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      // Parse hatası
    }
    return null;
  }

  void _onUserChanged() {
    if (mounted && !_isEditing) {
      _updateControllersFromUser();
      setState(() {});
    }
  }

  void _updateControllersFromUser() {
    final user = _authService.currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone ?? '';
      _selectedGender = user.gender;
      _selectedBirthDate = _parseBirthday(user.birthday);
    }
  }

  @override
  void dispose() {
    _authService.removeListener(_onUserChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  UserModel? get _user => _authService.currentUser;

  /// E-posta doğrulama başlat
  Future<void> _startEmailVerification(UserModel user) async {
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
        _refreshUserData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            backgroundColor: AppColors.surface,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 2,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            title: Text(
              'Profil Bilgilerim',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: true,
            actions: [
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: AppSpacing.md),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () {
                    if (_isEditing) {
                      _saveProfile();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                  child: Text(
                    _isEditing ? 'Kaydet' : 'Düzenle',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),

          // Profil Avatarı
          SliverToBoxAdapter(child: _buildProfileAvatar()),

          // Form
          SliverToBoxAdapter(child: _buildProfileForm()),

          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final user = _user;

    // Baş harfler
    String initials = 'K';
    if (user?.fullName != null && user!.fullName!.isNotEmpty) {
      final names = user.fullName!.split(' ');
      if (names.length >= 2) {
        initials = '${names[0][0]}${names[1][0]}';
      } else {
        initials = user.fullName!.substring(0, 1);
      }
    } else if (user?.firstName != null && user?.lastName != null) {
      initials = '${user!.firstName![0]}${user.lastName![0]}';
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          user.profilePhoto!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              initials.toUpperCase(),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          initials.toUpperCase(),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
              if (_isEditing)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // TODO: Fotoğraf değiştirme işlemi
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(user?.displayName ?? 'Kullanıcı', style: AppTypography.h4),
          if (user?.email != null && user!.email!.isNotEmpty)
            Text(
              user.email!,
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
    );
  }

  Widget _buildProfileForm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kişisel Bilgiler',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Ad
            _buildTextField(
              label: 'Ad',
              controller: _firstNameController,
              icon: Icons.person_outline,
              enabled: _isEditing,
            ),
            SizedBox(height: AppSpacing.md),

            // Soyad
            _buildTextField(
              label: 'Soyad',
              controller: _lastNameController,
              icon: Icons.person_outline,
              enabled: _isEditing,
            ),
            SizedBox(height: AppSpacing.md),

            // E-posta
            _buildTextField(
              label: 'E-posta',
              controller: _emailController,
              icon: Icons.email_outlined,
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: AppSpacing.md),

            // Telefon
            _buildTextField(
              label: 'Telefon',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: AppSpacing.md),

            // Cinsiyet
            _buildGenderSelector(),
            SizedBox(height: AppSpacing.md),

            // Doğum Tarihi
            _buildBirthDateSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 20,
              color: enabled ? AppColors.primary : AppColors.textTertiary,
            ),
            filled: true,
            fillColor: enabled
                ? AppColors.background
                : AppColors.background.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusSM,
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusSM,
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusSM,
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusSM,
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cinsiyet',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(child: _buildGenderOption('Erkek', Icons.male)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildGenderOption('Kadın', Icons.female)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildGenderOption('Belirtilmemiş', Icons.person_outline)),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: _isEditing
          ? () {
              HapticFeedback.lightImpact();
              setState(() => _selectedGender = gender);
            }
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.background,
          borderRadius: AppRadius.borderRadiusSM,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
            SizedBox(height: 4),
            Text(
              gender == 'Belirtilmemiş' ? 'Diğer' : gender,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Doğum Tarihi',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: _isEditing ? () => _selectBirthDate() : null,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: _isEditing
                  ? AppColors.background
                  : AppColors.background.withOpacity(0.5),
              borderRadius: AppRadius.borderRadiusSM,
              border: Border.all(
                color: _isEditing
                    ? AppColors.border
                    : AppColors.border.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: _isEditing
                      ? AppColors.primary
                      : AppColors.textTertiary,
                ),
                SizedBox(width: AppSpacing.md),
                Text(
                  _selectedBirthDate != null
                      ? _formatDate(_selectedBirthDate!)
                      : 'Seçiniz',
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedBirthDate != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
                Spacer(),
                if (_isEditing)
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  Future<void> _saveProfile() async {
    HapticFeedback.heavyImpact();

    setState(() {
      _isLoading = true;
      _isEditing = false;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı bilgisi bulunamadı');
      }

      // Cinsiyet koduna dönüştür
      int? genderCode;
      if (_selectedGender == 'Erkek') {
        genderCode = 1;
      } else if (_selectedGender == 'Kadın') {
        genderCode = 2;
      } else if (_selectedGender == 'Belirtilmemiş') {
        genderCode = 3;
      }

      final request = UpdateUserRequest(
        userToken: user.token,
        userFirstname: _firstNameController.text,
        userLastname: _lastNameController.text,
        userEmail: _emailController.text,
        userPhone: _phoneController.text,
        userBirthday: _selectedBirthDate != null ? _formatDate(_selectedBirthDate!) : null,
        userGender: genderCode,
      );

      final response = await _authService.updateUserInfo(user.id, request);

      setState(() => _isLoading = false);

      if (mounted) {
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text('Profil bilgileriniz güncellendi'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Güncelleme başarısız'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
