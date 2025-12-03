import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/address/user_address_model.dart';
import '../../models/address/update_address_model.dart';
import '../../models/location/location_model.dart';
import '../../services/address_service.dart';
import '../../services/location_service.dart';
import '../../widgets/add_address_sheet.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  final AddressService _addressService = AddressService();
  final LocationService _locationService = LocationService();
  List<UserAddress> _addresses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _addressService.getAddresses();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.isSuccess) {
          _addresses = response.addresses;
        } else {
          _errorMessage = response.message ?? 'Adresler yüklenirken bir hata oluştu';
        }
      });
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
              icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
            ),
            title: Text(
              'Adreslerim',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () => _showAddAddressSheet(),
                icon: Icon(Icons.add, color: AppColors.primary, size: 24),
              ),
            ],
          ),

          // Bilgi Banner
          SliverToBoxAdapter(
            child: _buildInfoBanner(),
          ),

          // Loading State
          if (_isLoading)
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          // Error State
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: _buildErrorState(),
            )
          // Adres Listesi
          else if (_addresses.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _buildAddressCard(_addresses[index]),
                  ),
                  childCount: _addresses.length,
                ),
              ),
            )
          else
            SliverFillRemaining(
              child: _buildEmptyState(),
            ),

          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Bir Hata Oluştu',
              style: AppTypography.h4,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage ?? 'Adresler yüklenirken bir hata oluştu',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: _loadAddresses,
              icon: Icon(Icons.refresh),
              label: Text('Tekrar Dene', style: AppTypography.buttonMedium),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: AppRadius.borderRadiusSM,
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Teslimat adreslerinizi buradan yönetebilirsiniz',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off_outlined,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Adres Bulunamadı',
              style: AppTypography.h4,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Henüz kayıtlı adresiniz bulunmuyor.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => _showAddAddressSheet(),
              icon: Icon(Icons.add_location_alt_outlined),
              label: Text('Adres Ekle', style: AppTypography.buttonMedium),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(UserAddress address) {
    return Dismissible(
      key: Key(address.addressID.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: AppRadius.borderRadiusSM,
        ),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(address);
      },
      onDismissed: (direction) {
        _deleteAddress(address);
      },
      child: GestureDetector(
        onTap: () => _showAddressOptions(address),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderRadiusSM,
            border: Border.all(
              color: AppColors.border.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // İkon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: AppRadius.borderRadiusXS,
                      ),
                      child: Icon(
                        _getAddressIcon(address.addressTitle),
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    // Bilgiler
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  address.addressTitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: AppRadius.borderRadiusXS,
                                ),
                                child: Text(
                                  address.addressType,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            address.addressName,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 2),
                          Text(
                            address.address,
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.place_outlined, size: 12, color: AppColors.textTertiary),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${address.addressNeighbourhood}, ${address.addressDistrict}/${address.addressCity}',
                                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, size: 12, color: AppColors.textTertiary),
                              SizedBox(width: 4),
                              Text(
                                address.addressPhone,
                                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.more_vert, color: AppColors.textTertiary, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAddressIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('ev') || lowerTitle.contains('home')) {
      return Icons.home_outlined;
    } else if (lowerTitle.contains('iş') || lowerTitle.contains('work') || lowerTitle.contains('ofis')) {
      return Icons.business_outlined;
    } else if (lowerTitle.contains('yazlık') || lowerTitle.contains('villa')) {
      return Icons.villa_outlined;
    } else if (lowerTitle.contains('aile') || lowerTitle.contains('anne') || lowerTitle.contains('baba')) {
      return Icons.family_restroom_outlined;
    }
    return Icons.location_on_outlined;
  }

  void _showAddressOptions(UserAddress address) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.borderRadiusRound,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              _buildOptionItem(
                icon: Icons.edit_outlined,
                title: 'Düzenle',
                onTap: () {
                  Navigator.pop(context);
                  _showEditAddressSheet(address);
                },
              ),
              _buildOptionItem(
                icon: Icons.delete_outline,
                title: 'Sil',
                color: AppColors.error,
                onTap: () async {
                  Navigator.pop(context);
                  final confirmed = await _showDeleteConfirmation(address);
                  if (confirmed) {
                    _deleteAddress(address);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.textSecondary, size: 22),
            SizedBox(width: AppSpacing.md),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(UserAddress address) async {
    return await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.borderRadiusRound,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline, color: AppColors.error, size: 32),
              ),
              SizedBox(height: AppSpacing.lg),
              Text('Adresi Sil', style: AppTypography.h4),
              SizedBox(height: AppSpacing.sm),
              Text(
                '${address.addressTitle} adresini silmek istediğinize emin misiniz?',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                      ),
                      child: Text(
                        'Vazgeç',
                        style: AppTypography.buttonMedium.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                      ),
                      child: Text('Sil', style: AppTypography.buttonMedium),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ?? false;
  }

  void _deleteAddress(UserAddress address) async {
    HapticFeedback.mediumImpact();
    
    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    final response = await _addressService.deleteAddress(address.addressID);

    // Loading kapat
    if (mounted) Navigator.pop(context);

    if (response.isSuccess) {
      setState(() {
        _addresses.removeWhere((a) => a.addressID == address.addressID);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? '${address.addressTitle} adresi silindi'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Adres silinirken bir hata oluştu'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
          ),
        );
      }
    }
  }

  void _showAddAddressSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddNewAddressSheet(
        onAddressAdded: (newAddress) {
          // Adresleri yeniden yükle
          _loadAddresses();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text('Adres eklendi'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
            ),
          );
        },
      ),
    );
  }

  void _showEditAddressSheet(UserAddress address) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EditAddressSheet(
        address: address,
        addressService: _addressService,
        locationService: _locationService,
        onAddressUpdated: () {
          _loadAddresses();
        },
      ),
    );
  }
}

