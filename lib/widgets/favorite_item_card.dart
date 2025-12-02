import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class FavoriteItemData {
  final String id;
  final String title;
  final String weight;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  final bool isAssetImage;
  final String category;

  FavoriteItemData({
    required this.id,
    required this.title,
    required this.weight,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    this.isAssetImage = false,
    this.category = '',
  });

  int? get discount {
    if (oldPrice != null && oldPrice! > price) {
      return ((oldPrice! - price) / oldPrice! * 100).round();
    }
    return null;
  }
}

class FavoriteItemCard extends StatelessWidget {
  final FavoriteItemData item;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onAddToCart;
  final VoidCallback? onDismissed;

  const FavoriteItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onRemove,
    this.onAddToCart,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
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
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: (direction) => onDismissed?.call(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderRadiusSM,
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ürün Görseli
                _buildProductImage(),
                SizedBox(width: AppSpacing.md),
                // Ürün Bilgileri
                Expanded(child: _buildProductInfo()),
                SizedBox(width: AppSpacing.sm),
                // Aksiyon Butonları
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadius.borderRadiusXS,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.borderRadiusXS,
            child: item.isAssetImage
                ? Image.asset(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                  )
                : Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                  ),
          ),
        ),
        // İndirim etiketi
        if (item.discount != null)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: AppRadius.borderRadiusXS,
              ),
              child: Text(
                '%${item.discount}',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.background,
      child: Icon(
        Icons.image_outlined,
        color: AppColors.textTertiary,
        size: 24,
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Kategori
        if (item.category.isNotEmpty)
          Container(
            margin: EdgeInsets.only(bottom: 4),
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.borderRadiusXS,
            ),
            child: Text(
              item.category,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
        // Başlık
        Text(
          item.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2),
        // Gramaj
        Text(
          item.weight,
          style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
        SizedBox(height: AppSpacing.xs),
        // Fiyat
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₺${item.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (item.oldPrice != null) ...[
              SizedBox(width: 6),
              Text(
                '₺${item.oldPrice!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Favoriden çıkar
        InkWell(
          onTap: onRemove,
          borderRadius: AppRadius.borderRadiusRound,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite,
              color: AppColors.error,
              size: 18,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        // Sepete ekle
        InkWell(
          onTap: onAddToCart,
          borderRadius: AppRadius.borderRadiusRound,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_shopping_cart,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

/// Yatay kaydırmalı favori ürün listesi
class FavoriteItemCardList extends StatelessWidget {
  final List<FavoriteItemCard> items;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const FavoriteItemCardList({
    super.key,
    required this.items,
    this.itemHeight = 100,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => items[index],
    );
  }
}
