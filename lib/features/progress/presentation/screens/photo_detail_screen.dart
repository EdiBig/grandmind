import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../domain/models/progress_photo.dart';
import '../providers/progress_providers.dart';

class PhotoDetailScreen extends ConsumerWidget {
  final ProgressPhoto photo;

  const PhotoDetailScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPhotoInfo(context),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation(context, ref);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: kIsWeb
              ? Image.network(
                  photo.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error, color: Colors.red, size: 48),
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: photo.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error, color: Colors.red, size: 48),
                  ),
                ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getAngleLabel(photo.angle),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('MMM d, yyyy').format(photo.date),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  if (photo.weight != null)
                    Text(
                      '${photo.weight!.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
              if (photo.notes != null && photo.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  photo.notes!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getAngleLabel(PhotoAngle angle) {
    switch (angle) {
      case PhotoAngle.front:
        return 'Front';
      case PhotoAngle.side:
        return 'Side';
      case PhotoAngle.back:
        return 'Back';
      case PhotoAngle.other:
        return 'Other';
    }
  }

  void _showPhotoInfo(BuildContext context) {
    final metadata = photo.metadata;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photo Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Date', DateFormat('EEEE, MMM d, yyyy').format(photo.date)),
            _buildInfoRow('Angle', _getAngleLabel(photo.angle)),
            if (photo.weight != null)
              _buildInfoRow('Weight', '${photo.weight!.toStringAsFixed(1)} kg'),
            if (metadata['width'] != null)
              _buildInfoRow('Dimensions', '${metadata['width']} × ${metadata['height']} px'),
            if (metadata['fileSize'] != null)
              _buildInfoRow('File Size', _formatFileSize(metadata['fileSize'] as int)),
            if (photo.notes != null && photo.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(photo.notes!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text(
          'Are you sure you want to delete this photo? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog

              final operations = ref.read(progressOperationsProvider.notifier);
              final success = await operations.deleteProgressPhoto(
                photo.id,
                photo.imageUrl,
              );

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Photo deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context); // Go back to photos screen
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete photo'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
