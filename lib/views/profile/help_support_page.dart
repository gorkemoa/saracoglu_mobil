import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/contact_service.dart';
import '../../models/contact/contact_subject_model.dart';
import '../../models/contact/contact_info_model.dart';
import '../../models/contact/faq_model.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final ContactService _contactService = ContactService();

  // Data
  ContactInfo? _contactInfo;
  List<FAQCategory> _faqCategories = [];
  List<FAQItem> _faqItems = [];

  // UI State
  bool _isLoading = true;
  int _selectedTabIndex = 0;
  int? _selectedCategoryId;
  int _expandedFAQIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Paralel olarak tüm verileri çek
    final results = await Future.wait([
      _contactService.getContactInfos(),
      _contactService.getFAQCategories(),
      _contactService.getFAQList(),
    ]);

    setState(() {
      _contactInfo = (results[0] as ContactInfoResponse?)?.data;
      _faqCategories = (results[1] as FAQCategoriesResponse?)?.categories ?? [];
      _faqItems = (results[2] as FAQListResponse?)?.faqs ?? [];

      // İlk kategoriyi seç
      if (_faqCategories.isNotEmpty) {
        _selectedCategoryId = _faqCategories.first.catID;
      }

      _isLoading = false;
    });
  }

  List<FAQItem> get _filteredFAQs {
    if (_selectedCategoryId == null) return _faqItems;
    return _faqItems.where((faq) => faq.catID == _selectedCategoryId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        ),
        title: Text(
          'Yardım & Destek',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBanner(),
          _buildContactSection(),
          _buildTabSelector(),
          if (_selectedTabIndex == 0)
            _buildFAQSection()
          else
            _buildRequestsSection(),
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(color:  AppColors.textTertiary),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Size nasıl yardımcı olabiliriz?',
            style: AppTypography.h4.copyWith(color: Colors.white),
          ),
          if (_contactInfo != null && _contactInfo!.compExcerpt.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: AppRadius.borderRadiusSM,
              ),
              child: Text(
                _contactInfo!.compExcerpt,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.95),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('İletişim', style: AppTypography.h5),
          SizedBox(height: AppSpacing.md),

          // Telefon ve E-posta kartları
          Row(
            children: [
              Expanded(
                child: _buildContactCard(
                  icon: Icons.phone_outlined,
                  title: 'Müşteri Hizmetleri',
                  subtitle: _contactInfo?.compCustomerPhone ?? '0850 XXX XX XX',
                  color: AppColors.success,
                  onTap: () => _showCallSheet(),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildContactCard(
                  icon: Icons.mail_outlined,
                  title: 'E-posta',
                  subtitle: _contactInfo?.compEmail ?? 'info@example.com',
                  color: AppColors.info,
                  onTap: () => _launchEmail(),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Sosyal medya ve destek talebi
          _buildSupportRequestCard(),

          SizedBox(height: AppSpacing.md),

          // Sosyal medya
          if (_hasSocialMedia()) _buildSocialMediaSection(),
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
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusMD,
          border: Border.all(color: AppColors.border),
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
              style: AppTypography.labelMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(color: color),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportRequestCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showEmailSheet();
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusMD,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_note,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Destek Talebi Oluştur',
                    style: AppTypography.labelLarge,
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Sorularınız için bize yazın',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.borderRadiusSM,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasSocialMedia() {
    if (_contactInfo == null) return false;
    return _contactInfo!.compFacebook.isNotEmpty ||
        _contactInfo!.compInstagram.isNotEmpty ||
        _contactInfo!.compTwitter.isNotEmpty ||
        _contactInfo!.compYoutube.isNotEmpty;
  }

  Widget _buildSocialMediaSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusSM,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sosyal Medya', style: AppTypography.labelMedium),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (_contactInfo!.compFacebook.isNotEmpty)
                _buildSocialButton(
                  'Facebook',
                  Icons.facebook,
                  const Color(0xFF1877F2),
                  _contactInfo!.compFacebook,
                ),
              if (_contactInfo!.compInstagram.isNotEmpty)
                _buildSocialButton(
                  'Instagram',
                  Icons.camera_alt,
                  const Color(0xFFE4405F),
                  _contactInfo!.compInstagram,
                ),
              if (_contactInfo!.compTwitter.isNotEmpty)
                _buildSocialButton(
                  'X',
                  Icons.close,
                  const Color(0xFF000000),
                  _contactInfo!.compTwitter,
                ),
              if (_contactInfo!.compYoutube.isNotEmpty)
                _buildSocialButton(
                  'YouTube',
                  Icons.play_circle_filled,
                  const Color(0xFFFF0000),
                  _contactInfo!.compYoutube,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    String name,
    IconData icon,
    Color color,
    String url,
  ) {
    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: () => _launchUrl(url),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: AppRadius.borderRadiusSM,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusSM,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'Sıkça Sorulanlar',
              isSelected: _selectedTabIndex == 0,
              onTap: () => setState(() => _selectedTabIndex = 0),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              title: 'Taleplerim',
              isSelected: _selectedTabIndex == 1,
              onTap: () => setState(() => _selectedTabIndex = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.borderRadiusSM,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategori Seçici
          if (_faqCategories.isNotEmpty) ...[
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _faqCategories.length,
                itemBuilder: (context, index) {
                  final category = _faqCategories[index];
                  final isSelected = category.catID == _selectedCategoryId;
                  return Padding(
                    padding: EdgeInsets.only(right: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedCategoryId = category.catID;
                          _expandedFAQIndex = -1;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: AppRadius.borderRadiusRound,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category.catName,
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.lg),
          ],

          // FAQ Listesi
          if (_filteredFAQs.isEmpty)
            _buildEmptyFAQState()
          else
            ...List.generate(
              _filteredFAQs.length,
              (index) => _buildFAQItem(index),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyFAQState() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.help_outline, size: 48, color: AppColors.textTertiary),
          SizedBox(height: AppSpacing.md),
          Text(
            'Bu kategoride soru bulunmuyor',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(int index) {
    final item = _filteredFAQs[index];
    final isExpanded = _expandedFAQIndex == index;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
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
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _expandedFAQIndex = isExpanded ? -1 : index);
            },
            borderRadius: AppRadius.borderRadiusSM,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      item.faqTitle.isNotEmpty ? item.faqTitle : item.catName,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadius.borderRadiusSM,
                ),
                child: Text(
                  item.faqDesc,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsSection() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Destek Taleplerim', style: AppTypography.h5),
              TextButton.icon(
                onPressed: _showEmailSheet,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Yeni'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          FutureBuilder<UserContactFormsResponse?>(
            future: _contactService.getUserContactForms(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                );
              }

              final contacts = snapshot.data?.contacts ?? [];
              if (contacts.isEmpty) return _buildEmptyRequestsState();

              return Column(
                children: contacts.map((c) => _buildRequestCard(c)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRequestsState() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text('Henüz talebiniz yok', style: AppTypography.labelLarge),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Yardıma ihtiyacınız olduğunda\nbize yazabilirsiniz.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall,
          ),
          SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: _showEmailSheet,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Talep Oluştur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(UserContactForm contact) {

  

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusSM,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  contact.subjectTitle,
                  style: AppTypography.labelLarge,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                 color: Colors.green,
                  borderRadius: AppRadius.borderRadiusRound,
                ),
                child: Text(
                  contact.statusTitle,
                  style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            contact.message,
            style: AppTypography.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            contact.createdAt,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Sheets
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
                child: const Icon(
                  Icons.phone,
                  color: AppColors.success,
                  size: 28,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text('Müşteri Hizmetleri', style: AppTypography.h5),
              SizedBox(height: AppSpacing.sm),
              Text(
                _contactInfo?.compCustomerPhone ?? '',
                style: AppTypography.h3.copyWith(color: AppColors.primary),
              ),
              if (_contactInfo != null &&
                  _contactInfo!.compExcerpt.isNotEmpty) ...[
                SizedBox(height: AppSpacing.md),
                Text(
                  _contactInfo!.compExcerpt,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall,
                ),
              ],
              SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _launchPhone(_contactInfo?.compCustomerPhone ?? '');
                  },
                  icon: const Icon(Icons.call),
                  label: const Text('Şimdi Ara'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
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
          if (isLoading && subjects.isEmpty) {
            _contactService.getContactSubjects().then((response) {
              if (response != null && response.isSuccess) {
                setSheetState(() {
                  subjects = response.subjects;
                  if (subjects.isNotEmpty) selectedSubject = subjects.first;
                  isLoading = false;
                });
              } else {
                setSheetState(() => isLoading = false);
              }
            });
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.border),
                        ),
                      ),
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
                          SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit_note,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Destek Talebi',
                                      style: AppTypography.h5,
                                    ),
                                    Text(
                                      'En kısa sürede dönüş yapacağız',
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Form
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Konu', style: AppTypography.labelLarge),
                            SizedBox(height: AppSpacing.sm),
                            if (isLoading)
                              Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: AppRadius.borderRadiusSM,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            else if (subjects.isEmpty)
                              Container(
                                padding: EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: AppRadius.borderRadiusSM,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: AppColors.error,
                                      size: 18,
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Konular yüklenemedi',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
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
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<ContactSubject>(
                                    value: selectedSubject,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: subjects
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s.subjectName),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) => setSheetState(
                                      () => selectedSubject = v,
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: AppSpacing.lg),
                            Text('Mesajınız', style: AppTypography.labelLarge),
                            SizedBox(height: AppSpacing.sm),
                            TextField(
                              controller: messageController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'Sorununuzu detaylı açıklayınız...',
                                hintStyle: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.borderRadiusSM,
                                  borderSide: BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.borderRadiusSM,
                                  borderSide: BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.borderRadiusSM,
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (_) => setSheetState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Submit
                    Container(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          top: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              (isSending ||
                                  selectedSubject == null ||
                                  messageController.text.trim().isEmpty)
                              ? null
                              : () async {
                                  setSheetState(() => isSending = true);
                                  final response = await _contactService
                                      .sendContactMessage(
                                        subjectId: selectedSubject!.subjectID,
                                        message: messageController.text.trim(),
                                      );
                                  setSheetState(() => isSending = false);

                                  if (response != null && response.isSuccess) {
                                    Navigator.pop(context);
                                    _showSnackBar(
                                      response.successMessage ??
                                          'Mesajınız gönderildi!',
                                      true,
                                    );
                                    setState(() {});
                                  } else {
                                    _showSnackBar('Mesaj gönderilemedi', false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.border,
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                          ),
                          child: isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Gönder'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
      ),
    );
  }

  // URL Launchers
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail() async {
    if (_contactInfo?.compEmail == null) return;
    final uri = Uri.parse('mailto:${_contactInfo!.compEmail}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
