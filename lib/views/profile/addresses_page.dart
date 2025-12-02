import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/delivery_address.dart';
import '../../widgets/add_address_sheet.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  List<DeliveryAddress> _addresses = [
    DeliveryAddress(
      id: '1',
      title: 'Ev',
      fullAddress: 'Mansuroğlu Mah. 286/5 Sok. No: 14 Daire: 7',
      city: 'İzmir',
      district: 'Bayraklı',
      phone: '0532 123 45 67',
      isDefault: true,
    ),
    DeliveryAddress(
      id: '2',
      title: 'Ofis',
      fullAddress: 'Cumhuriyet Bulvarı No: 110 Kat: 4 Office701',
      city: 'İzmir',
      district: 'Konak',
      phone: '0532 123 45 67',
    ),
    DeliveryAddress(
      id: '3',
      title: 'Aile Evi',
      fullAddress: 'Bağbaşı Mah. 1203 Sok. No: 22',
      city: 'Denizli',
      district: 'Merkezefendi',
      phone: '0532 987 65 43',
    ),
  ];

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

          // Adres Listesi
          if (_addresses.isNotEmpty)
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

  Widget _buildAddressCard(DeliveryAddress address) {
    return Dismissible(
      key: Key(address.id),
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
              color: address.isDefault ? AppColors.primary.withOpacity(0.5) : AppColors.border.withOpacity(0.5),
              width: address.isDefault ? 1.5 : 1,
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
                        color: address.isDefault 
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.background,
                        borderRadius: AppRadius.borderRadiusXS,
                      ),
                      child: Icon(
                        _getAddressIcon(address.title),
                        color: address.isDefault ? AppColors.primary : AppColors.textSecondary,
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
                              Text(
                                address.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (address.isDefault) ...[
                                SizedBox(width: AppSpacing.xs),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: AppRadius.borderRadiusXS,
                                  ),
                                  child: Text(
                                    'Varsayılan',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            address.fullAddress,
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.place_outlined, size: 12, color: AppColors.textTertiary),
                              SizedBox(width: 4),
                              Text(
                                '${address.district}, ${address.city}',
                                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                              ),
                              SizedBox(width: AppSpacing.md),
                              Icon(Icons.phone_outlined, size: 12, color: AppColors.textTertiary),
                              SizedBox(width: 4),
                              Text(
                                address.phone,
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

  void _showAddressOptions(DeliveryAddress address) {
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
              if (!address.isDefault)
                _buildOptionItem(
                  icon: Icons.check_circle_outline,
                  title: 'Varsayılan Yap',
                  onTap: () {
                    Navigator.pop(context);
                    _setDefaultAddress(address);
                  },
                ),
              _buildOptionItem(
                icon: Icons.delete_outline,
                title: 'Sil',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(address);
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

  Future<bool> _showDeleteConfirmation(DeliveryAddress address) async {
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
                '${address.title} adresini silmek istediğinize emin misiniz?',
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

  void _deleteAddress(DeliveryAddress address) {
    HapticFeedback.mediumImpact();
    setState(() {
      _addresses.removeWhere((a) => a.id == address.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${address.title} adresi silindi'),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
        action: SnackBarAction(
          label: 'Geri Al',
          textColor: AppColors.primary,
          onPressed: () {
            setState(() {
              _addresses.add(address);
            });
          },
        ),
      ),
    );
  }

  void _setDefaultAddress(DeliveryAddress address) {
    HapticFeedback.lightImpact();
    setState(() {
      _addresses = _addresses.map((addr) {
        return addr.copyWith(isDefault: addr.id == address.id);
      }).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: AppSpacing.sm),
            Text('${address.title} varsayılan adres olarak ayarlandı'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
      ),
    );
  }

  void _showAddAddressSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddNewAddressSheet(
        onAddressAdded: (newAddress) {
          setState(() {
            // Eğer yeni adres varsayılan ise, diğerlerini güncelle
            if (newAddress.isDefault) {
              _addresses = _addresses.map((addr) => addr.copyWith(isDefault: false)).toList();
            }
            _addresses.add(newAddress);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text('${newAddress.title} adresi eklendi'),
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

  void _showEditAddressSheet(DeliveryAddress address) {
    // Düzenleme için basit bir bottom sheet göster
    final titleController = TextEditingController(text: address.title);
    final addressController = TextEditingController(text: address.fullAddress);
    final cityController = TextEditingController(text: address.city);
    final districtController = TextEditingController(text: address.district);
    final phoneController = TextEditingController(text: address.phone);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(top: AppSpacing.sm),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppRadius.borderRadiusRound,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Text('Adresi Düzenle', style: AppTypography.h4),
                      Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: AppColors.divider),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        _buildFormField('Adres Başlığı', titleController, Icons.label_outline),
                        SizedBox(height: AppSpacing.md),
                        _buildFormField('Açık Adres', addressController, Icons.location_on_outlined, maxLines: 3),
                        SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(child: _buildFormField('İl', cityController, Icons.location_city_outlined)),
                            SizedBox(width: AppSpacing.md),
                            Expanded(child: _buildFormField('İlçe', districtController, Icons.map_outlined)),
                          ],
                        ),
                        SizedBox(height: AppSpacing.md),
                        _buildFormField('Telefon', phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
                        SizedBox(height: AppSpacing.xl),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.heavyImpact();
                              final updatedAddress = address.copyWith(
                                title: titleController.text,
                                fullAddress: addressController.text,
                                city: cityController.text,
                                district: districtController.text,
                                phone: phoneController.text,
                              );
                              final index = _addresses.indexWhere((a) => a.id == address.id);
                              if (index != -1) {
                                setState(() {
                                  _addresses[index] = updatedAddress;
                                });
                              }
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white, size: 18),
                                      SizedBox(width: AppSpacing.sm),
                                      Text('Adres güncellendi'),
                                    ],
                                  ),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(AppSpacing.md),
                                  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                            ),
                            child: Text('Güncelle', style: AppTypography.buttonMedium),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
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
            contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          ),
        ),
      ],
    );
  }
}
