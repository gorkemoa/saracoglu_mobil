import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class LegalDocument {
  final String title;
  final String lastUpdated;
  final IconData icon;
  final String content;

  LegalDocument({
    required this.title,
    required this.lastUpdated,
    required this.icon,
    required this.content,
  });
}

class LegalInfoPage extends StatefulWidget {
  const LegalInfoPage({super.key});

  @override
  State<LegalInfoPage> createState() => _LegalInfoPageState();
}

class _LegalInfoPageState extends State<LegalInfoPage> {
  final List<LegalDocument> _documents = [
    LegalDocument(
      title: 'Kullanım Koşulları',
      lastUpdated: '15.01.2024',
      icon: Icons.description_outlined,
      content: '''
KULLANIM KOŞULLARI

1. GİRİŞ

Bu kullanım koşulları, Saraçoğlu mobil uygulaması ve web sitesinin kullanımını düzenler. Uygulamayı kullanarak bu koşulları kabul etmiş sayılırsınız.

2. HİZMETLERİN TANIMI

Saraçoğlu, doğal ve organik ürünlerin satışını gerçekleştiren bir e-ticaret platformudur. Kullanıcılarımıza kaliteli ve güvenilir ürünler sunmaktayız.

3. ÜYELİK

Hizmetlerimizden yararlanmak için üyelik oluşturmanız gerekmektedir. Üyelik bilgilerinizin doğruluğundan siz sorumlusunuz.

4. SİPARİŞ VE TESLİMAT

Siparişleriniz, stok durumuna göre 1-5 iş günü içinde kargoya verilir. Teslimat süreleri bölgenize göre değişiklik gösterebilir.

5. İADE VE DEĞİŞİM

Ürünlerimizde 14 gün içinde koşulsuz iade hakkınız bulunmaktadır. İade sürecinde ürünün kullanılmamış ve orijinal ambalajında olması gerekmektedir.

6. FİKRİ MÜLKİYET

Uygulama ve içeriklerinin tüm hakları Saraçoğlu'na aittir. İzinsiz kopyalama ve dağıtım yasaktır.
''',
    ),
    LegalDocument(
      title: 'Gizlilik Politikası',
      lastUpdated: '15.01.2024',
      icon: Icons.privacy_tip_outlined,
      content: '''
GİZLİLİK POLİTİKASI

1. KİŞİSEL VERİLERİN TOPLANMASI

Hizmetlerimizi kullanmanız sırasında ad, soyad, e-posta, telefon numarası ve adres bilgilerinizi topluyoruz.

2. VERİLERİN KULLANIMI

Topladığımız veriler sipariş işleme, müşteri desteği ve pazarlama faaliyetleri için kullanılmaktadır.

3. VERİ GÜVENLİĞİ

Kişisel verileriniz 256-bit SSL şifreleme ile korunmaktadır. Güvenlik önlemlerimizi sürekli güncel tutuyoruz.

4. ÜÇÜNCÜ TARAFLARLA PAYLAŞIM

Verileriniz, sipariş teslimatı için kargo firmaları ve ödeme işlemleri için ödeme kuruluşları ile paylaşılmaktadır.

5. ÇEREZLER

Deneyiminizi iyileştirmek için çerezler kullanmaktayız. Tarayıcı ayarlarınızdan çerez tercihlerinizi yönetebilirsiniz.

6. HAKLARINIZ

Verilerinize erişim, düzeltme ve silme haklarına sahipsiniz. Başvurularınız için destek@saracoglu.com adresine ulaşabilirsiniz.
''',
    ),
    LegalDocument(
      title: 'KVKK Aydınlatma Metni',
      lastUpdated: '15.01.2024',
      icon: Icons.security_outlined,
      content: '''
KVKK AYDINLATMA METNİ

6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında veri sorumlusu olarak aydınlatma yükümlülüğümüzü yerine getirmek amacıyla aşağıdaki bilgileri sunarız:

1. VERİ SORUMLUSU

Saraçoğlu Doğal Ürünler A.Ş. olarak kişisel verilerinizin işlenmesi ve korunmasına önem veriyoruz.

2. İŞLENEN KİŞİSEL VERİLER

- Kimlik Bilgileri: Ad, soyad, T.C. kimlik numarası
- İletişim Bilgileri: Telefon, e-posta, adres
- Finansal Bilgiler: Ödeme ve fatura bilgileri
- İşlem Güvenliği: IP adresi, giriş bilgileri

3. VERİ İŞLEME AMAÇLARI

- Sipariş süreçlerinin yürütülmesi
- Müşteri ilişkileri yönetimi
- Yasal yükümlülüklerin yerine getirilmesi
- Pazarlama faaliyetleri (onay dahilinde)

4. VERİ AKTARIMI

Kişisel verileriniz yasal yükümlülükler çerçevesinde yetkili kamu kuruluşlarına ve iş ortaklarımıza aktarılabilmektedir.

5. VERİ SAHİBİ HAKLARI

KVKK 11. maddesi kapsamında başvuru yaparak bilgi edinme, düzeltme, silme, itiraz etme haklarınızı kullanabilirsiniz.

6. BAŞVURU

kvkk@saracoglu.com adresine başvurabilirsiniz.
''',
    ),
    LegalDocument(
      title: 'Mesafeli Satış Sözleşmesi',
      lastUpdated: '15.01.2024',
      icon: Icons.handshake_outlined,
      content: '''
MESAFELİ SATIŞ SÖZLEŞMESİ

MADDE 1 - TARAFLAR

SATICI:
Saraçoğlu Doğal Ürünler A.Ş.
Adres: İstanbul, Türkiye
Tel: 0850 123 45 67

ALICI:
[Sipariş sırasında girilen bilgiler]

MADDE 2 - KONU

İşbu sözleşme, alıcının satıcıya ait internet sitesi veya mobil uygulama üzerinden sipariş verdiği ürünlerin satışı ve teslimatına ilişkin hak ve yükümlülükleri düzenler.

MADDE 3 - ÜRÜN BİLGİLERİ

Ürün bilgileri, fiyatı ve özellikleri sipariş sayfasında belirtilmiştir.

MADDE 4 - TESLİMAT

Siparişler, ödemenin onaylanmasından itibaren 1-5 iş günü içinde kargoya verilir.

MADDE 5 - CAYMA HAKKI

Tüketici, ürünü teslim aldığı tarihten itibaren 14 gün içinde herhangi bir gerekçe göstermeksizin cayma hakkını kullanabilir.

MADDE 6 - ÖDEME

Kredi kartı, banka kartı, havale/EFT ve kapıda ödeme kabul edilmektedir.

MADDE 7 - UYUŞMAZLIK

Uyuşmazlıklarda İstanbul Mahkemeleri ve İcra Daireleri yetkilidir.
''',
    ),
    LegalDocument(
      title: 'Çerez Politikası',
      lastUpdated: '15.01.2024',
      icon: Icons.cookie_outlined,
      content: '''
ÇEREZ POLİTİKASI

1. ÇEREZ NEDİR?

Çerezler, web siteleri ve uygulamalar tarafından cihazınıza yerleştirilen küçük metin dosyalarıdır.

2. KULLANILAN ÇEREZ TÜRLERİ

Zorunlu Çerezler:
Uygulamanın düzgün çalışması için gerekli olan çerezlerdir.

Performans Çerezleri:
Uygulama performansını analiz etmek için kullanılır.

İşlevsellik Çerezleri:
Tercihlerinizi hatırlamak için kullanılır.

Hedefleme/Reklam Çerezleri:
İlgi alanlarınıza uygun içerik sunmak için kullanılır.

3. ÇEREZ YÖNETİMİ

Tarayıcı veya cihaz ayarlarınızdan çerez tercihlerinizi yönetebilirsiniz.

4. ÜÇÜNCÜ TARAF ÇEREZLERİ

Google Analytics ve sosyal medya platformlarının çerezlerini kullanmaktayız.
''',
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
              'Yasal Bilgiler',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: true,
          ),

          // Açıklama
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.08),
                  borderRadius: AppRadius.borderRadiusSM,
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Yasal metinlerimizi inceleyebilir ve indirilebilirsiniz.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Döküman Listesi
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildDocumentCard(_documents[index]),
                ),
                childCount: _documents.length,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(LegalDocument document) {
    return GestureDetector(
      onTap: () => _showDocumentSheet(document),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusSM,
          boxShadow: AppShadows.shadowCard,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppRadius.borderRadiusSM,
              ),
              child: Icon(document.icon, color: AppColors.primary, size: 24),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Son güncelleme: ${document.lastUpdated}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.textTertiary, size: 16),
          ],
        ),
      ),
    );
  }

  void _showDocumentSheet(LegalDocument document) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
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
                            borderRadius: AppRadius.borderRadiusSM,
                          ),
                          child: Icon(document.icon, color: AppColors.primary, size: 22),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                document.title,
                                style: AppTypography.h4,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Son güncelleme: ${document.lastUpdated}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      // Alt butonlar
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.download_done, color: Colors.white, size: 18),
                                        SizedBox(width: AppSpacing.sm),
                                        Text('PDF indirildi'),
                                      ],
                                    ),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(AppSpacing.md),
                                    shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                                  ),
                                );
                              },
                              icon: Icon(Icons.download_outlined, size: 18),
                              label: Text('PDF İndir'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                                side: BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Paylaş
                              },
                              icon: Icon(Icons.share_outlined, size: 18),
                              label: Text('Paylaş'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                                side: BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
