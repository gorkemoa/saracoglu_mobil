import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // Favori ürünler listesi - gerçek uygulamada state management ile yönetilecek
  final List<Map<String, dynamic>> _favorites = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Favorilerim',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          if (_favorites.isNotEmpty)
            TextButton(
              onPressed: () {
                // Tümünü temizle
              },
              child: Text(
                'Temizle',
                style: AppTypography.labelMedium.copyWith(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: _favorites.isEmpty ? _buildEmptyState() : _buildFavoritesList(),
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
              Icons.favorite_outline,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            'Henüz favoriniz yok',
            style: AppTypography.h4,
          ),
          SizedBox(height: AppSpacing.sm),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Text(
              'Beğendiğiniz ürünleri favorilere ekleyerek daha sonra kolayca ulaşabilirsiniz.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: () {
              // Ana sayfaya yönlendir - MainScreen'deki tab'ı değiştirmek gerekecek
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

  Widget _buildFavoritesList() {
    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        // Favori ürün kartları
        return Container();
      },
    );
  }
}
