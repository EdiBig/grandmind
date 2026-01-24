import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/challenge_report_model.dart';
import '../../data/services/challenge_moderation_service.dart';

/// Screen for challenge creators to manage moderation settings
class ChallengeModerationScreen extends ConsumerStatefulWidget {
  final String challengeId;
  final String challengeName;

  const ChallengeModerationScreen({
    super.key,
    required this.challengeId,
    required this.challengeName,
  });

  @override
  ConsumerState<ChallengeModerationScreen> createState() =>
      _ChallengeModerationScreenState();
}

class _ChallengeModerationScreenState
    extends ConsumerState<ChallengeModerationScreen> {
  ChallengeModerationSettings _settings = const ChallengeModerationSettings();
  bool _isLoading = true;
  bool _isSaving = false;
  final _bannedWordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _bannedWordController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final service = ref.read(challengeModerationServiceProvider);
      final settings = await service.getModerationSettings(widget.challengeId);
      if (mounted) {
        setState(() {
          _settings = settings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load settings: $e')),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isSaving = true);

    try {
      final service = ref.read(challengeModerationServiceProvider);
      await service.updateModerationSettings(
        challengeId: widget.challengeId,
        userId: userId,
        settings: _settings,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _addBannedWord() {
    final word = _bannedWordController.text.trim().toLowerCase();
    if (word.isEmpty) return;

    if (_settings.bannedWords.contains(word)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Word already in list')),
      );
      return;
    }

    setState(() {
      _settings = _settings.copyWith(
        bannedWords: [..._settings.bannedWords, word],
      );
    });
    _bannedWordController.clear();
  }

  void _removeBannedWord(String word) {
    setState(() {
      _settings = _settings.copyWith(
        bannedWords: _settings.bannedWords.where((w) => w != word).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderation Settings'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveSettings,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Challenge name header
                  Text(
                    widget.challengeName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Content moderation section
                  _buildSectionHeader(context, 'Content Moderation'),
                  const SizedBox(height: 8),

                  _buildSwitchTile(
                    context,
                    title: 'Auto-moderate activity feed',
                    subtitle: 'Automatically filter reported content',
                    value: _settings.autoModerateActivityFeed,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(
                          autoModerateActivityFeed: value,
                        );
                      });
                    },
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Hide offensive content',
                    subtitle: 'Auto-hide content flagged by the system',
                    value: _settings.hideOffensiveContent,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(
                          hideOffensiveContent: value,
                        );
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Joining settings
                  _buildSectionHeader(context, 'Joining Settings'),
                  const SizedBox(height: 8),

                  _buildSwitchTile(
                    context,
                    title: 'Require approval to join',
                    subtitle: 'New members must be approved by you',
                    value: _settings.requireApprovalToJoin,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(
                          requireApprovalToJoin: value,
                        );
                      });
                    },
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Allow participant invites',
                    subtitle: 'Let members invite others to join',
                    value: _settings.allowParticipantInvites,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(
                          allowParticipantInvites: value,
                        );
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // New participant settings
                  _buildSectionHeader(context, 'New Participants'),
                  const SizedBox(height: 8),

                  _buildSwitchTile(
                    context,
                    title: 'Mute new participants',
                    subtitle: 'New members cannot post for a period',
                    value: _settings.muteNewParticipants,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(
                          muteNewParticipants: value,
                        );
                      });
                    },
                  ),

                  if (_settings.muteNewParticipants) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Mute duration:',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<int>(
                            value: _settings.muteNewParticipantsDuration.inHours,
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('1 hour')),
                              DropdownMenuItem(value: 6, child: Text('6 hours')),
                              DropdownMenuItem(value: 12, child: Text('12 hours')),
                              DropdownMenuItem(value: 24, child: Text('24 hours')),
                              DropdownMenuItem(value: 48, child: Text('48 hours')),
                              DropdownMenuItem(value: 72, child: Text('72 hours')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _settings = _settings.copyWith(
                                    muteNewParticipantsDuration: Duration(hours: value),
                                  );
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Banned words section
                  _buildSectionHeader(context, 'Banned Words'),
                  const SizedBox(height: 8),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Posts containing these words will be automatically hidden.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 12),

                          // Add word input
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _bannedWordController,
                                  decoration: const InputDecoration(
                                    hintText: 'Add a word...',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  onSubmitted: (_) => _addBannedWord(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                onPressed: _addBannedWord,
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),

                          if (_settings.bannedWords.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _settings.bannedWords.map((word) {
                                return Chip(
                                  label: Text(word),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () => _removeBannedWord(word),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // View reports button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChallengeReportsScreen(
                              challengeId: widget.challengeId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.flag),
                      label: const Text('View Reports'),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// Screen showing reports for a challenge
class ChallengeReportsScreen extends ConsumerStatefulWidget {
  final String challengeId;

  const ChallengeReportsScreen({
    super.key,
    required this.challengeId,
  });

  @override
  ConsumerState<ChallengeReportsScreen> createState() =>
      _ChallengeReportsScreenState();
}

class _ChallengeReportsScreenState
    extends ConsumerState<ChallengeReportsScreen> {
  List<ChallengeReport>? _reports;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final service = ref.read(challengeModerationServiceProvider);
      final reports = await service.getChallengeReports(widget.challengeId);
      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reports: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports == null || _reports!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reports',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your challenge is running smoothly!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports!.length,
                    itemBuilder: (context, index) {
                      return _ReportCard(report: _reports![index]);
                    },
                  ),
                ),
    );
  }
}

/// Card displaying a single report
class _ReportCard extends StatelessWidget {
  final ChallengeReport report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _buildStatusChip(context, report.status),
                const Spacer(),
                Text(
                  _formatDate(report.createdAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Reason
            Row(
              children: [
                Icon(
                  Icons.flag,
                  size: 16,
                  color: colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  report.reasonDisplay,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),

            // Description
            if (report.description != null &&
                report.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],

            // Content type
            const SizedBox(height: 8),
            Text(
              'Reported: ${_getContentTypeName(report.contentType)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ReportStatus status) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case ReportStatus.pending:
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        label = 'Pending';
        break;
      case ReportStatus.underReview:
        backgroundColor = colorScheme.tertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        label = 'Under Review';
        break;
      case ReportStatus.resolved:
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        label = 'Resolved';
        break;
      case ReportStatus.dismissed:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurfaceVariant;
        label = 'Dismissed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  String _getContentTypeName(ReportableContentType type) {
    switch (type) {
      case ReportableContentType.challenge:
        return 'Challenge';
      case ReportableContentType.activity:
        return 'Activity post';
      case ReportableContentType.participant:
        return 'Participant';
      case ReportableContentType.message:
        return 'Message';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
