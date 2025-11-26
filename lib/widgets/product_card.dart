import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String weight;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  final bool isNew;
  final bool isAssetImage;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final double? rating;
  final int? reviewCount;
  final String? badgeText;
  final Color? badgeColor;

  const ProductCard({
    super.key,
    required this.title,
    required this.weight,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    this.isNew = false,
    this.isAssetImage = false,
    this.onTap,
    this.onAddToCart,
    this.onFavorite,
    this.isFavorite = false,
    this.rating,
    this.reviewCount,
    this.badgeText,
    this.badgeColor,
  });

  int? get discount {
    if (oldPrice != null && oldPrice! > price) {
      return ((oldPrice! - price) / oldPrice! * 100).round();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Görsel Alanı
            _buildImageSection(),
            // Bilgi Alanı
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Ürün Görseli - Beyaz arka plan
        Container(
          height: 170,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(5) , topRight: Radius.circular(5)), // Tam circular görüntü
            child: isAssetImage
                ? Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: _errorBuilder,
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: _loadingBuilder,
                    errorBuilder: _errorBuilder,
                  ),
          ),
        ),

        // Sol üst badge (Kampanya vs.)
        if (badgeText != null)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor ?? const Color(0xFF7B2CBF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badgeText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Favori Butonu - Sağ üst
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onFavorite,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: isFavorite ? Colors.red : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    // Başlığı max 38 karakterle sınırla
    String displayTitle = title.length > 38
        ? '${title.substring(0, 38)}...'
        : title;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      height: 150, // Sabit yükseklik
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ürün Adı
          Text(
            displayTitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),

          // Rating
          if (rating != null)
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFF9800), size: 14),
                const SizedBox(width: 2),
                Text(
                  rating!.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (reviewCount != null) ...[
                  const SizedBox(width: 2),
                  Text(
                    "(${reviewCount})",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),

          // Gramaj
          Text(
            weight,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),

          const Spacer(), // Fiyatı alta it
          // Eski Fiyat ve İndirim Yüzdesi
          if (oldPrice != null)
            Row(
              children: [
                Text(
                  "${oldPrice!.toStringAsFixed(2)} TL",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "%$discount",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

          if (oldPrice != null) const SizedBox(height: 2),

          // Fiyat ve Sepet Butonu - Her zaman en altta
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Güncel Fiyat
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    price.toStringAsFixed(2).split('.')[0],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    ",${price.toStringAsFixed(2).split('.')[1]} TL",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              // Sepete Ekle Butonu
              GestureDetector(
                onTap: onAddToCart,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Icon(
                    Icons.add_shopping_cart_outlined,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) return child;
    return Container(
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
              : null,
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Container(
      color: Colors.white,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade300,
        size: 40,
      ),
    );
  }
}

// Yatay kaydırmalı ürün listesi için widget
class ProductCardList extends StatelessWidget {
  final List<ProductCard> products;
  final double height;

  const ProductCardList({
    super.key,
    required this.products,
    this.height = 330, // 170 (görsel) + 150 (info) + 10 (margin)
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) => products[index],
      ),
    );
  }
}
