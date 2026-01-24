import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/challenge_report_model.dart';
import '../../data/services/challenge_moderation_service.dart';

/// Dialog for reporting content in challenges
class ChallengeReportDialog extends ConsumerStatefulWidget {
  final ReportableContentType contentType;
  final String contentId;
  final String? challengeId;
  final String? reportedUserId;
  final String? contentPreview;

  const ChallengeReportDialog({
    super.key,
    required this.contentType,
    required this.contentId,
    this.challengeId,
    this.reportedUserId,
    this.contentPreview,
  });

  /// Show the report dialog
  static Future<bool> show({
    required BuildContext context,
    required ReportableContentType contentType,
    required String contentId,
    String? challengeId,
    String? reportedUserId,
    String? contentPreview,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ChallengeReportDialog(
        contentType: contentType,
        contentId: contentId,
        challengeId: challengeId,
        reportedUserId: reportedUserId,
        contentPreview: contentPreview,
      ),
    );
    return result ?? false;
  }

  @override
  ConsumerState<ChallengeReportDialog> createState() =>
      _ChallengeReportDialogState();
}

class _ChallengeReportDialogState extends ConsumerState<ChallengeReportDialog> {
  ReportReason? _selectedReason;
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.flag, color: colorScheme.error),
          const SizedBox(width: 8),
          const Text('Report Content'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content preview
              if (widget.contentPreview != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.contentPreview!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Text(
                'Why are you reporting this?',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // Report reasons
              ...ReportReason.values.map((reason) => _ReasonTile(
                    reason: reason,
                    isSelected: _selectedReason == reason,
                    onTap: () => setState(() => _selectedReason = reason),
                  )),

              const SizedBox(height: 16),

              // Additional details
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Additional details (optional)',
                  hintText: 'Provide more context...',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                maxLength: 500,
              ),

              const SizedBox(height: 8),

              // Info text
              Text(
                'Reports are reviewed by our team. False reports may result in action against your account.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedReason == null || _isSubmitting
              ? null
              : _submitReport,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit Report'),
        ),
      ],
    );
  }

  Future<void> _submitReport() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || _selectedReason == null) return;

    setState(() => _isSubmitting = true);

    try {
      final service = ref.read(challengeModerationServiceProvider);
      await service.submitReport(
        reporterId: userId,
        contentType: widget.contentType,
        contentId: widget.contentId,
        reason: _selectedReason!,
        challengeId: widget.challengeId,
        reportedUserId: widget.reportedUserId,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted. Thank you for helping keep our community safe.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

/// Single reason tile
class _ReasonTile extends StatelessWidget {
  final ReportReason reason;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReasonTile({
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getReasonLabel(reason),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w500 : null,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReasonLabel(ReportReason reason) {
    switch (reason) {
      case ReportReason.spam:
        return 'Spam or misleading';
      case ReportReason.harassment:
        return 'Harassment or bullying';
      case ReportReason.inappropriateContent:
        return 'Inappropriate content';
      case ReportReason.falseInformation:
        return 'False information';
      case ReportReason.hateSpeech:
        return 'Hate speech';
      case ReportReason.violence:
        return 'Violence or threats';
      case ReportReason.privacyViolation:
        return 'Privacy violation';
      case ReportReason.cheating:
        return 'Cheating or unfair play';
      case ReportReason.other:
        return 'Other';
    }
  }
}

/// Block user confirmation dialog
class BlockUserDialog extends StatelessWidget {
  final String userName;
  final VoidCallback onBlock;

  const BlockUserDialog({
    super.key,
    required this.userName,
    required this.onBlock,
  });

  static Future<bool> show({
    required BuildContext context,
    required String userName,
  }) async {
    bool blocked = false;
    await showDialog(
      context: context,
      builder: (context) => BlockUserDialog(
        userName: userName,
        onBlock: () {
          blocked = true;
          Navigator.pop(context);
        },
      ),
    );
    return blocked;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.block, color: colorScheme.error),
          const SizedBox(width: 8),
          const Text('Block User'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Are you sure you want to block $userName?'),
          const SizedBox(height: 16),
          Text(
            'When you block someone:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _buildBulletPoint(context, 'They won\'t be able to see your activity'),
          _buildBulletPoint(context, 'You won\'t see their activity'),
          _buildBulletPoint(context, 'They can\'t send you invitations'),
          _buildBulletPoint(context, 'You can unblock them anytime'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: onBlock,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
          ),
          child: const Text('Block'),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// More options menu for challenge content
class ChallengeContentMenu extends StatelessWidget {
  final String contentId;
  final ReportableContentType contentType;
  final String? challengeId;
  final String? userId;
  final String? userName;
  final String? contentPreview;
  final bool isOwnContent;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ChallengeContentMenu({
    super.key,
    required this.contentId,
    required this.contentType,
    this.challengeId,
    this.userId,
    this.userName,
    this.contentPreview,
    this.isOwnContent = false,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (context) => [
        if (isOwnContent && onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (isOwnContent && onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (!isOwnContent) ...[
          const PopupMenuItem(
            value: 'report',
            child: ListTile(
              leading: Icon(Icons.flag),
              title: Text('Report'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (userId != null)
            const PopupMenuItem(
              value: 'block',
              child: ListTile(
                leading: Icon(Icons.block),
                title: Text('Block User'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _handleMenuAction(BuildContext context, String action) async {
    switch (action) {
      case 'edit':
        onEdit?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
      case 'report':
        await ChallengeReportDialog.show(
          context: context,
          contentType: contentType,
          contentId: contentId,
          challengeId: challengeId,
          reportedUserId: userId,
          contentPreview: contentPreview,
        );
        break;
      case 'block':
        if (userName != null) {
          final blocked = await BlockUserDialog.show(
            context: context,
            userName: userName!,
          );
          if (blocked && context.mounted) {
            // Handle block action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$userName has been blocked')),
            );
          }
        }
        break;
    }
  }
}
