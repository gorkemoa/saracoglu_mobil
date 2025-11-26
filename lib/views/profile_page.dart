import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Hesabım',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Ayarlar
            },
            icon: Icon(Icons.settings_outlined, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Kullanıcı bilgileri
            _buildUserHeader(),
            SizedBox(height: AppSpacing.md),
            // Menü öğeleri
            _buildMenuSection(
              title: 'Siparişlerim',
              items: [
                _MenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Siparişlerim',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.local_shipping_outlined,
                  title: 'Kargo Takibi',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.replay,
                  title: 'İade Taleplerim',
                  onTap: () {},
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            _buildMenuSection(
              title: 'Hesap Bilgilerim',
              items: [
                _MenuItem(
                  icon: Icons.person_outline,
                  title: 'Profil Bilgilerim',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Adreslerim',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.credit_card_outlined,
                  title: 'Kayıtlı Kartlarım',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.lock_outline,
                  title: 'Şifre Değiştir',
                  onTap: () {},
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            _buildMenuSection(
              title: 'Diğer',
              items: [
                _MenuItem(
                  icon: Icons.help_outline,
                  title: 'Yardım & Destek',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.description_outlined,
                  title: 'Yasal Bilgiler',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.info_outline,
                  title: 'Hakkımızda',
                  onTap: () {},
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            // Çıkış yap butonu
            _buildLogoutButton(context),
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    // Giriş yapmamış kullanıcı için
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoş Geldiniz',
                  style: AppTypography.h4,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Giriş yaparak siparişlerinizi takip edebilirsiniz.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...items.map((item) => _buildMenuItem(item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppRadius.borderRadiusSM,
              ),
              child: Icon(
                item.icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                item.title,
                style: AppTypography.bodyMedium,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            // Çıkış yap
          },
          icon: Icon(Icons.logout, color: AppColors.error),
          label: Text(
            'Çıkış Yap',
            style: AppTypography.buttonMedium.copyWith(color: AppColors.error),
          ),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            side: BorderSide(color: AppColors.error),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
