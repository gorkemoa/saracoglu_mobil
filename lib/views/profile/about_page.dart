import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
        ),
        title: Text(
          'Hakkımızda',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.lg),
              
              // Logo ve Marka
              _buildHeader(),
              
              SizedBox(height: AppSpacing.xxl),
              
              // Kurumsal Bilgi
              _buildSection(
                title: 'Kurumsal',
                content: 'Prof. Dr. İbrahim Adnan Saraçoğlu tarafından kurulan markamız, doğal ve bitkisel ürünleri bilimsel yaklaşımla sizlerle buluşturmaktadır.',
              ),
              
              SizedBox(height: AppSpacing.lg),
              
              // İletişim Bilgileri
              _buildContactSection(),
              
              SizedBox(height: AppSpacing.lg),
              
              // Sosyal Medya
              _buildSocialSection(context),
              
              SizedBox(height: AppSpacing.lg),
              
              // Linkler
              _buildLinksSection(context),
              
              SizedBox(height: AppSpacing.xxl),
              
              // Footer
              _buildFooter(),
              
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          // Logo
          SizedBox(
            width: 180,
            height: 80,
            child: Center(
            child: Image.asset(
                'assets/logo.png',
                width: 180,
                height: 48,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Doğal Bitkisel Ürünler',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İletişim',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        _buildContactRow(Icons.location_on_outlined, 'Soğanlık Yeni Mah. Aliağa Sok. No:8\nKat:16 Daire:78 Kartal/İSTANBUL'),
        SizedBox(height: AppSpacing.sm),
        _buildContactRow(Icons.phone_outlined, '0850 221 01 61'),
        SizedBox(height: AppSpacing.sm),
        _buildContactRow(Icons.email_outlined, 'info@profsaracoglu.com'),
        SizedBox(height: AppSpacing.sm),
        _buildContactRow(Icons.language_outlined, 'www.profsaracoglu.com'),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sosyal Medya',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _buildSocialButton(
              icon: Icons.facebook,
              onTap: () => _launchUrl('https://www.facebook.com/profsaracoglu'),
            ),
            SizedBox(width: AppSpacing.md),
            _buildSocialButton(
              icon: Icons.camera_alt_outlined,
              onTap: () => _launchUrl('https://instagram.com/profsaracoglu'),
            ),
            SizedBox(width: AppSpacing.md),
            _buildSocialButton(
              icon: Icons.play_circle_outline,
              onTap: () => _launchUrl('https://www.youtube.com/channel/UCA8_-LBCglz1OKWPD77xVGA'),
            ),
            SizedBox(width: AppSpacing.md),
            _buildSocialButton(
              icon: Icons.alternate_email,
              onTap: () => _launchUrl('https://twitter.com/profsaracoglu'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildLinksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bağlantılar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        _buildLinkItem('Satış Noktalarımız', () => _launchUrl('https://www.profsaracoglu.com/magazalarimiz.xhtml')),
        _buildLinkItem('Sertifikalarımız', () => _launchUrl('https://www.profsaracoglu.com/sertifikalarimiz')),
        _buildLinkItem('Gizlilik Politikası', () => _launchUrl('https://www.profsaracoglu.com/kisisel-verilerin-korunmasi-aydinlatma-metni')),
        _buildLinkItem('Satış Sözleşmesi', () => _launchUrl('https://www.profsaracoglu.com/satis-sozlesmesi.shtm')),
      ],
    );
  }

  Widget _buildLinkItem(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Divider(color: AppColors.border),
        SizedBox(height: AppSpacing.lg),
        Text(
          'Versiyon 1.0.0',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          '© 2007-2025 Prof. Saraçoğlu',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        Text(
          'Tüm Hakları Saklıdır.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        GestureDetector(
          onTap: () => _launchUrl('https://office701.com/'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Developed by ',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                'Office701',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
