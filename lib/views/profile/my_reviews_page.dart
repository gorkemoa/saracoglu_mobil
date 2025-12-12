import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/comment_service.dart';
import '../../models/comment/user_comment_model.dart';
import '../product_detail_page.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  final CommentService _commentService = CommentService();

  List<UserComment> _comments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _commentService.getUserComments();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response != null && response.success) {
          _comments = response.comments;
        } else {
          _errorMessage = 'Yorumlar yüklenemedi';
        }
      });
    }
  }

  void _navigateToProduct(UserComment comment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: comment.productID),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Değerlendirmelerim',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
          ? _buildErrorState()
          : _comments.isEmpty
          ? _buildEmptyState()
          : _buildCommentsList(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSpacing.md),
          Text(
            'Yorumlar yükleniyor...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage ?? 'Bir hata oluştu',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _loadComments,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
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
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rate_review_outlined,
                size: 56,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Henüz Değerlendirme Yok',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Satın aldığınız ürünleri değerlendirerek\ndiğer kullanıcılara yardımcı olabilirsiniz.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Ürünleri Keşfet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderRadiusMD,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    return RefreshIndicator(
      onRefresh: _loadComments,
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: _comments.length,
        itemBuilder: (context, index) {
          final comment = _comments[index];
          return _buildCommentCard(comment);
        },
      ),
    );
  }

  Widget _buildCommentCard(UserComment comment) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMD,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ürün Resmi
                    GestureDetector(
                      onTap: () => _navigateToProduct(comment),
                      child: ClipRRect(
                        borderRadius: AppRadius.borderRadiusSM,
                        child: Image.network(
                          comment.productImage,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 70,
                            height: 70,
                            color: AppColors.background,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    // Ürün Bilgileri ve Rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _navigateToProduct(comment),
                            child: Text(
                              comment.productTitle,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 4),
                          // Rating
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: i < comment.commentRating
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${comment.commentRating}/5',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          // Tarih
                          Text(
                            comment.commentDate,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            comment.commentApproval,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Menu Button
              Positioned(
                top: 4,
                right: 4,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editComment(comment);
                    } else if (value == 'delete') {
                      _deleteComment(comment);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Düzenle'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 8),
                          Text('Sil', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Yorum İçeriği (Eğer varsa)
          if (comment.commentDesc.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadius.borderRadiusSM,
                ),
                child: Text(
                  comment.commentDesc,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

          SizedBox(height: AppSpacing.md),

          // Action Button
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: SizedBox(
              height: 36,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _navigateToProduct(comment),
                icon: Icon(
                  Icons.storefront_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: Text(
                  'Ürüne Git',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusSM,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editComment(UserComment comment) {
    int _rating = comment.commentRating;
    bool _showName = comment.showName;
    final TextEditingController _controller = TextEditingController(
      text: comment.commentDesc,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (innerContext, setState) {
          return AlertDialog(
            title: Text('Yorumu Düzenle', style: AppTypography.h4),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Puanınız', style: AppTypography.labelMedium),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star_rounded,
                          color: index < _rating
                              ? AppColors.primary
                              : AppColors.border,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() => _rating = index + 1);
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      );
                    }),
                  ),
                  SizedBox(height: 16),
                  Text('Yorumunuz', style: AppTypography.labelMedium),
                  SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Ürün hakkında düşünceleriniz...',
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.borderRadiusSM,
                      ),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _showName,
                          onChanged: (val) {
                            setState(() => _showName = val ?? true);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('İsmim yorumda görünsün'),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'İptal',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_rating == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lütfen puan seçiniz')),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext); // Dialog'u kapat

                  // Loading göster
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (c) => Center(child: CircularProgressIndicator()),
                  );

                  final success = await _commentService.updateComment(
                    productID: comment.productID,
                    commentID: comment.commentID,
                    comment: _controller.text,
                    commentRating: _rating,
                    showName: _showName,
                  );

                  if (mounted) {
                    Navigator.of(context).pop(); // Loading'i kapat

                    if (success) {
                      _loadComments(); // Listeyi yenile
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Yorumunuz güncellendi'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Güncelleme başarısız oldu'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text('Güncelle'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteComment(UserComment comment) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Yorumu Sil', style: AppTypography.h4),
        content: Text('Bu yorumu silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'İptal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Dialog'u kapat

              // Loading göster
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (c) => Center(child: CircularProgressIndicator()),
              );

              final success = await _commentService.deleteComment(
                comment.commentID,
              );

              if (mounted) {
                Navigator.of(context).pop(); // Loading'i kapat

                if (success) {
                  _loadComments(); // Listeyi yenile
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Yorum silindi'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Silme işlemi başarısız oldu'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text('Sil', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
