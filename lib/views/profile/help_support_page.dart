import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/contact_service.dart';
import '../../models/contact/contact_subject_model.dart';

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
  final ContactService _contactService = ContactService();
  int _expandedIndex = -1;

  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Siparişimi nasıl takip edebilirim?',
      answer:
          'Siparişlerinizi "Siparişlerim" bölümünden takip edebilirsiniz. Kargo takip numarası ile de kargo firmasının sitesinden güncel durumu görebilirsiniz.',
      icon: Icons.local_shipping_outlined,
    ),
    FAQItem(
      question: 'İade işlemi nasıl yapılır?',
      answer:
          'Ürünü teslim aldığınız tarihten itibaren 14 gün içinde "İade Taleplerim" bölümünden iade başvurusu yapabilirsiniz. Onay sonrası kargo kodunuz iletilecektir.',
      icon: Icons.assignment_return_outlined,
    ),
    FAQItem(
      question: 'Ödeme seçenekleri nelerdir?',
      answer:
          'Kredi kartı, banka kartı, havale/EFT ve kapıda ödeme seçenekleri mevcuttur. Taksitli ödeme imkanı da sunmaktayız.',
      icon: Icons.payment_outlined,
    ),
    FAQItem(
      question: 'Ürünler orijinal mi?',
      answer:
          'Tüm ürünlerimiz orijinal ve yetkili distribütörlerden temin edilmektedir. Her ürün için orijinallik garantisi verilmektedir.',
      icon: Icons.verified_outlined,
    ),
    FAQItem(
      question: 'Kargo ücreti ne kadar?',
      answer:
          '200 TL ve üzeri siparişlerde kargo ücretsizdir. 200 TL altı siparişlerde 29.90 TL kargo ücreti uygulanmaktadır.',
      icon: Icons.inventory_2_outlined,
    ),
    FAQItem(
      question: 'Sipariş iptal edilebilir mi?',
      answer:
          'Kargoya verilmemiş siparişlerinizi iptal edebilirsiniz. Kargoya verildikten sonra iptal yapılamamaktadır, iade süreci başlatmanız gerekmektedir.',
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
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            title: Text(
              'Yardım & Destek',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: true,
          ),

          // Arama
          SliverToBoxAdapter(child: _buildSearchBar()),

          // İletişim kartları
          SliverToBoxAdapter(child: _buildContactOptions()),

          // SSS başlık
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Text('Sıkça Sorulan Sorular', style: AppTypography.h4),
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
          SliverToBoxAdapter(child: _buildSupportTicketSection()),

          // Taleplerim bölümü
          SliverToBoxAdapter(child: _buildMyRequestsSection()),

          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
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
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
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
          Expanded(
            child: _buildContactCard(
              icon: Icons.phone_outlined,
              title: 'Ara',
              subtitle: '0850 123 45 67',
              color: AppColors.success,
              onTap: () => _showCallSheet(),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildContactCard(
              icon: Icons.chat_outlined,
              title: 'Canlı Destek',
              subtitle: 'Çevrimiçi',
              color: AppColors.primary,
              onTap: () => _showLiveChatSheet(),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildContactCard(
              icon: Icons.email_outlined,
              title: 'E-posta',
              subtitle: 'Yaz',
              color: AppColors.info,
              onTap: () => _showEmailSheet(),
            ),
          ),
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
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
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
              color: isExpanded
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.border,
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
                      child: Icon(
                        item.icon,
                        color: AppColors.primary,
                        size: 18,
                      ),
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
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
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
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
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
                Icon(
                  Icons.help_center_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
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
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCreateTicketSheet(),
                icon: Icon(Icons.add_comment_outlined, size: 18),
                label: Text(
                  'Destek Talebi Oluştur',
                  style: AppTypography.buttonMedium,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusSM,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRequestsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Taleplerim', style: AppTypography.h4),
              TextButton(
                onPressed: () => _showMyRequestsSheet(),
                child: Text(
                  'Tümünü Gör',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () => _showMyRequestsSheet(),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.borderRadiusSM,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: AppRadius.borderRadiusXS,
                    ),
                    child: Icon(Icons.history, color: AppColors.info, size: 20),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Geçmiş Taleplerim',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Gönderdiğiniz talepleri görüntüleyin',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMyRequestsSheet() {
    List<UserContactForm> contacts = [];
    bool isLoading = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          if (isLoading && contacts.isEmpty) {
            _contactService.getUserContactForms().then((response) {
              if (response != null && response.isSuccess) {
                setSheetState(() {
                  contacts = response.contacts;
                  isLoading = false;
                });
              } else {
                setSheetState(() {
                  isLoading = false;
                });
              }
            });
          }

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Column(
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
                      Text('Taleplerim', style: AppTypography.h4),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : contacts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              SizedBox(height: AppSpacing.md),
                              Text(
                                'Henüz talebiniz bulunmuyor',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          itemCount: contacts.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final contact = contacts[index];
                            return _buildContactFormCard(contact);
                          },
                        ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.borderRadiusSM,
                          ),
                          side: BorderSide(color: AppColors.border),
                        ),
                        child: Text(
                          'Kapat',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactFormCard(UserContactForm contact) {
    Color statusColor;
    switch (contact.statusID) {
      case 1: // Yeni Kayıt
        statusColor = AppColors.info;
        break;
      case 2: // İşlemde
        statusColor = AppColors.warning;
        break;
      case 3: // Tamamlandı
        statusColor = AppColors.success;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.borderRadiusSM,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  contact.subjectTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: AppRadius.borderRadiusXS,
                ),
                child: Text(
                  contact.statusTitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            contact.message,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
              SizedBox(width: 4),
              Text(
                contact.createdAt,
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
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
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.phone_outlined,
                  color: AppColors.success,
                  size: 32,
                ),
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
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusSM,
                    ),
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
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.headset_mic_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
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
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.chat),
                  label: Text(
                    'Sohbet Başlat',
                    style: AppTypography.buttonMedium,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusSM,
                    ),
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
    final messageController = TextEditingController();
    ContactSubject? selectedSubject;
    List<ContactSubject> subjects = [];
    bool isLoading = true;
    bool isSending = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          // İlk açılışta konuları yükle
          if (isLoading && subjects.isEmpty) {
            _contactService.getContactSubjects().then((response) {
              if (response != null && response.isSuccess) {
                setSheetState(() {
                  subjects = response.subjects;
                  if (subjects.isNotEmpty) {
                    selectedSubject = subjects.first;
                  }
                  isLoading = false;
                });
              } else {
                setSheetState(() {
                  isLoading = false;
                });
              }
            });
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
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
                      Center(
                        child: Text('E-posta Gönder', style: AppTypography.h4),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      Text(
                        'Konu',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      if (isLoading)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else if (subjects.isEmpty)
                        Container(
                          padding: EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppRadius.borderRadiusSM,
                          ),
                          child: Text(
                            'Konular yüklenemedi',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppRadius.borderRadiusSM,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ContactSubject>(
                              value: selectedSubject,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary,
                              ),
                              dropdownColor: AppColors.surface,
                              items: subjects.map((subject) {
                                return DropdownMenuItem<ContactSubject>(
                                  value: subject,
                                  child: Text(
                                    subject.subjectName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setSheetState(() {
                                  selectedSubject = value;
                                });
                              },
                            ),
                          ),
                        ),
                      SizedBox(height: AppSpacing.lg),
                      Text(
                        'Mesaj',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: messageController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Mesajınızı yazınız',
                          hintStyle: TextStyle(color: AppColors.textTertiary),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.borderRadiusSM,
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.all(AppSpacing.md),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              (isSending ||
                                  selectedSubject == null ||
                                  messageController.text.trim().isEmpty)
                              ? null
                              : () async {
                                  setSheetState(() {
                                    isSending = true;
                                  });

                                  final response = await _contactService
                                      .sendContactMessage(
                                        subjectId: selectedSubject!.subjectID,
                                        message: messageController.text.trim(),
                                      );

                                  setSheetState(() {
                                    isSending = false;
                                  });

                                  if (response != null && response.isSuccess) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            SizedBox(width: AppSpacing.sm),
                                            Expanded(
                                              child: Text(
                                                response.successMessage ??
                                                    'E-posta gönderildi',
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(AppSpacing.md),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              AppRadius.borderRadiusSM,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            SizedBox(width: AppSpacing.sm),
                                            Text('Mesaj gönderilemedi'),
                                          ],
                                        ),
                                        backgroundColor: AppColors.error,
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(AppSpacing.md),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              AppRadius.borderRadiusSM,
                                        ),
                                      ),
                                    );
                                  }
                                },
                          icon: isSending
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(Icons.send),
                          label: Text(
                            isSending ? 'Gönderiliyor...' : 'Gönder',
                            style: AppTypography.buttonMedium,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.borderRadiusSM,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
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
                    Center(
                      child: Text('Destek Talebi', style: AppTypography.h4),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final isSelected = selectedCategory == category;
                        return GestureDetector(
                          onTap: () =>
                              setSheetState(() => selectedCategory = category),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.background,
                              borderRadius: AppRadius.borderRadiusSM,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      'Açıklama',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Sorununuzu detaylı açıklayınız',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.borderRadiusSM,
                          borderSide: BorderSide.none,
                        ),
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
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  Text('Destek talebiniz oluşturuldu'),
                                ],
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(AppSpacing.md),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.borderRadiusSM,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.borderRadiusSM,
                          ),
                        ),
                        child: Text(
                          'Talep Oluştur',
                          style: AppTypography.buttonMedium,
                        ),
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
