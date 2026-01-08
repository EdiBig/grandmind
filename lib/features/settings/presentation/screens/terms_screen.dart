import 'package:flutter/material.dart';
import '../widgets/legal_document_view.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: const LegalDocumentView(
        assetPath: 'assets/data/terms_of_service.md',
      ),
    );
  }
}
