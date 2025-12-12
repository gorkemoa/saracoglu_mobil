import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/favorite_service.dart';
import '../services/basket_service.dart';
import '../models/product/product_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ürün Detay Sayfası
class ProductDetailPage extends StatefulWidget {
  final int productId;
  final ProductModel? initialProduct;

  const ProductDetailPage({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ProductService _productService = ProductService();
  final FavoriteService _favoriteService = FavoriteService();
  final BasketService _basketService = BasketService();
  final ScrollController _scrollController = ScrollController();

  // State
  ProductDetailModel? _product;
  List<ProductModel> _similarProducts = [];
  List<ProductComment> _comments = [];
  bool _isLoading = true;
  bool _isLoadingComments = false;
  bool _isTogglingFavorite = false;
  String? _errorMessage;
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadProductDetail();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// HTML içeriği oluştur
  Widget _buildHtmlContent(String htmlContent) {
    return Html(
      data: htmlContent,
      style: {
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontFamily: AppTypography.bodyMedium.fontFamily,
          fontSize: FontSize(AppTypography.bodyMedium.fontSize ?? 14),
          color: AppColors.textSecondary,
          lineHeight: LineHeight(1.5),
        ),
        "ul": Style(padding: HtmlPaddings.only(left: 10)),
        "li": Style(listStyleType: ListStyleType.disc),
        "p": Style(margin: Margins.only(bottom: 8)),
      },
      onLinkTap: (url, _, __) async {
        if (url != null) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
    );
  }

  /// Ürün detayını API'den yükle
  Future<void> _loadProductDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _productService.getProductDetail(
      productId: widget.productId,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response != null && response.product != null) {
          _product = response.product;
          _similarProducts = response.similarProducts;
          _isFavorite = _product!.isFavorite;
          // Yorumları da yükle
          _loadComments();
        } else {
          _errorMessage = 'Ürün detayı yüklenemedi';
        }
      });
    }
  }

  /// Yorumları API'den yükle
  Future<void> _loadComments() async {
    setState(() {
      _isLoadingComments = true;
    });

    final response = await _productService.getProductComments(
      productId: widget.productId,
    );

    if (mounted) {
      setState(() {
        _isLoadingComments = false;
        if (response != null && response.success) {
          _comments = response.comments;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    if (_isLoading) {
      return _buildLoadingScaffold();
    }

    if (_errorMessage != null || _product == null) {
      return _buildErrorScaffold();
    }

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
                      _buildCargoInfo(),
                      const SizedBox(height: 8),
                      _buildInfoTabs(),
                      const SizedBox(height: 12),
                      _buildReviewSection(),
                      const SizedBox(height: 12),
                      _buildSimilarProducts(),
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

  Widget _buildLoadingScaffold() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppSpacing.md),
            Text(
              'Ürün yükleniyor...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScaffold() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage ?? 'Bir hata oluştu',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _loadProductDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  /// Görsel ve App Bar Bölümü
  Widget _buildSliverAppBar() {
    final images = _product!.allImages;

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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.75),
            shape: BoxShape.circle,
            boxShadow: AppShadows.shadowSM,
          ),
          child: IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? AppColors.error : AppColors.textPrimary,
              size: 18,
            ),
            onPressed: () => _toggleFavorite(),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.75),
            shape: BoxShape.circle,
            boxShadow: AppShadows.shadowSM,
          ),
          child: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(
                  Icons.share_outlined,
                  color: AppColors.textPrimary,
                  size: 18,
                ),
                onPressed: () {
                  final box = context.findRenderObject() as RenderBox?;
                  Rect? shareOrigin = box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : null;
                  _shareProduct(sharePositionOrigin: shareOrigin);
                },
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) =>
                  setState(() => _selectedImageIndex = index),
              itemBuilder: (context, index) {
                return Container(
                  color: AppColors.surface,
                  child: _buildProductImage(images[index]),
                );
              },
            ),
            // Dot Indicators
            if (images.length > 1)
              Positioned(
                bottom: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
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

  Widget _buildProductImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.fill,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
            color: AppColors.primary,
          ),
        );
      },
      errorBuilder: (c, o, s) => _buildImagePlaceholder(),
    );
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
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// Başlık, Fiyat ve Stok Bölümü
  Widget _buildHeaderSection() {
    final product = _product!;
    final hasDiscount = product.hasDiscount;

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
              if (product.isInStock)
                _buildTag(
                  "Stokta",
                  AppColors.success,
                  Icons.check_circle_outline,
                ),
              if (hasDiscount)
                _buildTag(
                  "${product.productDiscountIcon}${product.productDiscount}",
                  AppColors.error,
                  Icons.local_offer_outlined,
                ),
              if (product.categories != null)
                _buildTag(
                  product.categories!.name,
                  AppColors.primary,
                  Icons.category_outlined,
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Başlık
          Text(product.productName, style: AppTypography.h3),

          if (product.productExcerpt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                product.productExcerpt,
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
                '${product.productPrice} TL',
                style: AppTypography.priceLarge.copyWith(fontSize: 22),
              ),
              if (hasDiscount) ...[
                const SizedBox(width: 8),
                Text(
                  '${product.productPriceDiscount} TL',
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
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBadge() {
    final product = _product!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, size: 16, color: AppColors.accent),
          const SizedBox(width: 3),
          Text(
            product.rating.isNotEmpty ? product.rating : '-',
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '(${product.totalComments})',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// Kargo bilgisi bölümü
  Widget _buildCargoInfo() {
    final product = _product!;
    if (product.cargoInfo.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.cargoInfo,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (product.cargoDetail.isNotEmpty)
                  Text(
                    product.cargoDetail,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bilgi Sekmeleri (Açıklama, Kullanım, İçerik, Uyarılar)
  Widget _buildInfoTabs() {
    final product = _product!;

    return Container(
      color: AppColors.surface,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'Ürün Açıklaması',
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          initiallyExpanded: true,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            if (product.productDescription.isNotEmpty)
              _buildHtmlContent(product.productDescription)
            else
              Text(
                'Ürün açıklaması bulunmamaktadır.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Yorum Bölümü
  Widget _buildReviewSection() {
    final product = _product!;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Değerlendirmeler',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: _showAllReviews,
                child: Text(
                  'Tümünü Gör (${product.totalComments})',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          // Özet Rating
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      product.rating.isNotEmpty ? product.rating : '-',
                      style: AppTypography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: i < (product.ratingAsDouble?.round() ?? 0)
                              ? AppColors.accent
                              : AppColors.border,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.totalComments} yorum',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [5, 4, 3, 2, 1].map((star) {
                      // Her yıldız için yorum sayısını hesapla
                      final countForStar = _comments
                          .where((c) => c.rating == star)
                          .length;
                      final percentage = _comments.isNotEmpty
                          ? countForStar / _comments.length
                          : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('$star', style: AppTypography.labelSmall),
                            const Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.accent,
                                ),
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Yorumlar
          if (_isLoadingComments)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_comments.isNotEmpty) ...[
            ..._comments.take(2).map((comment) => _buildCommentItem(comment)),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Henüz yorum yapılmamış.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(ProductComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  comment.initials,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      comment.date,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 12,
                    color: i < comment.rating
                        ? AppColors.accent
                        : AppColors.border,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.comment,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Benzer Ürünler
  Widget _buildSimilarProducts() {
    if (_similarProducts.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(top: 14, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Benzer Ürünler',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ProductCardList(
            height: 330,
            products: _similarProducts.map((product) {
              return ProductCard(
                title: product.productName,
                weight: product.productExcerpt,
                price: product.priceAsDouble,
                oldPrice: product.hasDiscount
                    ? product.discountPriceAsDouble
                    : null,
                imageUrl: product.productImage,
                rating: product.ratingAsDouble,
                reviewCount: product.totalComments > 0
                    ? product.totalComments
                    : null,
                isFavorite: product.isFavorite,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(
                        productId: product.productID,
                        initialProduct: product,
                      ),
                    ),
                  );
                },
                onAddToCart: () => _handleAddToCartSimilar(product),
                onFavorite: () => _handleFavoriteSimilar(product.productName),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Alt Bar - Sepete Ekle
  Widget _buildStickyBottomBar() {
    final product = _product!;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 14,
          right: 14,
          top: 10,
          bottom: MediaQuery.of(context).padding.bottom + 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            // Adet Seçici
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _buildQuantityButton(Icons.remove, () {
                    if (_quantity > 1) setState(() => _quantity--);
                  }),
                  Container(
                    constraints: const BoxConstraints(minWidth: 32),
                    alignment: Alignment.center,
                    child: Text(
                      '$_quantity',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildQuantityButton(Icons.add, () {
                    if (_quantity < product.productStock) {
                      setState(() => _quantity++);
                    }
                  }),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Sepete Ekle Butonu
            Expanded(
              child: GestureDetector(
                onTap: product.isInStock ? _addToCart : null,
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: product.isInStock
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.isInStock
                            ? "Sepete Ekle - ${(product.priceAsDouble * _quantity).toStringAsFixed(2)} TL"
                            : "Stokta Yok",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  // --- Action Methods ---

  void _shareProduct({Rect? sharePositionOrigin}) {
    if (_product == null) return;

    final String shareText =
        "${_product!.productName}\n\n"
        "${_product!.productPrice} TL\n\n"
        "İncelemek için: https://saracoglu.com/urun/${_product!.productID}";

    Share.share(shareText, sharePositionOrigin: sharePositionOrigin);
  }

  Future<void> _toggleFavorite() async {
    if (!await AuthGuard.checkAuth(
      context,
      message: 'Favorilere eklemek için giriş yapın',
    )) {
      return;
    }

    if (_isTogglingFavorite) return;

    setState(() => _isTogglingFavorite = true);
    HapticFeedback.lightImpact();

    final response = await _favoriteService.toggleFavorite(
      productId: widget.productId,
    );

    if (mounted) {
      setState(() => _isTogglingFavorite = false);

      if (response != null && response.success) {
        setState(() => _isFavorite = response.isFavorite);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  response.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(response.message)),
              ],
            ),
            backgroundColor: response.isFavorite
                ? AppColors.success
                : AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Favori işlemi başarısız oldu'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        );
      }
    }
  }

  Future<void> _addToCart() async {
    if (!await AuthGuard.checkAuth(
      context,
      message: 'Sepete eklemek için giriş yapın',
    )) {
      return;
    }

    HapticFeedback.mediumImpact();

    final response = await _basketService.addToBasket(
      productId: widget.productId,
      quantity: _quantity,
    );

    if (!mounted) return;

    if (response != null && response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(response.message)),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(response?.message ?? 'Sepete eklenemedi')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
        ),
      );
    }
  }

  Future<void> _handleAddToCartSimilar(ProductModel product) async {
    if (!await AuthGuard.checkAuth(
      context,
      message: 'Sepete eklemek için giriş yapın',
    )) {
      return;
    }

    HapticFeedback.mediumImpact();

    final response = await _basketService.addToBasket(
      productId: product.productID,
    );

    if (!mounted) return;

    if (response != null && response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(response.message)),
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
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(response?.message ?? 'Sepete eklenemedi')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
        ),
      );
    }
  }

  Future<void> _handleFavoriteSimilar(String productName) async {
    if (!await AuthGuard.checkAuth(
      context,
      message: 'Favorilere eklemek için giriş yapın',
    )) {
      return;
    }

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text('$productName favorilere eklendi')),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
      ),
    );
  }

  void _showAllReviews() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Başlık
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tüm Değerlendirmeler (${_comments.length})',
                      style: AppTypography.h3,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Yorum listesi
              Expanded(
                child: _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 64,
                              color: AppColors.textTertiary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz yorum yapılmamış',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildCommentItem(_comments[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
