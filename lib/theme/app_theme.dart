import 'package:flutter/material.dart';

/// Saraçoğlu App Tema Ayarları
/// Tüm renk, font ve boşluk değerleri burada tanımlanır.
/// Uygulamanın tutarlı görünmesi için bu değerler kullanılmalıdır.

class AppColors {
  // Ana Renkler
  static const Color primary = Color(0xFF6DAA43);        // Yeşil - Ana marka rengi
  static const Color primaryLight = Color(0xFF8BC34A);   // Açık yeşil
  static const Color primaryDark = Color(0xFF4E7A30);    // Koyu yeşil
  
  // Arka Plan Renkleri
  static const Color background = Color(0xFFF9F9F4);     // Krem - Ana arka plan
  static const Color surface = Color(0xFFFFFFFF);        // Beyaz - Kart arka planları
  static const Color surfaceLight = Color(0xFFFAFAFA);   // Çok açık gri
  
  // Metin Renkleri
  static const Color textPrimary = Color(0xFF333333);    // Koyu metin - Başlıklar
  static const Color textSecondary = Color(0xFF666666);  // Orta metin - Alt başlıklar
  static const Color textTertiary = Color(0xFF999999);   // Açık metin - İpuçları
  static const Color textOnPrimary = Color(0xFFFFFFFF);  // Primary üzerindeki metin
  
  // Vurgu Renkleri
  static const Color accent = Color(0xFFE8C66B);         // Altın-sarı - Vurgu rengi
  static const Color accentLight = Color(0xFFF5E6C8);    // Açık altın
  
  // Durum Renkleri
  static const Color success = Color(0xFF4CAF50);        // Başarı - Yeşil
  static const Color warning = Color(0xFFFF9800);        // Uyarı - Turuncu
  static const Color error = Color(0xFFE53935);          // Hata - Kırmızı
  static const Color info = Color(0xFF2196F3);           // Bilgi - Mavi
  
  // İndirim ve Etiket Renkleri
  static const Color discount = Color(0xFFE53935);       // İndirim etiketi
  static const Color discountBackground = Color(0xFFFFEBEE); // İndirim arka planı
  static const Color badge = Color(0xFFE53935);          // Bildirim badge
  
  // Kenarlık ve Ayırıcı Renkleri
  static const Color border = Color(0xFFE0E0E0);         // Kenarlık
  static const Color divider = Color(0xFFF0F0F0);        // Ayırıcı çizgi
  
  // Gölge Renkleri
  static const Color shadow = Color(0x1A000000);         // %10 siyah
  static const Color shadowLight = Color(0x0D000000);    // %5 siyah
  
  // Kategori Renkleri
  static const Color categoryWomen = Color(0xFFE91E63);
  static const Color categoryMen = Color(0xFF2196F3);
  static const Color categoryKids = Color(0xFF4CAF50);
  static const Color categoryHome = Color(0xFF9C27B0);
  static const Color categoryMarket = Color(0xFFFF9800);
  static const Color categoryCosmetics = Color(0xFFE91E63);
  static const Color categoryShoes = Color(0xFF795548);
  static const Color categoryElectronics = Color(0xFF607D8B);
  
  // Gradient'ler
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6DAA43), Color(0xFF8BC34A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF6DAA43), Color(0xFF7CB850)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE8C66B), Color(0xFFF5D98A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient flashSaleGradient = LinearGradient(
    colors: [Colors.green.shade50, const Color(0xFFF9F9F4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTypography {
  // Font Ailesi
  static const String fontFamily = 'Roboto';
  
  // Başlık Stilleri
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle h5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  // Body Stilleri
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  // Label Stilleri
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    height: 1.3,
  );
  
  // Fiyat Stilleri
  static const TextStyle priceMain = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    height: 1.2,
  );
  
  static const TextStyle priceLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    height: 1.2,
  );
  
  static const TextStyle priceOld = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
    decoration: TextDecoration.lineThrough,
    height: 1.2,
  );
  
  // Buton Stilleri
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnPrimary,
    height: 1.2,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnPrimary,
    height: 1.2,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnPrimary,
    height: 1.2,
  );
  
  // Badge Stilleri
  static const TextStyle badge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnPrimary,
    height: 1.0,
  );
  
  static const TextStyle discountBadge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnPrimary,
    height: 1.0,
  );
  
  // Logo Stili
  static const TextStyle logo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnPrimary,
    letterSpacing: -0.5,
  );
}

class AppSpacing {
  // Temel Boşluklar
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  
  // Padding'ler
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  
  // Yatay Padding'ler
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  
  // Dikey Padding'ler
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);
  
  // Screen Padding
  static const EdgeInsets screenPadding = EdgeInsets.all(lg);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: lg);
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double round = 100.0;
  
  // BorderRadius
  static const BorderRadius borderRadiusXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderRadiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderRadiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderRadiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderRadiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderRadiusRound = BorderRadius.all(Radius.circular(round));
}

class AppShadows {
  static List<BoxShadow> shadowSM = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> shadowMD = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> shadowLG = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
  
  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> shadowNavBar = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 10,
      offset: const Offset(0, -2),
    ),
  ];
}

class AppSizes {
  // İkon Boyutları
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 28.0;
  static const double iconXL = 32.0;
  
  // Buton Boyutları
  static const double buttonHeightSM = 36.0;
  static const double buttonHeightMD = 44.0;
  static const double buttonHeightLG = 52.0;
  
  // Avatar Boyutları
  static const double avatarSM = 32.0;
  static const double avatarMD = 48.0;
  static const double avatarLG = 64.0;
  
  // Kart Boyutları
  static const double cardImageHeight = 120.0;
  static const double cardWidthSM = 140.0;
  static const double cardWidthMD = 155.0;
  static const double cardWidthLG = 180.0;
  
  // Banner Boyutları
  static const double bannerHeight = 160.0;
  
  // Ürün Kartı Boyutları
  static const double productCardWidth = 155.0;
  static const double productImageHeight = 120.0;
  
  // Category Icon Boyutları
  static const double categoryIconSize = 56.0;
  static const double categoryIconInnerSize = 28.0;
  
  // Quick Access Button Boyutları
  static const double quickButtonSize = 50.0;
  static const double quickButtonIconSize = 24.0;
  
  // Badge Boyutları
  static const double badgeSize = 16.0;
  static const double badgeSizeLG = 20.0;
  
  // Indicator Boyutları
  static const double indicatorActive = 20.0;
  static const double indicatorInactive = 8.0;
  static const double indicatorHeight = 4.0;
}

/// Ana Flutter Theme verisi
ThemeData getAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontFamily,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onError: AppColors.textOnPrimary,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeightMD),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusSM,
        ),
        textStyle: AppTypography.buttonMedium,
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeightMD),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusSM,
        ),
        textStyle: AppTypography.buttonMedium,
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.buttonMedium,
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: AppSpacing.paddingMD,
      border: OutlineInputBorder(
        borderRadius: AppRadius.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderRadiusSM,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
    ),
    
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusMD,
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
  );
}
