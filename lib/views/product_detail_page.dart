import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

/// Ürün detay sayfası için veri modeli
class ProductDetailData {
  final String title;
  final String? subtitle;
  final double price;
  final double? oldPrice;
  final List<String> imageUrls;
  final bool inStock;
  final int reviewCount;
  final double rating;
  final String? description;
  final String? usage;
  final String? ingredients;
  final String? warnings;

  const ProductDetailData({
    required this.title,
    this.subtitle,
    required this.price,
    this.oldPrice,
    required this.imageUrls,
    this.inStock = true,
    this.reviewCount = 0,
    this.rating = 0.0,
    this.description,
    this.usage,
    this.ingredients,
    this.warnings,
  });
}

/// Yorum veri modeli
class ReviewData {
  final String userName;
  final String date;
  final int rating;
  final String comment;
  final String? avatarInitials;

  const ReviewData({
    required this.userName,
    required this.date,
    required this.rating,
    required this.comment,
    this.avatarInitials,
  });
}

/// Ürün Detay Sayfası
class ProductDetailPage extends StatefulWidget {
  final ProductDetailData? product;

  const ProductDetailPage({super.key, this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final ProductDetailData product;
  
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  final ScrollController _scrollController = ScrollController();

  // Örnek benzer ürünler
  final List<Map<String, dynamic>> _relatedProducts = [
    {'title': 'Lavanta Yağı', 'price': 185.0, 'image': 'assets/kategorileri/aromaterapi.png'},
    {'title': 'Organik Çay', 'price': 120.0, 'image': 'assets/kategorileri/dogalgidaveicecekler.png'},
    {'title': 'Bitki Serumu', 'price': 250.0, 'image': 'assets/kategorileri/ciltvevucuturunleri.png'},
  ];

  // Örnek yorumlar
  final List<ReviewData> _reviews = const [
    ReviewData(
      userName: "Ayşe Yılmaz",
      date: "15 Kasım 2023",
      rating: 5,
      comment: "Ürünü düzenli kullanıyorum, etkisini kısa sürede hissettim. Paketleme çok özenliydi, teşekkürler Saraçoğlu ailesi.",
      avatarInitials: "AY",
    ),
    ReviewData(
      userName: "Mehmet Kaya",
      date: "10 Kasım 2023",
      rating: 4,
      comment: "Kaliteli ürün, tavsiye ederim. Kargo da hızlıydı.",
      avatarInitials: "MK",
    ),
  ];

  @override
  void initState() {
    super.initState();
    product = widget.product ?? const ProductDetailData(
      title: "Brokoli Kürü",
      subtitle: "Brassica Oleracea",
      price: 450.0,
      oldPrice: 520.0,
      imageUrls: [
        'assets/kategorileri/dogalbitkiler.png',
        'assets/kategorileri/dogalgidaveicecekler.png',
      ],
      inStock: true,
      reviewCount: 128,
      rating: 4.8,
      description: "Doğal yöntemlerle toplanmış ve kurutulmuş, katkı maddesi içermeyen özel seri. Mevsiminde toplanan ürünlerimiz Prof. Saraçoğlu kalite standartlarında paketlenmiştir.",
      usage: "1. Kaynamakta olan bir bardak klorsuz suya bir tutam atınız.\n2. Kısık ateşte ağzı kapalı olarak 5 dakika demleyiniz.\n3. Sıcakken süzünüz.\n\nNot: Günde 1 kez kahvaltıdan önce tüketilmelidir.",
      ingredients: "%100 Brassica Oleracea (Brokoli). Koruyucu ve katkı maddesi içermez. Menşei: Türkiye.",
      warnings: "Hamilelik ve emzirme döneminde doktora danışılmalıdır. İlaç değildir. Hastalıkların önlenmesi veya tedavi edilmesi amacıyla kullanılmaz.",
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      const SizedBox(height: 8),
                      _buildCertificatesRow(),
                      const SizedBox(height: 8),
                      _buildInfoTabs(),
                      const SizedBox(height: 12),
                      _buildReviewSection(),
                      const SizedBox(height: 12),
                      _buildRelatedProducts(),
                       const SizedBox(height: 12),


                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildStickyBottomBar(),
        ],
      ),
    );
  }