/// Adres düzenleme bottom sheet widget'ı
class _EditAddressSheet extends StatefulWidget {
  final UserAddress address;
  final AddressService addressService;
  final LocationService locationService;
  final VoidCallback onAddressUpdated;

  const _EditAddressSheet({
    required this.address,
    required this.addressService,
    required this.locationService,
    required this.onAddressUpdated,
  });

  @override
  State<_EditAddressSheet> createState() => _EditAddressSheetState();
}

class _EditAddressSheetState extends State<_EditAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _fullAddressController;
  late TextEditingController _phoneController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _postalCodeController;
  late TextEditingController _invoiceAddressController;
  late TextEditingController _identityNumberController;
  late TextEditingController _companyNameController;
  late TextEditingController _taxNumberController;
  late TextEditingController _taxAdministrationController;

  City? _selectedCity;
  District? _selectedDistrict;
  Neighbourhood? _selectedNeighbourhood;
  int _invoiceType = 1; // 1: Bireysel, 2: Kurumsal
  bool _isSaving = false;
  String? _errorMessage;

  List<City> _cities = [];
  List<District> _districts = [];
  List<Neighbourhood> _neighbourhoods = [];

  bool _isLoadingCities = true;
  bool _isLoadingDistricts = false;
  bool _isLoadingNeighbourhoods = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadCities();
  }

  void _initControllers() {
    _titleController = TextEditingController(text: widget.address.addressTitle);
    _fullAddressController = TextEditingController(text: widget.address.address);
    _phoneController = TextEditingController(text: widget.address.addressPhone);
    _firstNameController = TextEditingController(text: widget.address.addressFirstName);
    _lastNameController = TextEditingController(text: widget.address.addressLastName);
    _emailController = TextEditingController(text: widget.address.addressEmail);
    _postalCodeController = TextEditingController(text: widget.address.postalCode);
    _invoiceAddressController = TextEditingController(text: widget.address.invoiceAddress);
    _identityNumberController = TextEditingController(text: widget.address.identityNumber.toString());
    _companyNameController = TextEditingController(text: widget.address.realCompanyName);
    _taxNumberController = TextEditingController(text: widget.address.taxNumber);
    _taxAdministrationController = TextEditingController(text: widget.address.taxAdministration);
    _invoiceType = widget.address.addressTypeID;
  }

  Future<void> _loadCities() async {
    setState(() => _isLoadingCities = true);
    final response = await widget.locationService.getCities();
    if (response.isSuccess && mounted) {
      setState(() {
        _cities = response.cities;
        _isLoadingCities = false;
        // Mevcut şehri seç
        _selectedCity = _cities.firstWhere(
          (c) => c.no == widget.address.cityID,
          orElse: () => _cities.first,
        );
      });
      if (_selectedCity != null) {
        _loadDistricts(_selectedCity!.no);
      }
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

    final response = await widget.locationService.getDistricts(cityNo);
    if (response.isSuccess && mounted) {
      setState(() {
        _districts = response.districts;
        _isLoadingDistricts = false;
        // Mevcut ilçeyi seç
        _selectedDistrict = _districts.firstWhere(
          (d) => d.no == widget.address.districtID,
          orElse: () => _districts.isNotEmpty ? _districts.first : _districts.first,
        );
      });
      if (_selectedDistrict != null) {
        _loadNeighbourhoods(_selectedDistrict!.no);
      }
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

    final response = await widget.locationService.getNeighbourhoods(districtNo);
    if (response.isSuccess && mounted) {
      setState(() {
        _neighbourhoods = response.neighbourhoods;
        _isLoadingNeighbourhoods = false;
        // Mevcut mahalleyi seç
        if (_neighbourhoods.isNotEmpty) {
          _selectedNeighbourhood = _neighbourhoods.firstWhere(
            (n) => n.no == widget.address.neighbourhoodID,
            orElse: () => _neighbourhoods.first,
          );
        }
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

  String _formatPhoneNumber(String phone) {
    String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('90') && digits.length > 10) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length > 10) {
      digits = digits.substring(1);
    }
    if (digits.length != 10) {
      return phone;
    }
    return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6, 8)} ${digits.substring(8, 10)}';
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
      final formattedPhone = _formatPhoneNumber(_phoneController.text.trim());

      final request = UpdateAddressRequest(
        userToken: widget.addressService.userToken ?? '',
        addressID: widget.address.addressID,
        userFirstName: _firstNameController.text.trim(),
        userLastName: _lastNameController.text.trim(),
        addressTitle: _titleController.text.trim(),
        addressType: _invoiceType,
        addressPhone: formattedPhone,
        addressEmail: _emailController.text.trim(),
        addressCityID: _selectedCity!.no.toString(),
        addressDistrictID: _selectedDistrict!.no.toString(),
        addressNeighbourhoodID: _selectedNeighbourhood?.no.toString() ?? '0',
        address: _fullAddressController.text.trim(),
        invoiceAddress: _invoiceAddressController.text.trim().isNotEmpty
            ? _invoiceAddressController.text.trim()
            : _fullAddressController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        identityNumber: _invoiceType == 1 ? _identityNumberController.text.trim() : '',
        realCompanyName: _invoiceType == 2 ? _companyNameController.text.trim() : '',
        taxNumber: _invoiceType == 2 ? _taxNumberController.text.trim() : '',
        taxAdministration: _invoiceType == 2 ? _taxAdministrationController.text.trim() : '',
      );

      final response = await widget.addressService.updateAddress(request);

      if (response.isSuccess) {
        setState(() => _isSaving = false);
        if (mounted) {
          Navigator.pop(context);
          widget.onAddressUpdated();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text(response.message ?? 'Adres güncellendi'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
            ),
          );
        }
      } else {
        setState(() {
          _isSaving = false;
          _errorMessage = response.message ?? 'Adres güncellenirken bir hata oluştu';
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
          Expanded(child: Text('Adresi Düzenle', style: AppTypography.h4)),
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
                      Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
              ],
              _buildInvoiceTypeSelector(),
              SizedBox(height: AppSpacing.xl),
              _buildNameFields(),
              SizedBox(height: AppSpacing.lg),
              _buildTextField(
                controller: _titleController,
                label: 'Adres Başlığı',
                hint: 'örn: Ev, İş',
                prefixIcon: Icons.label_outline,
              ),
              SizedBox(height: AppSpacing.lg),
              _buildTextField(
                controller: _emailController,
                label: 'E-posta',
                hint: 'ornek@email.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: AppSpacing.lg),
              _buildTextField(
                controller: _phoneController,
                label: 'Telefon Numarası',
                hint: '05XX XXX XX XX',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: AppSpacing.lg),
              _buildCityDistrictRow(),
              SizedBox(height: AppSpacing.lg),
              _buildNeighbourhoodDropdown(),
              SizedBox(height: AppSpacing.lg),
              _buildTextField(
                controller: _fullAddressController,
                label: 'Açık Adres',
                hint: 'Mahalle, sokak, bina no, daire no',
                prefixIcon: Icons.home_outlined,
                maxLines: 3,
              ),
              SizedBox(height: AppSpacing.lg),
              _buildTextField(
                controller: _invoiceAddressController,
                label: 'Fatura Adresi (opsiyonel)',
                hint: 'Farklı bir fatura adresi varsa yazın',
                prefixIcon: Icons.receipt_long_outlined,
                maxLines: 2,
              ),
              SizedBox(height: AppSpacing.lg),
              _buildTextField(
                controller: _postalCodeController,
                label: 'Posta Kodu',
                hint: '34000',
                prefixIcon: Icons.local_post_office_outlined,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: AppSpacing.lg),
              if (_invoiceType == 1)
                _buildTextField(
                  controller: _identityNumberController,
                  label: 'TC Kimlik Numarası',
                  hint: '11 haneli TC Kimlik No',
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                )
              else
                _buildCorporateFields(),
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
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: _buildInvoiceTypeButton('Bireysel', Icons.person_outline, 1)),
            SizedBox(width: AppSpacing.md),
            Expanded(child: _buildInvoiceTypeButton('Kurumsal', Icons.business, 2)),
          ],
        ),
      ],
    );
  }

  Widget _buildInvoiceTypeButton(String title, IconData icon, int type) {
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
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.background,
          borderRadius: AppRadius.borderRadiusSM,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
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
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityDropdown() {
    if (_isLoadingCities) return _buildLoadingDropdown('İl');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('İl', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
              hint: Text('Seçiniz', style: TextStyle(fontSize: 14, color: AppColors.textTertiary)),
              items: _cities.map((city) {
                return DropdownMenuItem<City>(
                  value: city,
                  child: Text(city.name, style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
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
                  padding: EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
                  child: Icon(Icons.location_city_outlined, size: 20, color: AppColors.textSecondary),
                ),
                prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                border: InputBorder.none,
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
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
    if (_isLoadingDistricts) return _buildLoadingDropdown('İlçe');

    if (_districts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('İlçe', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
                Text('Önce il seçiniz', style: TextStyle(fontSize: 14, color: AppColors.textTertiary)),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('İlçe', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
              hint: Text('Seçiniz', style: TextStyle(fontSize: 14, color: AppColors.textTertiary)),
              items: _districts.map((district) {
                return DropdownMenuItem<District>(
                  value: district,
                  child: Text(district.name, style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
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
                  padding: EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
                  child: Icon(Icons.map_outlined, size: 20, color: AppColors.textSecondary),
                ),
                prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                border: InputBorder.none,
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
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

  Widget _buildNeighbourhoodDropdown() {
    if (_isLoadingNeighbourhoods) return _buildLoadingDropdown('Mahalle');

    if (_neighbourhoods.isEmpty && _selectedDistrict == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mahalle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
                Text('Önce ilçe seçiniz', style: TextStyle(fontSize: 14, color: AppColors.textTertiary)),
              ],
            ),
          ),
        ],
      );
    }

    if (_neighbourhoods.isEmpty) return _buildLoadingDropdown('Mahalle');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mahalle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
              hint: Text('Seçiniz', style: TextStyle(fontSize: 14, color: AppColors.textTertiary)),
              items: _neighbourhoods.map((neighbourhood) {
                return DropdownMenuItem<Neighbourhood>(
                  value: neighbourhood,
                  child: Text(neighbourhood.name, style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedNeighbourhood = value),
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
                  child: Icon(Icons.location_on_outlined, size: 20, color: AppColors.textSecondary),
                ),
                prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                border: InputBorder.none,
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
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
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, color: Colors.white, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Güncelle',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
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
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
          ),
        ),
      ],
    );
  }
}
