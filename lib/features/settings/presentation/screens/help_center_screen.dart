import 'package:flutter/material.dart';
import '../widgets/legal_document_view.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
      ),
      body: const LegalDocumentView(
        assetPath: 'assets/data/help_centre.md',
      ),
    );
  }
}