  /// Görsel ve App Bar Bölümü
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 320.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          shape: BoxShape.circle,
          boxShadow: AppShadows.shadowSM,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.95),
            shape: BoxShape.circle,
            boxShadow: AppShadows.shadowSM,
          ),
          child: IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? AppColors.error : AppColors.textPrimary,
              size: 18,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.95),
            shape: BoxShape.circle,
            boxShadow: AppShadows.shadowSM,
          ),
          child: IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary, size: 18),
            onPressed: () => _shareProduct(),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              itemCount: product.imageUrls.length,
              onPageChanged: (index) => setState(() => _selectedImageIndex = index),
              itemBuilder: (context, index) {
                final imageUrl = product.imageUrls[index];
                return Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(24),
                  child: _buildProductImage(imageUrl),
                );
              },
            ),
            // Dot Indicators
            Positioned(
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  product.imageUrls.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _selectedImageIndex == index ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _selectedImageIndex == index
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ürün görselini yükler (asset veya network)
  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (c, o, s) => _buildImagePlaceholder(),
      );
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.primary,
            ),
          );
        },
        errorBuilder: (c, o, s) => _buildImagePlaceholder(),
      );
    }
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco, size: 60, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Görsel yüklenemedi',
            style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  /// Başlık, Fiyat ve Stok Bölümü
  Widget _buildHeaderSection() {
    final hasDiscount = product.oldPrice != null && product.oldPrice! > product.price;
    final discountPercent = hasDiscount
        ? (((product.oldPrice! - product.price) / product.oldPrice!) * 100).round()
        : 0;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiketler
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (product.inStock) _buildTag("Stokta", AppColors.success, Icons.check_circle_outline),
              _buildTag("Ücretsiz Kargo", AppColors.primary, Icons.local_shipping_outlined),
              if (hasDiscount) _buildTag("%$discountPercent", AppColors.error, Icons.local_offer_outlined),
            ],
          ),
          const SizedBox(height: 10),
          
          // Başlık
          Text(product.title, style: AppTypography.h3),
          
          if (product.subtitle?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                product.subtitle!,
                style: AppTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          
          const SizedBox(height: 12),
          
          // Fiyat ve Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₺${product.price.toStringAsFixed(0)}',
                style: AppTypography.priceLarge.copyWith(fontSize: 22),
              ),
              if (hasDiscount) ...[
                const SizedBox(width: 8),
                Text(
                  '₺${product.oldPrice!.toStringAsFixed(0)}',
                  style: AppTypography.priceOld.copyWith(fontSize: 14),
                ),
              ],
              const Spacer(),
              _buildRatingBadge(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.accent, size: 14),
          const SizedBox(width: 3),
          Text(
            "${product.rating}",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
          ),
          Text(
            " (${product.reviewCount})",
            style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  /// Sertifikalar - Güven Oluşturucu
  Widget _buildCertificatesRow() {
    final certificates = [
      {'icon': Icons.eco_outlined, 'label': 'Organik', 'color': AppColors.success},
      {'icon': Icons.verified_outlined, 'label': 'Onaylı', 'color': AppColors.primary},
      {'icon': Icons.science_outlined, 'label': 'Analizli', 'color': AppColors.info},
      {'icon': Icons.local_shipping_outlined, 'label': 'Hızlı', 'color': AppColors.accent},
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: certificates.map((cert) {
          final color = cert['color'] as Color;
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(cert['icon'] as IconData, color: color, size: 18),
              ),
              const SizedBox(height: 4),
              Text(
                cert['label'] as String,
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Bilgi Sekmeleri (Accordion)
  Widget _buildInfoTabs() {
    return Column(
      children: [
        if (product.description?.isNotEmpty == true)
          _buildExpansionTile(
            title: "Ürün Açıklaması",
            icon: Icons.info_outline,
            content: product.description!,
          ),
        if (product.usage?.isNotEmpty == true)
          _buildExpansionTile(
            title: "Kullanım Şekli (Kür Tarifi)",
            icon: Icons.healing_outlined,
            initiallyExpanded: true,
            content: product.usage!,
          ),
        if (product.ingredients?.isNotEmpty == true)
          _buildExpansionTile(
            title: "İçindekiler",
            icon: Icons.grass_outlined,
            content: product.ingredients!,
          ),
        if (product.warnings?.isNotEmpty == true)
          _buildExpansionTile(
            title: "Uyarılar",
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.warning,
            content: product.warnings!,
          ),
      ],
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required IconData icon,
    required String content,
    bool initiallyExpanded = false,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: AppColors.surface,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 16),
          ),
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          iconColor: AppColors.textSecondary,
          collapsedIconColor: AppColors.textTertiary,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  content,
                  style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Yorumlar Bölümü
  Widget _buildReviewSection() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Değerlendirmeler", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              TextButton(
                onPressed: () => _showAllReviews(),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text("Tümü (${product.reviewCount})", style: const TextStyle(fontSize: 12, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Yorum listesi
          ...(_reviews.take(2).map((review) => _buildReviewCard(review))),
          
          // Yorum yaz butonu
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _writeReview(),
            icon: const Icon(Icons.rate_review_outlined, size: 16),
            label: const Text("Yorum Yaz", style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewData review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryLight.withOpacity(0.15),
                radius: 16,
                child: Text(
                  review.avatarInitials ?? review.userName.substring(0, 2).toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(review.date, style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 12,
                    color: index < review.rating ? AppColors.accent : AppColors.border,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.comment,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  /// Benzer Ürünler
  Widget _buildRelatedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Birlikte İyi Gider", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text("Tümü", style: TextStyle(fontSize: 12, color: AppColors.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ProductCardList(
          products: _relatedProducts.map((item) => ProductCard(
            title: item['title'] as String,
            weight: "50g",
            price: item['price'] as double,
            imageUrl: item['image'] as String,
            isAssetImage: true,
            rating: 4.5,
            reviewCount: 24,
            onTap: () {
              // Ürün detayına git
            },
            onAddToCart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item['title']} sepete eklendi'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          )).toList(),
        ),
      ],
    );
  }
  /// Sabit Alt Bar (Sticky Bottom)
  Widget _buildStickyBottomBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.only(
          left: 14,
          right: 14,
          top: 10,
          bottom: MediaQuery.of(context).padding.bottom + 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppShadows.shadowNavBar,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          children: [
            // Adet Seçici
            Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    height: 40,
                    child: IconButton(
                      onPressed: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                      icon: Icon(
                        Icons.remove,
                        size: 16,
                        color: _quantity > 1 ? AppColors.textPrimary : AppColors.textTertiary,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(
                    width: 24,
                    child: Text(
                      "$_quantity",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    height: 40,
                    child: IconButton(
                      onPressed: () => setState(() => _quantity++),
                      icon: const Icon(Icons.add, size: 16, color: AppColors.textPrimary),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Sepete Ekle Butonu
            Expanded(
              child: SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: product.inStock ? () => _addToCart() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    disabledBackgroundColor: AppColors.border,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        product.inStock
                            ? "Sepete Ekle - ₺${(product.price * _quantity).toStringAsFixed(0)}"
                            : "Stokta Yok",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Action Methods ---

  void _shareProduct() {
    // Ürün paylaşma işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} paylaşılıyor...'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
      ),
    );
  }

  void _addToCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text('$_quantity adet ${product.title} sepete eklendi')),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
        action: SnackBarAction(
          label: 'Sepete Git',
          textColor: Colors.white,
          onPressed: () {
            // Sepet sayfasına git
          },
        ),
      ),
    );
  }

  void _showAllReviews() {
    // Tüm yorumları gösteren sayfa veya modal
  }

  void _writeReview() {
    // Yorum yazma modalı
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        padding: AppSpacing.paddingXL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.borderRadiusRound,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text("Yorum Yaz", style: AppTypography.h3),
            const SizedBox(height: AppSpacing.lg),
            Text("Bu özellik yakında eklenecektir.", style: AppTypography.bodyMedium),
          ],
        ),
      ),
    );
  }
}