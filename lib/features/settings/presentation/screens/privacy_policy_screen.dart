import 'package:flutter/material.dart';
import '../widgets/legal_document_view.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const LegalDocumentView(
        assetPath: 'assets/data/privacy_policy.md',
      ),
    );
  }
}
