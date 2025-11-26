import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Sepet ürünleri listesi - gerçek uygulamada state management ile yönetilecek
  final List<Map<String, dynamic>> _cartItems = [];

  double get _totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Sepetim',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          if (_cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                // Sepeti temizle
              },
              child: Text(
                'Temizle',
                style: AppTypography.labelMedium.copyWith(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: _cartItems.isEmpty ? _buildEmptyState() : _buildCartContent(),
      bottomNavigationBar: _cartItems.isNotEmpty ? _buildCheckoutBar() : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            'Sepetiniz boş',
            style: AppTypography.h4,
          ),
          SizedBox(height: AppSpacing.sm),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Text(
              'Beğendiğiniz ürünleri sepete ekleyerek alışverişinizi tamamlayabilirsiniz.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: () {
              // Ana sayfaya yönlendir
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderRadiusSM,
              ),
            ),
            child: Text(
              'Alışverişe Başla',
              style: AppTypography.buttonMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Kargo bilgisi
          Container(
            margin: EdgeInsets.all(AppSpacing.md),
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.borderRadiusSM,
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: AppColors.primary),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '1000 TL üzeri alışverişlerde kargo bedava!',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          // Sepet ürünleri listesi
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: _cartItems.length,
            separatorBuilder: (context, index) => Divider(color: AppColors.divider),
            itemBuilder: (context, index) {
              return _buildCartItem(_cartItems[index]);
            },
          ),
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ürün görseli
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: AppRadius.borderRadiusSM,
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: AppRadius.borderRadiusSM,
              child: Image.network(
                item['imageUrl'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          // Ürün bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? '',
                  style: AppTypography.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  item['weight'] ?? '',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  '${item['price']?.toStringAsFixed(2)} TL',
                  style: AppTypography.priceMain,
                ),
              ],
            ),
          ),
          // Miktar kontrolü
          Column(
            children: [
              IconButton(
                onPressed: () {
                  // Sil
                },
                icon: Icon(Icons.delete_outline, color: AppColors.error),
                iconSize: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: AppRadius.borderRadiusSM,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Azalt
                      },
                      icon: Icon(Icons.remove, size: 16),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    Text(
                      '${item['quantity'] ?? 1}',
                      style: AppTypography.labelLarge,
                    ),
                    IconButton(
                      onPressed: () {
                        // Artır
                      },
                      icon: Icon(Icons.add, size: 16),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.shadowNavBar,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toplam',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  Text(
                    '${_totalPrice.toStringAsFixed(2)} TL',
                    style: AppTypography.priceLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Ödeme sayfasına git
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusSM,
                  ),
                ),
                child: Text(
                  'Sepeti Onayla',
                  style: AppTypography.buttonMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
