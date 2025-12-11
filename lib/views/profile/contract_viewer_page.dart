import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../theme/app_theme.dart';
import '../../models/contract/contract_model.dart';

class ContractViewerPage extends StatefulWidget {
  final String title;
  final Future<ContractResponse> Function() loadContract;

  const ContractViewerPage({
    super.key,
    required this.title,
    required this.loadContract,
  });

  @override
  State<ContractViewerPage> createState() => _ContractViewerPageState();
}

class _ContractViewerPageState extends State<ContractViewerPage> {
  bool _isLoading = true;
  ContractData? _contractData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchContract();
  }

  Future<void> _fetchContract() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await widget.loadContract();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.isSuccess && response.data != null) {
          _contractData = response.data;
        } else {
          _errorMessage = response.message ?? '${widget.title} yüklenemedi';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          _contractData?.postTitle ?? widget.title,
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: _fetchContract,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_contractData == null) {
      return Center(child: Text('İçerik bulunamadı'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusMD,
          boxShadow: AppShadows.shadowCard,
        ),
        child: Html(
          data: _contractData!.postContent,
          style: {
            "body": Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
              fontSize: FontSize(14),
              lineHeight: LineHeight(1.6),
            ),
            "p": Style(margin: Margins.only(bottom: 16)),
            "h1": Style(fontSize: FontSize(24), fontWeight: FontWeight.bold),
            "h2": Style(fontSize: FontSize(20), fontWeight: FontWeight.bold),
            "h3": Style(fontSize: FontSize(18), fontWeight: FontWeight.bold),
          },
        ),
      ),
    );
  }
}
