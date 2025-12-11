import 'package:flutter/material.dart';
import 'contract_viewer_page.dart';
import '../../services/contract_service.dart';

class KVKKPolicyPage extends StatelessWidget {
  const KVKKPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ContractViewerPage(
      title: 'KVKK Aydınlatma Metni',
      loadContract: () => ContractService().getKVKKPolicy(),
    );
  }
}
