import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// GDPR consent checkbox widget
///
/// Shows a checkbox with rich text label, link to full text,
/// and required indicator.
class ConsentCheckbox extends StatelessWidget {
  const ConsentCheckbox({
    super.key,
    required this.consentType,
    required this.isChecked,
    required this.onChanged,
    this.onViewFullText,
    this.version = 1,
    this.showDescription = true,
  });

  /// The type of consent
  final ConsentType consentType;

  /// Whether the checkbox is checked
  final bool isChecked;

  /// Callback when checkbox state changes
  final ValueChanged<bool?> onChanged;

  /// Callback to view full consent text
  final VoidCallback? onViewFullText;

  /// Version of the consent text
  final int version;

  /// Whether to show the description
  final bool showDescription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final consentText = ConsentText.currentVersions[consentType];

    return InkWell(
      onTap: () => onChanged(!isChecked),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            Checkbox(
              value: isChecked,
              onChanged: onChanged,
            ),
            const SizedBox(width: 8),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with required indicator
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          consentText?.title ?? consentType.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (consentType.isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Required',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  if (showDescription && consentText?.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      consentText!.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  // View full text link
                  if (onViewFullText != null) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onViewFullText,
                      child: Text(
                        'View full text',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Multiple consent checkboxes in a group
class ConsentCheckboxGroup extends StatelessWidget {
  const ConsentCheckboxGroup({
    super.key,
    required this.consents,
    required this.onConsentChanged,
    this.onViewFullText,
  });

  /// Map of consent type to whether it's checked
  final Map<ConsentType, bool> consents;

  /// Callback when a consent is changed
  final void Function(ConsentType type, bool value) onConsentChanged;

  /// Callback to view full text of a consent
  final void Function(ConsentType type)? onViewFullText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedTypes = consents.keys.toList()
      ..sort((a, b) {
        // Required consents first
        if (a.isRequired && !b.isRequired) return -1;
        if (!a.isRequired && b.isRequired) return 1;
        return a.index.compareTo(b.index);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consent & Permissions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...sortedTypes.map((type) {
          return ConsentCheckbox(
            consentType: type,
            isChecked: consents[type] ?? false,
            onChanged: (value) => onConsentChanged(type, value ?? false),
            onViewFullText:
                onViewFullText != null ? () => onViewFullText!(type) : null,
          );
        }),
      ],
    );
  }
}

/// Full consent text dialog
class ConsentTextDialog extends StatelessWidget {
  const ConsentTextDialog({
    super.key,
    required this.consentType,
    this.onAccept,
    this.showAcceptButton = true,
  });

  final ConsentType consentType;
  final VoidCallback? onAccept;
  final bool showAcceptButton;

  /// Show the consent text dialog
  static Future<bool?> show({
    required BuildContext context,
    required ConsentType consentType,
    bool requireAccept = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: !requireAccept,
      builder: (context) => ConsentTextDialog(
        consentType: consentType,
        showAcceptButton: requireAccept,
        onAccept: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final consentText = ConsentText.currentVersions[consentType];

    return AlertDialog(
      title: Text(consentText?.title ?? consentType.displayName),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (consentText != null) ...[
              Text(
                consentText.fullText,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Version ${consentText.version} - Effective ${_formatDate(consentText.effectiveDate)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ] else
              Text(
                'Consent text not available.',
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(showAcceptButton ? 'Decline' : 'Close'),
        ),
        if (showAcceptButton)
          FilledButton(
            onPressed: onAccept ?? () => Navigator.of(context).pop(true),
            child: const Text('Accept'),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Health disclaimer consent card
class HealthDisclaimerCard extends StatelessWidget {
  const HealthDisclaimerCard({
    super.key,
    required this.isAccepted,
    required this.onChanged,
    this.onViewFullText,
  });

  final bool isAccepted;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onViewFullText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.health_and_safety,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Health Disclaimer',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Required',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Please read and acknowledge',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'I understand the physical nature of this challenge and will listen to my body. I will consult a physician if I have any health concerns.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: isAccepted,
                  onChanged: (value) => onChanged(value ?? false),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(!isAccepted),
                    child: Text(
                      'I have read and agree to the health disclaimer',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (onViewFullText != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onViewFullText,
                  child: const Text('View full text'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
