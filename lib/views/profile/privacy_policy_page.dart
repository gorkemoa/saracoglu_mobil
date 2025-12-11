import 'package:flutter/material.dart';
import 'contract_viewer_page.dart';
import '../../services/contract_service.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ContractViewerPage(
      title: 'Gizlilik Politikası',
      loadContract: () => ContractService().getPrivacyPolicy(),
    );
  }
}
