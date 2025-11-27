import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/delivery_address.dart';

/// Yeni adres ekleme bottom sheet widget'ı
class AddNewAddressSheet extends StatefulWidget {
  final Function(DeliveryAddress) onAddressAdded;

  const AddNewAddressSheet({super.key, required this.onAddressAdded});

  @override
  State<AddNewAddressSheet> createState() => _AddNewAddressSheetState();
}

class _AddNewAddressSheetState extends State<AddNewAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedCity = 'İstanbul';
  String _selectedDistrict = 'Kadıköy';
  String _selectedAddressType = 'Ev';
  bool _isDefault = false;
  bool _isSaving = false;

  // Demo şehir ve ilçe verileri - gerçek uygulamada API'den gelecek
  final Map<String, List<String>> _cityDistricts = {
    'İstanbul': ['Kadıköy', 'Beşiktaş', 'Üsküdar', 'Maltepe', 'Ataşehir', 'Bakırköy', 'Fatih', 'Beyoğlu', 'Şişli', 'Kartal'],
    'Ankara': ['Çankaya', 'Keçiören', 'Yenimahalle', 'Mamak', 'Etimesgut', 'Sincan', 'Altındağ', 'Pursaklar'],
    'İzmir': ['Konak', 'Karşıyaka', 'Bornova', 'Buca', 'Çiğli', 'Bayraklı', 'Gaziemir', 'Narlıdere'],
    'Antalya': ['Muratpaşa', 'Kepez', 'Konyaaltı', 'Alanya', 'Manavgat', 'Serik', 'Kaş'],
    'Bursa': ['Osmangazi', 'Nilüfer', 'Yıldırım', 'Mudanya', 'Gemlik', 'İnegöl'],
    'Muğla': ['Bodrum', 'Fethiye', 'Marmaris', 'Milas', 'Datça', 'Dalaman'],
  };

  final List<Map<String, dynamic>> _addressTypes = [
    {'title': 'Ev', 'icon': Icons.home_outlined},
    {'title': 'İş', 'icon': Icons.business_outlined},
    {'title': 'Yazlık', 'icon': Icons.villa_outlined},
    {'title': 'Diğer', 'icon': Icons.location_on_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _titleController.text = _selectedAddressType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fullAddressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();

    // Simüle edilmiş API çağrısı
    await Future.delayed(const Duration(milliseconds: 800));

    final newAddress = DeliveryAddress(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      fullAddress: _fullAddressController.text.trim(),
      city: _selectedCity,
      district: _selectedDistrict,
      phone: _phoneController.text.trim(),
      isDefault: _isDefault,
    );

    setState(() => _isSaving = false);
    if (mounted) {
      Navigator.pop(context);
      widget.onAddressAdded(newAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              _buildHeader(),
              Divider(height: 1, color: AppColors.divider),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.sm),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: AppRadius.borderRadiusRound,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: AppRadius.borderRadiusSM,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.xs),
              child: Icon(Icons.close, color: AppColors.textSecondary, size: 24),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Yeni Adres Ekle',
              style: AppTypography.h4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Flexible(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddressTypeSelector(),
              SizedBox(height: AppSpacing.xl),
              _buildAddressTitleField(),
              SizedBox(height: AppSpacing.lg),
              _buildCityDistrictRow(),
              SizedBox(height: AppSpacing.lg),
              _buildFullAddressField(),
              SizedBox(height: AppSpacing.lg),
              _buildPhoneField(),
              SizedBox(height: AppSpacing.xl),
              _buildDefaultSwitch(),
              SizedBox(height: AppSpacing.xxl),
              _buildSaveButton(),
              SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adres Tipi',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: _addressTypes.map((type) {
            final isSelected = _selectedAddressType == type['title'];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: type != _addressTypes.last ? AppSpacing.sm : 0,
                ),
                child: _buildAddressTypeButton(type, isSelected),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddressTypeButton(Map<String, dynamic> type, bool isSelected) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedAddressType = type['title'] as String;
          if (_titleController.text == 'Ev' ||
              _titleController.text == 'İş' ||
              _titleController.text == 'Yazlık' ||
              _titleController.text == 'Diğer') {
            _titleController.text = type['title'] as String;
          }
        });
      },
      borderRadius: AppRadius.borderRadiusSM,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.background,
          borderRadius: AppRadius.borderRadiusSM,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              type['icon'] as IconData,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            SizedBox(height: 4),
            Text(
              type['title'] as String,
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

  Widget _buildAddressTitleField() {
    return _buildTextField(
      controller: _titleController,
      label: 'Adres Başlığı',
      hint: 'örn: Ev, İş, Annemin Evi',
      prefixIcon: Icons.label_outline,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Adres başlığı gereklidir';
        }
        return null;
      },
    );
  }

  Widget _buildCityDistrictRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdownField(
            label: 'İl',
            value: _selectedCity,
            items: _cityDistricts.keys.toList(),
            onChanged: (value) {
              setState(() {
                _selectedCity = value!;
                _selectedDistrict = _cityDistricts[value]!.first;
              });
            },
            prefixIcon: Icons.location_city_outlined,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildDropdownField(
            label: 'İlçe',
            value: _selectedDistrict,
            items: _cityDistricts[_selectedCity]!,
            onChanged: (value) {
              setState(() {
                _selectedDistrict = value!;
              });
            },
            prefixIcon: Icons.map_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildFullAddressField() {
    return _buildTextField(
      controller: _fullAddressController,
      label: 'Açık Adres',
      hint: 'Mahalle, sokak, bina no, daire no',
      prefixIcon: Icons.home_outlined,
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Açık adres gereklidir';
        }
        if (value.trim().length < 10) {
          return 'Lütfen daha detaylı bir adres girin';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      controller: _phoneController,
      label: 'Telefon Numarası',
      hint: '05XX XXX XX XX',
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Telefon numarası gereklidir';
        }
        final phoneRegex = RegExp(r'^[0-9]{10,11}$');
        final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
        if (!phoneRegex.hasMatch(cleanPhone)) {
          return 'Geçerli bir telefon numarası girin';
        }
        return null;
      },
    );
  }

  Widget _buildDefaultSwitch() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.borderRadiusSM,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isDefault ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
              borderRadius: AppRadius.borderRadiusXS,
            ),
            child: Icon(
              Icons.star_outline,
              color: _isDefault ? AppColors.primary : AppColors.textTertiary,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Varsayılan Adres',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Bu adresi varsayılan teslimat adresi olarak ayarla',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: _isDefault,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _isDefault = value);
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveAddress,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusSM,
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, color: Colors.white, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Adresi Kaydet',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: AppColors.textTertiary),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
              child: Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
            contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            filled: true,
            fillColor: AppColors.background,
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
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusSM,
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusSM,
              borderSide: BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadius.borderRadiusSM,
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: value,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
                  child: Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
                ),
                prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                border: InputBorder.none,
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
              isExpanded: true,
              dropdownColor: AppColors.surface,
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        ),
      ],
    );
  }
}
