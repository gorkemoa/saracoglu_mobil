import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class FAQItem {
  final String question;
  final String answer;
  final IconData icon;

  FAQItem({required this.question, required this.answer, required this.icon});
}

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final _searchController = TextEditingController();
  int _expandedIndex = -1;

  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Siparişimi nasıl takip edebilirim?',
      answer: 'Siparişlerinizi "Siparişlerim" bölümünden takip edebilirsiniz. Kargo takip numarası ile de kargo firmasının sitesinden güncel durumu görebilirsiniz.',
      icon: Icons.local_shipping_outlined,
    ),
    FAQItem(
      question: 'İade işlemi nasıl yapılır?',
      answer: 'Ürünü teslim aldığınız tarihten itibaren 14 gün içinde "İade Taleplerim" bölümünden iade başvurusu yapabilirsiniz. Onay sonrası kargo kodunuz iletilecektir.',
      icon: Icons.assignment_return_outlined,
    ),
    FAQItem(
      question: 'Ödeme seçenekleri nelerdir?',
      answer: 'Kredi kartı, banka kartı, havale/EFT ve kapıda ödeme seçenekleri mevcuttur. Taksitli ödeme imkanı da sunmaktayız.',
      icon: Icons.payment_outlined,
    ),
    FAQItem(
      question: 'Ürünler orijinal mi?',
      answer: 'Tüm ürünlerimiz orijinal ve yetkili distribütörlerden temin edilmektedir. Her ürün için orijinallik garantisi verilmektedir.',
      icon: Icons.verified_outlined,
    ),
    FAQItem(
      question: 'Kargo ücreti ne kadar?',
      answer: '200 TL ve üzeri siparişlerde kargo ücretsizdir. 200 TL altı siparişlerde 29.90 TL kargo ücreti uygulanmaktadır.',
      icon: Icons.inventory_2_outlined,
    ),
    FAQItem(
      question: 'Sipariş iptal edilebilir mi?',
      answer: 'Kargoya verilmemiş siparişlerinizi iptal edebilirsiniz. Kargoya verildikten sonra iptal yapılamamaktadır, iade süreci başlatmanız gerekmektedir.',
      icon: Icons.cancel_outlined,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
            ),
            title: Text(
              'Yardım & Destek',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: true,
          ),

          // Arama
          SliverToBoxAdapter(
            child: _buildSearchBar(),
          ),

          // İletişim kartları
          SliverToBoxAdapter(
            child: _buildContactOptions(),
          ),

          // SSS başlık
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
              child: Text(
                'Sıkça Sorulan Sorular',
                style: AppTypography.h4,
              ),
            ),
          ),

          // SSS listesi
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildFAQItem(index),
                childCount: _faqItems.length,
              ),
            ),
          ),

          // Destek talebi
          SliverToBoxAdapter(
            child: _buildSupportTicketSection(),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Yardım konusu ara...',
          hintStyle: TextStyle(color: AppColors.textTertiary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusSM,
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                )
              : null,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildContactOptions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(child: _buildContactCard(
            icon: Icons.phone_outlined,
            title: 'Ara',
            subtitle: '0850 123 45 67',
            color: AppColors.success,
            onTap: () => _showCallSheet(),
          )),
          SizedBox(width: AppSpacing.md),
          Expanded(child: _buildContactCard(
            icon: Icons.chat_outlined,
            title: 'Canlı Destek',
            subtitle: 'Çevrimiçi',
            color: AppColors.primary,
            onTap: () => _showLiveChatSheet(),
          )),
          SizedBox(width: AppSpacing.md),
          Expanded(child: _buildContactCard(
            icon: Icons.email_outlined,
            title: 'E-posta',
            subtitle: 'Yaz',
            color: AppColors.info,
            onTap: () => _showEmailSheet(),
          )),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusSM,
          boxShadow: AppShadows.shadowCard,
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(int index) {
    final item = _faqItems[index];
    final isExpanded = _expandedIndex == index;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _expandedIndex = isExpanded ? -1 : index;
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderRadiusSM,
            border: Border.all(
              color: isExpanded ? AppColors.primary.withOpacity(0.3) : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: AppRadius.borderRadiusXS,
                      ),
                      child: Icon(item.icon, color: AppColors.primary, size: 18),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        item.question,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedCrossFade(
                firstChild: SizedBox.shrink(),
                secondChild: Container(
                  padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadius.borderRadiusXS,
                    ),
                    child: Text(
                      item.answer,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportTicketSection() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.08),
              AppColors.primary.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.borderRadiusMD,
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_center_outlined, color: AppColors.primary, size: 24),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Sorunuz çözülmedi mi?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Destek talebi oluşturarak müşteri temsilcimizden yardım alabilirsiniz.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCreateTicketSheet(),
                icon: Icon(Icons.add_comment_outlined, size: 18),
                label: Text('Destek Talebi Oluştur', style: AppTypography.buttonMedium),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallSheet() {
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
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.phone_outlined, color: AppColors.success, size: 32),
              ),
              SizedBox(height: AppSpacing.lg),
              Text('Müşteri Hizmetleri', style: AppTypography.h4),
              SizedBox(height: AppSpacing.sm),
              Text(
                '0850 123 45 67',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Hafta içi 09:00 - 18:00',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.call),
                  label: Text('Şimdi Ara', style: AppTypography.buttonMedium),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLiveChatSheet() {
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
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.headset_mic_outlined, color: AppColors.primary, size: 32),
              ),
              SizedBox(height: AppSpacing.lg),
              Text('Canlı Destek', style: AppTypography.h4),
              SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Çevrimiçi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Ortalama bekleme süresi: 2 dakika',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.chat),
                  label: Text('Sohbet Başlat', style: AppTypography.buttonMedium),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmailSheet() {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

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
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                SizedBox(height: AppSpacing.xl),
                Center(child: Text('E-posta Gönder', style: AppTypography.h4)),
                SizedBox(height: AppSpacing.xl),
                Text('Konu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    hintText: 'Konu giriniz',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderRadiusSM, borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.all(AppSpacing.md),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Text('Mesaj', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Mesajınızı yazınız',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderRadiusSM, borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.all(AppSpacing.md),
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 18),
                              SizedBox(width: AppSpacing.sm),
                              Text('E-posta gönderildi'),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(AppSpacing.md),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                        ),
                      );
                    },
                    icon: Icon(Icons.send),
                    label: Text('Gönder', style: AppTypography.buttonMedium),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateTicketSheet() {
    final descriptionController = TextEditingController();
    String selectedCategory = 'Sipariş';
    final categories = ['Sipariş', 'İade', 'Ürün', 'Kargo', 'Ödeme', 'Diğer'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    SizedBox(height: AppSpacing.xl),
                    Center(child: Text('Destek Talebi', style: AppTypography.h4)),
                    SizedBox(height: AppSpacing.xl),
                    Text('Kategori', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                    SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final isSelected = selectedCategory == category;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedCategory = category),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.background,
                              borderRadius: AppRadius.borderRadiusSM,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Text('Açıklama', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                    SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Sorununuzu detaylı açıklayınız',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: AppRadius.borderRadiusSM, borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.all(AppSpacing.md),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                                  SizedBox(width: AppSpacing.sm),
                                  Text('Destek talebiniz oluşturuldu'),
                                ],
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(AppSpacing.md),
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                        ),
                        child: Text('Talep Oluştur', style: AppTypography.buttonMedium),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
