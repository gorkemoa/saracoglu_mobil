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
    return GestureDetector(
      onTap: () => _navigateToProduct(comment),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusMD,
          boxShadow: AppShadows.shadowSM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ürün bilgisi
            Row(
              children: [
                ClipRRect(
                  borderRadius: AppRadius.borderRadiusSM,
                  child: Image.network(
                    comment.productImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.background,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.productTitle,
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      // Rating
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: i < comment.commentRating
                                  ? AppColors.accent
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
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            // Yorum içeriği
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppRadius.borderRadiusSM,
              ),
              child: Text(
                comment.commentDesc,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Alt bilgiler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tarih
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      comment.commentDate,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                // Onay durumu
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: comment.isApproved
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: AppRadius.borderRadiusSM,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        comment.isApproved
                            ? Icons.check_circle_outline
                            : Icons.schedule,
                        size: 14,
                        color: comment.isApproved
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      SizedBox(width: 4),
                      Text(
                        comment.commentApproval,
                        style: AppTypography.labelSmall.copyWith(
                          color: comment.isApproved
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Like/Dislike bilgisi
            if (comment.commentLike > 0 || comment.commentDislike > 0) ...[
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (comment.commentLike > 0) ...[
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 14,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${comment.commentLike}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                  ],
                  if (comment.commentDislike > 0) ...[
                    Icon(
                      Icons.thumb_down_outlined,
                      size: 14,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${comment.commentDislike}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
