import 'package:flutter/material.dart';
import '../widgets/legal_document_view.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: const LegalDocumentView(
        assetPath: 'assets/data/about.md',
      ),
    );
  }
}
