import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/delivery_address.dart';
import '../models/address/add_address_model.dart';
import '../models/location/location_model.dart';
import '../services/address_service.dart';
import '../services/location_service.dart';

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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _invoiceAddressController = TextEditingController();
  final _identityNumberController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _taxAdministrationController = TextEditingController();

  // Seçili değerler
  City? _selectedCity;
  District? _selectedDistrict;
  Neighbourhood? _selectedNeighbourhood;
  String _selectedAddressType = 'Ev';
  String _invoiceType = AddressType.individual; // '1' Bireysel varsayılan
  bool _isDefault = false;
  bool _isSaving = false;
  String? _errorMessage;

  // Listeler
  List<City> _cities = [];
  List<District> _districts = [];
  List<Neighbourhood> _neighbourhoods = [];

  // Loading states
  bool _isLoadingCities = true;
  bool _isLoadingDistricts = false;
  bool _isLoadingNeighbourhoods = false;

  final _addressService = AddressService();
  final _locationService = LocationService();

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

    // Şehirleri yükle
    _loadCities();
  }

  Future<void> _loadCities() async {
    setState(() => _isLoadingCities = true);
    final response = await _locationService.getCities();
    if (response.isSuccess && mounted) {
      setState(() {
        _cities = response.cities;
        _isLoadingCities = false;
        // Varsayılan olarak seçili değil - kullanıcı seçecek
        _selectedCity = null;
      });
    } else if (mounted) {
      setState(() => _isLoadingCities = false);
    }
  }

  Future<void> _loadDistricts(int cityNo) async {
    setState(() {
      _isLoadingDistricts = true;
      _selectedDistrict = null;
      _districts = [];
      _selectedNeighbourhood = null;
      _neighbourhoods = [];
    });

    final response = await _locationService.getDistricts(cityNo);
    if (response.isSuccess && mounted) {
      setState(() {
        _districts = response.districts;
        _isLoadingDistricts = false;
        // Varsayılan olarak seçili değil - kullanıcı seçecek
        _selectedDistrict = null;
      });
    } else if (mounted) {
      setState(() => _isLoadingDistricts = false);
    }
  }

  Future<void> _loadNeighbourhoods(int districtNo) async {
    setState(() {
      _isLoadingNeighbourhoods = true;
      _selectedNeighbourhood = null;
      _neighbourhoods = [];
    });

    final response = await _locationService.getNeighbourhoods(districtNo);
    if (response.isSuccess && mounted) {
      setState(() {
        _neighbourhoods = response.neighbourhoods;
        _isLoadingNeighbourhoods = false;
        // Varsayılan olarak seçili değil - kullanıcı seçecek
        _selectedNeighbourhood = null;
      });
    } else if (mounted) {
      setState(() => _isLoadingNeighbourhoods = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fullAddressController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _postalCodeController.dispose();
    _invoiceAddressController.dispose();
    _identityNumberController.dispose();
    _companyNameController.dispose();
    _taxNumberController.dispose();
    _taxAdministrationController.dispose();
    super.dispose();
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCity == null || _selectedDistrict == null) {
      setState(() => _errorMessage = 'Lütfen il ve ilçe seçin');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    HapticFeedback.lightImpact();

    try {
      final request = AddAddressRequest(
        userToken: _addressService.userToken ?? '',
        userFirstName: _firstNameController.text.trim(),
        userLastName: _lastNameController.text.trim(),
        addressTitle: _titleController.text.trim(),
        addressType: _invoiceType,
        addressPhone: _phoneController.text.trim(),
        addressEmail: _emailController.text.trim(),
        addressCityID: _selectedCity!.no.toString(),
        addressDistrictID: _selectedDistrict!.no.toString(),
        addressNeighbourhoodID: _selectedNeighbourhood?.no ?? '0',
        address: _fullAddressController.text.trim(),
        invoiceAddress: _invoiceAddressController.text.trim().isNotEmpty
            ? _invoiceAddressController.text.trim()
            : _fullAddressController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        identityNumber: _invoiceType == AddressType.individual
            ? _identityNumberController.text.trim()
            : '',
        realCompanyName: _invoiceType == AddressType.corporate
            ? _companyNameController.text.trim()
            : '',
        taxNumber: _invoiceType == AddressType.corporate
            ? _taxNumberController.text.trim()
            : '',
        taxAdministration: _invoiceType == AddressType.corporate
            ? _taxAdministrationController.text.trim()
            : '',
      );

      final response = await _addressService.addAddress(request);

      if (response.isSuccess) {
        final newAddress = DeliveryAddress(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          fullAddress: _fullAddressController.text.trim(),
          city: _selectedCity!.name,
          district: _selectedDistrict!.name,
          phone: _phoneController.text.trim(),
          isDefault: _isDefault,
        );

        setState(() => _isSaving = false);
        if (mounted) {
          Navigator.pop(context);
          widget.onAddressAdded(newAddress);
        }
      } else {
        setState(() {
          _isSaving = false;
          _errorMessage =
              response.message ?? 'Adres eklenirken bir hata oluştu';
        });
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Bir hata oluştu: $e';
      });
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
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
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
              child: Icon(
                Icons.close,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(child: Text('Yeni Adres Ekle', style: AppTypography.h4)),
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
              if (_errorMessage != null) ...[
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: AppRadius.borderRadiusSM,
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
              ],
              _buildAddressTypeSelector(),
              SizedBox(height: AppSpacing.xl),
              _buildInvoiceTypeSelector(),
              SizedBox(height: AppSpacing.xl),
              _buildNameFields(),
              SizedBox(height: AppSpacing.lg),
              _buildAddressTitleField(),
              SizedBox(height: AppSpacing.lg),
              _buildEmailField(),
              SizedBox(height: AppSpacing.lg),
              _buildPhoneField(),
              SizedBox(height: AppSpacing.lg),
              _buildCityDistrictRow(),
              SizedBox(height: AppSpacing.lg),
              _buildNeighbourhoodField(),
              SizedBox(height: AppSpacing.lg),
              _buildFullAddressField(),
              SizedBox(height: AppSpacing.lg),
              _buildInvoiceAddressField(),
              SizedBox(height: AppSpacing.lg),
              _buildPostalCodeField(),
              SizedBox(height: AppSpacing.lg),
              if (_invoiceType == AddressType.individual)
                _buildIdentityNumberField()
              else
                _buildCorporateFields(),
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

  Widget _buildInvoiceTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fatura Tipi',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildInvoiceTypeButton(
                'Bireysel',
                Icons.person_outline,
                AddressType.individual,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildInvoiceTypeButton(
                'Kurumsal',
                Icons.business,
                AddressType.corporate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInvoiceTypeButton(String title, IconData icon, String type) {
    final isSelected = _invoiceType == type;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _invoiceType = type);
      },
      borderRadius: AppRadius.borderRadiusSM,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _firstNameController,
            label: 'Ad',
            hint: 'Adınız',
            prefixIcon: Icons.person_outline,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildTextField(
            controller: _lastNameController,
            label: 'Soyad',
            hint: 'Soyadınız',
            prefixIcon: Icons.person_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      controller: _emailController,
      label: 'E-posta',
      hint: 'ornek@email.com',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildNeighbourhoodField() {
    if (_isLoadingNeighbourhoods) {
      return _buildLoadingDropdown('Mahalle');
    }

    if (_neighbourhoods.isEmpty && _selectedDistrict == null) {
      return _buildDisabledDropdown('Mahalle', 'Önce ilçe seçiniz');
    }

    if (_neighbourhoods.isEmpty) {
      return _buildTextField(
        controller: TextEditingController(),
        label: 'Mahalle',
        hint: 'Mahalle bulunamadı',
        prefixIcon: Icons.location_on_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mahalle',
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
            child: DropdownButtonFormField<Neighbourhood>(
              value: _selectedNeighbourhood,
              hint: Text(
                'Seçiniz',
                style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
              ),
              items: _neighbourhoods.map((neighbourhood) {
                return DropdownMenuItem<Neighbourhood>(
                  value: neighbourhood,
                  child: Text(
                    neighbourhood.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedNeighbourhood = value);
              },
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.sm,
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: InputBorder.none,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
              isExpanded: true,
              dropdownColor: AppColors.surface,
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceAddressField() {
    return _buildTextField(
      controller: _invoiceAddressController,
      label: 'Fatura Adresi (opsiyonel)',
      hint: 'Farklı bir fatura adresi varsa yazın',
      prefixIcon: Icons.receipt_long_outlined,
      maxLines: 2,
    );
  }

  Widget _buildPostalCodeField() {
    return _buildTextField(
      controller: _postalCodeController,
      label: 'Posta Kodu',
      hint: '34000',
      prefixIcon: Icons.local_post_office_outlined,
      keyboardType: TextInputType.number,
     
    );
  }

  Widget _buildIdentityNumberField() {
    return _buildTextField(
      controller: _identityNumberController,
      label: 'TC Kimlik Numarası',
      hint: '11 haneli TC Kimlik No',
      prefixIcon: Icons.badge_outlined,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildCorporateFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _companyNameController,
          label: 'Firma Adı',
          hint: 'Firma ünvanı',
          prefixIcon: Icons.business_center_outlined,
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _taxNumberController,
                label: 'Vergi No',
                hint: 'Vergi numarası',
                prefixIcon: Icons.numbers,
                keyboardType: TextInputType.number,
              
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTextField(
                controller: _taxAdministrationController,
                label: 'Vergi Dairesi',
                hint: 'Vergi dairesi adı',
                prefixIcon: Icons.account_balance_outlined,
               
              ),
            ),
          ],
        ),
      ],
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
    );
  }

  Widget _buildCityDistrictRow() {
    return Row(
      children: [
        Expanded(child: _buildCityDropdown()),
        SizedBox(width: AppSpacing.md),
        Expanded(child: _buildDistrictDropdown()),
      ],
    );
  }

  Widget _buildLoadingDropdown(String label) {
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
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadius.borderRadiusSM,
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledDropdown(String label, String hint) {
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
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.5),
            borderRadius: AppRadius.borderRadiusSM,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: AppColors.textTertiary),
              SizedBox(width: AppSpacing.sm),
              Text(
                hint,
                style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCityDropdown() {
    if (_isLoadingCities) {
      return _buildLoadingDropdown('İl');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İl',
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
            child: DropdownButtonFormField<City>(
              value: _selectedCity,
              hint: Text(
                'Seçiniz',
                style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
              ),
              items: _cities.map((city) {
                return DropdownMenuItem<City>(
                  value: city,
                  child: Text(
                    city.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCity = value);
                  _loadDistricts(value.no);
                }
              },
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.sm,
                  ),
                  child: Icon(
                    Icons.location_city_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: InputBorder.none,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
              isExpanded: true,
              dropdownColor: AppColors.surface,
              borderRadius: AppRadius.borderRadiusSM,
              menuMaxHeight: 300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistrictDropdown() {
    if (_isLoadingDistricts) {
      return _buildLoadingDropdown('İlçe');
    }

    if (_districts.isEmpty && _selectedCity == null) {
      return _buildDisabledDropdown('İlçe', 'Önce il seçiniz');
    }

    if (_districts.isEmpty) {
      return _buildLoadingDropdown('İlçe');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İlçe',
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
            child: DropdownButtonFormField<District>(
              value: _selectedDistrict,
              hint: Text(
                'Seçiniz',
                style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
              ),
              items: _districts.map((district) {
                return DropdownMenuItem<District>(
                  value: district,
                  child: Text(
                    district.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDistrict = value);
                  _loadNeighbourhoods(value.no);
                }
              },
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.sm,
                  ),
                  child: Icon(
                    Icons.map_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: InputBorder.none,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
              isExpanded: true,
              dropdownColor: AppColors.surface,
              borderRadius: AppRadius.borderRadiusSM,
              menuMaxHeight: 300,
            ),
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
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      controller: _phoneController,
      label: 'Telefon Numarası',
      hint: '05XX XXX XX XX',
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
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
              color: _isDefault
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.surface,
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
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
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
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
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
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.sm,
              ),
              child: Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
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
        ),
      ],
    );
  }

}