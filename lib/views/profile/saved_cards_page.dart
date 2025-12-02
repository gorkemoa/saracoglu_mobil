import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class SavedCard {
  final String id;
  final String cardNumber;
  final String holderName;
  final String expiryDate;
  final String cardType;
  bool isDefault;

  SavedCard({
    required this.id,
    required this.cardNumber,
    required this.holderName,
    required this.expiryDate,
    required this.cardType,
    this.isDefault = false,
  });

  String get maskedNumber => '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
}

class SavedCardsPage extends StatefulWidget {
  const SavedCardsPage({super.key});

  @override
  State<SavedCardsPage> createState() => _SavedCardsPageState();
}

class _SavedCardsPageState extends State<SavedCardsPage> {
  final List<SavedCard> _cards = [
    SavedCard(
      id: '1',
      cardNumber: '4532015112830366',
      holderName: 'AHMET YILMAZ',
      expiryDate: '12/26',
      cardType: 'Visa',
      isDefault: true,
    ),
    SavedCard(
      id: '2',
      cardNumber: '5425233430109903',
      holderName: 'AHMET YILMAZ',
      expiryDate: '08/25',
      cardType: 'Mastercard',
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
              'Kayıtlı Kartlarım',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () => _showAddCardSheet(),
                icon: Icon(Icons.add, color: AppColors.primary, size: 24),
              ),
            ],
          ),

          // Güvenlik Banner
          SliverToBoxAdapter(
            child: _buildSecurityBanner(),
          ),

          // Kart Listesi
          if (_cards.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: _buildCardItem(_cards[index]),
                  ),
                  childCount: _cards.length,
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

  Widget _buildSecurityBanner() {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: AppRadius.borderRadiusSM,
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: AppColors.success, size: 18),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Kart bilgileriniz 256-bit SSL ile şifreli olarak saklanır',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.success,
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
                  Icons.credit_card_off_outlined,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Kayıtlı Kart Yok',
              style: AppTypography.h4,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Hızlı ödeme için kart ekleyebilirsiniz.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => _showAddCardSheet(),
              icon: Icon(Icons.add_card),
              label: Text('Kart Ekle', style: AppTypography.buttonMedium),
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

  Widget _buildCardItem(SavedCard card) {
    final cardColor = card.cardType == 'Visa' 
        ? Color(0xFF1A1F71) 
        : Color(0xFFEB001B);
    
    return GestureDetector(
      onTap: () => _showCardOptions(card),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cardColor,
              cardColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.borderRadiusMD,
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kısım - Logo ve varsayılan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card.cardType,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (card.isDefault)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: AppRadius.borderRadiusXS,
                      ),
                      child: Text(
                        'Varsayılan',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              Spacer(),
              // Kart numarası
              Row(
                children: [
                  Icon(Icons.contactless_outlined, color: Colors.white70, size: 24),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    card.maskedNumber,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              Spacer(),
              // Alt kısım - İsim ve tarih
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KART SAHİBİ',
                        style: TextStyle(fontSize: 8, color: Colors.white60),
                      ),
                      Text(
                        card.holderName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'SON KULLANMA',
                        style: TextStyle(fontSize: 8, color: Colors.white60),
                      ),
                      Text(
                        card.expiryDate,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCardOptions(SavedCard card) {
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
              if (!card.isDefault)
                _buildOptionItem(
                  icon: Icons.check_circle_outline,
                  title: 'Varsayılan Yap',
                  onTap: () {
                    Navigator.pop(context);
                    _setDefaultCard(card);
                  },
                ),
              _buildOptionItem(
                icon: Icons.delete_outline,
                title: 'Kartı Sil',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(card);
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

  void _setDefaultCard(SavedCard card) {
    HapticFeedback.lightImpact();
    setState(() {
      for (var c in _cards) {
        c.isDefault = c.id == card.id;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: AppSpacing.sm),
            Text('Varsayılan kart değiştirildi'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
      ),
    );
  }

  void _showDeleteConfirmation(SavedCard card) {
    showModalBottomSheet(
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
                child: Icon(Icons.credit_card_off_outlined, color: AppColors.error, size: 32),
              ),
              SizedBox(height: AppSpacing.lg),
              Text('Kartı Sil', style: AppTypography.h4),
              SizedBox(height: AppSpacing.sm),
              Text(
                '${card.maskedNumber} numaralı kartı silmek istediğinize emin misiniz?',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteCard(card);
                      },
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
    );
  }

  void _deleteCard(SavedCard card) {
    HapticFeedback.mediumImpact();
    setState(() {
      _cards.removeWhere((c) => c.id == card.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kart silindi'),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
      ),
    );
  }

  void _showAddCardSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
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
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add_card, color: AppColors.primary, size: 32),
                ),
                SizedBox(height: AppSpacing.lg),
                Text('Yeni Kart Ekle', style: AppTypography.h4),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Kart ekleme işlemi güvenli ödeme sayfasında gerçekleştirilecektir.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Güvenli ödeme sayfasına yönlendir
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                    ),
                    child: Text('Devam Et', style: AppTypography.buttonMedium),
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Vazgeç',
                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
