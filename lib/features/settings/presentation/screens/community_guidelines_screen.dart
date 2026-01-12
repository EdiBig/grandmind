import 'package:flutter/material.dart';
import '../widgets/legal_document_view.dart';

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Guidelines'),
      ),
      body: const LegalDocumentView(
        assetPath: 'assets/data/community_guidelines.md',
      ),
    );
  }
}
