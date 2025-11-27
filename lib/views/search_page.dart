import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

class SearchPage extends StatefulWidget {
  final bool showBackButton;

  const SearchPage({super.key, this.showBackButton = false});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Sana Özel Ürünler
  final List<Map<String, dynamic>> _specialProducts = [
    {
      'title': 'Çörek Otu Yağı Soğuk Sıkım 100ml',
      'weight': '100ml',
      'price': 189.90,
      'imageUrl': 'assets/kategorileri/soguksikimyaglar.png',
      'badgeText': '2. Ürün %10',
      'badgeColor': const Color(0xFFFF5722),
      'isAsset': true,
    },
    {
      'title': 'Ihlamur Yaprak Doğal 50g',
      'weight': '50g',
      'price': 79.90,
      'imageUrl': 'assets/kategorileri/dogalbitkiler.png',
      'badgeText': 'Kargo Bedava',
      'badgeColor': const Color(0xFF333333),
      'isAsset': true,
    },
    {
      'title': 'Organik Ham Bal 450g',
      'weight': '450g',
      'price': 329.90,
      'imageUrl': 'assets/kategorileri/dogalgidaveicecekler.png',
      'badgeText': 'Çok Satan',
      'badgeColor': const Color(0xFFFF5722),
      'sponsorlu': true,
      'isAsset': true,
    },
    {
      'title': 'Lavanta Yağı Saf 50ml',
      'weight': '50ml',
      'price': 149.90,
      'imageUrl': 'assets/kategorileri/aromaterapi.png',
      'badgeText': 'Yeni',
      'badgeColor': const Color(0xFF4CAF50),
      'isAsset': true,
    },
  ];

  // Önceden Gezdiklerim
  final List<Map<String, dynamic>> _recentlyViewed = [
    {'image': 'assets/kategorileri/soguksikimyaglar.png', 'isAsset': true},
    {'image': 'assets/kategorileri/dogalbitkiler.png', 'isAsset': true},
    {'image': 'assets/kategorileri/dogalgidaveicecekler.png', 'isAsset': true},
    {'image': 'assets/kategorileri/aromaterapi.png', 'isAsset': true},
    {'image': 'assets/kategorileri/ciltvevucuturunleri.png', 'isAsset': true},
    {'image': 'assets/kategorileri/organikkozmatik.png', 'isAsset': true},
  ];

  // Popüler Aramalar
  final List<Map<String, dynamic>> _popularSearches = [
    {'text': 'çörek otu yağı', 'isHot': true},
    {'text': 'ıhlamur', 'isHot': true},
    {'text': 'organik bal', 'isHot': false},
    {'text': 'lavanta yağı', 'isHot': false},
    {'text': 'arı sütü', 'isHot': false},
    {'text': 'propolis', 'isHot': false},
    {'text': 'zerdeçal', 'isHot': false},
    {'text': 'kekik suyu', 'isHot': false},
  ];

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında arama kutusuna otomatik focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSpacing.lg),
                    _buildRecentlyViewed(),

                    SizedBox(height: AppSpacing.xl),
                    _buildSpecialProducts(),
                    SizedBox(height: AppSpacing.xl),
                    _buildPopularSearches(),

                    SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Arama Kutusu
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(22),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                  SizedBox(width: 8),

                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Marka, ürün veya kategori ara",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),

                        // Çizgiyi %100 yok eden kısım:
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,

                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),

                  SizedBox(width: 8),
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: () {
              if (widget.showBackButton) {
                Navigator.pop(context);
              } else {
                _searchController.clear();
                FocusScope.of(context).unfocus();
              }
            },
            child: Text(
              'Ara',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sana Özel Ürünler',
                style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  // Tümünü gör
                },
                child: Row(
                  children: [
                    Text(
                      'Tümünü Gör',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        ProductCardList(
          height: 330,
          products: _specialProducts.map((product) {
            return ProductCard(
              title: product['title'],
              weight: product['weight'],
              price: product['price'],
              imageUrl: product['imageUrl'],
              isAssetImage: product['isAsset'] == true,
              badgeText: product['badgeText'],
              badgeColor: product['badgeColor'],
              onTap: () {
                // Ürün detayına git
              },
              onAddToCart: () {
                // Sepete ekle
              },
              onFavorite: () {
                // Favorilere ekle
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentlyViewed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Önceden Gezdiklerim',
                style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  // Tümünü gör
                },
                child: Row(
                  children: [
                    Text(
                      'Tümünü Gör',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _recentlyViewed.length,
            separatorBuilder: (context, index) =>
                SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              return _buildRecentlyViewedItem(_recentlyViewed[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyViewedItem(Map<String, dynamic> item) {
    final String imageUrl = item['image'] ?? '';
    final bool isAsset = item['isAsset'] == true;

    return GestureDetector(
      onTap: () {
        // Ürün detayına git
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isAsset
              ? Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade100,
                    child: Icon(
                      Icons.spa_outlined,
                      color: Colors.grey.shade300,
                      size: 30,
                    ),
                  ),
                )
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade100,
                    child: Icon(
                      Icons.spa_outlined,
                      color: Colors.grey.shade300,
                      size: 30,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPopularSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Popüler Aramalar',
                style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _popularSearches.length,
            separatorBuilder: (context, index) =>
                SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final search = _popularSearches[index];
              return _buildPopularSearchChip(
                search['text'],
                isHot: search['isHot'],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularSearchChip(String text, {bool isHot = false}) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        // Arama yap
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isHot) ...[
              Icon(
                Icons.local_fire_department,
                color: const Color(0xFFFF5722),
                size: 16,
              ),
              SizedBox(width: AppSpacing.xs),
            ],
            Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
