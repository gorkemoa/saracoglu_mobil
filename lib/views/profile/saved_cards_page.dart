import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/payment_service.dart';
import '../../models/user/saved_card_model.dart';

class SavedCardsPage extends StatefulWidget {
  const SavedCardsPage({super.key});

  @override
  State<SavedCardsPage> createState() => _SavedCardsPageState();
}

class _SavedCardsPageState extends State<SavedCardsPage> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = true;
  List<SavedCardModel> _cards = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  Future<void> _fetchCards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _paymentService.getSavedCards();

    if (mounted) {
      if (response.success && response.data != null) {
        setState(() {
          _cards = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Kartlar yüklenemedi';
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
      }
    }
  }

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
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            title: Text(
              'Kayıtlı Kartlarım',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: true,
          ),

          // Güvenlik Banner
          SliverToBoxAdapter(child: _buildSecurityBanner()),

          // Kart Listesi veya Yükleniyor veya Hata
          if (_isLoading)
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(child: _buildErrorState())
          else if (_cards.isNotEmpty)
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
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildSecurityBanner() {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          SizedBox(height: AppSpacing.md),
          Text(
            _errorMessage ?? 'Bir hata oluştu',
            style: AppTypography.bodyMedium,
          ),
          SizedBox(height: AppSpacing.md),
          ElevatedButton(onPressed: _fetchCards, child: Text('Tekrar Dene')),
        ],
      ),
    );
  }

  Widget _buildCardItem(SavedCardModel card) {
    final isVisa = card.schema?.toUpperCase().contains('VISA') == true;
    final cardColor = isVisa ? Color(0xFF1A1F71) : Color(0xFFEB001B);

    return GestureDetector(
      onTap: () => _showCardOptions(card),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cardColor, cardColor.withOpacity(0.8)],
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
                    card.cBrand ?? (card.schema ?? 'Card'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    card.cBank ?? 'Bank',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),

                  /* // Varsayılan kart özelliği API response'da yok gibi görünüyor, varsa eklenebilir
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
                  */
                ],
              ),
              Text(
                card.cType ?? 'Card Type',
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
              Spacer(),
              // Kart numarası
              Row(
                children: [
                  Icon(
                    Icons.contactless_outlined,
                    color: Colors.white70,
                    size: 24,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '**** **** **** ${card.last4 ?? '****'}',
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
                        card.cName ?? '',
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
                        '${card.month}/${card.year}',
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

  void _showCardOptions(SavedCardModel card) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
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
              // Varsayılan yapma özelliği API'de yoksa kaldırıyoruz veya endpoint varsa eklenmeli
              /*
              if (!card.isDefault)
                _buildOptionItem(
                  icon: Icons.check_circle_outline,
                  title: 'Varsayılan Yap',
                  onTap: () {
                    Navigator.pop(context);
                    // _setDefaultCard(card);
                  },
                ),
              */
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

  /*
  void _setDefaultCard(SavedCardModel card) {
    // API request for setting default card needs to be implemented
  }
  */

  void _showDeleteConfirmation(SavedCardModel card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
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
                child: Icon(
                  Icons.credit_card_off_outlined,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Text('Kartı Sil', style: AppTypography.h4),
              SizedBox(height: AppSpacing.sm),
              Text(
                '**** **** **** ${card.last4} numaralı kartı silmek istediğinize emin misiniz?',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusSM,
                        ),
                      ),
                      child: Text(
                        'Vazgeç',
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusSM,
                        ),
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

  Future<void> _deleteCard(SavedCardModel card) async {
    if (card.ctoken == null) return;

    // Loading gösterilebilir veya optimistic update yapılabilir.
    // Optimistic update: Listeden sil, hata olursa geri koy.
    // Ancak backend yanıtını beklemek daha güvenli.

    // Geçici bir loading göstergesi veya modal kapatma zaten yapıldı.
    // Tekrar modal açıp loading gösterebiliriz veya snackbar ile bilgi verebiliriz.

    final response = await _paymentService.deleteSavedCard(card.ctoken!);

    if (mounted) {
      if (response.success) {
        HapticFeedback.mediumImpact();
        setState(() {
          _cards.removeWhere((c) => c.ctoken == card.ctoken);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kart başarıyla silindi'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Kart silinemedi'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSM,
            ),
          ),
        );
      }
    }
  }
}
