import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../providers/providers.dart';

/// Circle admin settings screen for managing circle info, members, and settings
class CircleSettingsScreen extends ConsumerStatefulWidget {
  const CircleSettingsScreen({
    super.key,
    required this.circleId,
  });

  final String circleId;

  @override
  ConsumerState<CircleSettingsScreen> createState() =>
      _CircleSettingsScreenState();
}

class _CircleSettingsScreenState extends ConsumerState<CircleSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circleAsync = ref.watch(circleByIdProvider(widget.circleId));
    final membersAsync = ref.watch(circleMembersProvider(widget.circleId));
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return circleAsync.when(
      data: (circle) {
        if (circle == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Circle not found')),
          );
        }

        // Initialize controllers with circle data
        if (_nameController.text.isEmpty) {
          _nameController.text = circle.name;
          _descriptionController.text = circle.description ?? '';
        }

        final isOwner = circle.isOwner(currentUserId ?? '');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Circle Settings'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circle info section
                _buildSectionHeader(context, 'Circle Info', Icons.info_outline),
                const SizedBox(height: 12),
                _buildCircleInfoSection(context, circle, isOwner),
                const SizedBox(height: 24),

                // Members section
                _buildSectionHeader(context, 'Members', Icons.people_outline),
                const SizedBox(height: 12),
                _buildMembersSection(context, ref, circle, membersAsync),
                const SizedBox(height: 24),

                // Invite settings section
                _buildSectionHeader(
                    context, 'Invite Settings', Icons.person_add_outlined),
                const SizedBox(height: 12),
                _buildInviteSettingsSection(context, circle),
                const SizedBox(height: 24),

                // Circle settings section
                _buildSectionHeader(context, 'Circle Settings', Icons.tune),
                const SizedBox(height: 12),
                _buildCircleSettingsSection(context, circle),
                const SizedBox(height: 24),

                // Danger zone
                if (isOwner) ...[
                  _buildSectionHeader(
                    context,
                    'Danger Zone',
                    Icons.warning_outlined,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  _buildDangerZoneSection(context, circle),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    Color? color,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCircleInfoSection(
    BuildContext context,
    Circle circle,
    bool isOwner,
  ) {
    final theme = Theme.of(context);

    if (_isEditing) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Circle Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _nameController.text = circle.name;
                          _descriptionController.text = circle.description ?? '';
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // TODO: Save circle info
                          setState(() => _isEditing = false);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(circle.name),
            subtitle: const Text('Circle Name'),
            trailing: isOwner
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => setState(() => _isEditing = true),
                  )
                : null,
          ),
          if (circle.description != null) ...[
            const Divider(height: 1),
            ListTile(
              title: Text(circle.description!),
              subtitle: const Text('Description'),
            ),
          ],
          const Divider(height: 1),
          ListTile(
            title: Text(circle.type.displayName),
            subtitle: const Text('Circle Type'),
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(circle.visibility.displayName),
            subtitle: const Text('Visibility'),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(
    BuildContext context,
    WidgetRef ref,
    Circle circle,
    AsyncValue<List<CircleMember>> membersAsync,
  ) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isAdmin = circle.isAdmin(currentUserId ?? '');

    return Card(
      child: membersAsync.when(
        data: (members) {
          return Column(
            children: [
              ListTile(
                title: Text('${members.length} Members'),
                subtitle: Text('Max ${circle.effectiveMaxMembers}'),
                trailing: isAdmin
                    ? IconButton(
                        icon: const Icon(Icons.person_add),
                        onPressed: () => _showInviteMemberSheet(context),
                      )
                    : null,
              ),
              const Divider(height: 1),
              ...members.take(5).map((member) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: member.avatarUrl != null
                        ? NetworkImage(member.avatarUrl!)
                        : null,
                    child: member.avatarUrl == null
                        ? Text(member.effectiveDisplayName[0].toUpperCase())
                        : null,
                  ),
                  title: Text(member.effectiveDisplayName),
                  subtitle: Text(member.role.displayName),
                  trailing: isAdmin && member.userId != currentUserId
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            _handleMemberAction(value, member, circle);
                          },
                          itemBuilder: (context) => [
                            if (member.role == CircleMemberRole.member)
                              const PopupMenuItem(
                                value: 'promote',
                                child: Text('Make Admin'),
                              ),
                            if (member.role == CircleMemberRole.admin &&
                                circle.isOwner(currentUserId ?? ''))
                              const PopupMenuItem(
                                value: 'demote',
                                child: Text('Remove Admin'),
                              ),
                            const PopupMenuItem(
                              value: 'remove',
                              child: Text('Remove from Circle'),
                            ),
                          ],
                        )
                      : null,
                );
              }),
              if (members.length > 5)
                ListTile(
                  title: Text(
                    'View all ${members.length} members',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                  onTap: () {
                    // Navigate to full members list
                  },
                ),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $e'),
        ),
      ),
    );
  }

  Widget _buildInviteSettingsSection(BuildContext context, Circle circle) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Allow Member Invites'),
            subtitle: const Text('Let members invite others'),
            value: circle.settings.allowMemberInvites,
            onChanged: (value) {
              // TODO: Update setting
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Require Approval'),
            subtitle: const Text('Approve new members before they join'),
            value: circle.settings.requireApprovalToJoin,
            onChanged: (value) {
              // TODO: Update setting
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Invite Code'),
            subtitle: Text(circle.inviteCode ?? 'No invite code'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: circle.inviteCode != null
                      ? () {
                          // Copy to clipboard
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref
                        .read(generateInviteCodeProvider.notifier)
                        .generateCode(widget.circleId);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleSettingsSection(BuildContext context, Circle circle) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Show Member Activity'),
            subtitle: const Text('Display member activity in the feed'),
            value: circle.settings.showMemberActivity,
            onChanged: (value) {
              // TODO: Update setting
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Allow Challenge Creation'),
            subtitle: const Text('Let members create challenges'),
            value: circle.settings.allowChallengeCreation,
            onChanged: (value) {
              // TODO: Update setting
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Enable Cheers'),
            subtitle: const Text('Allow members to send encouragement'),
            value: circle.settings.enableCheers,
            onChanged: (value) {
              // TODO: Update setting
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Enable Activity Feed'),
            subtitle: const Text('Show activity feed in the circle'),
            value: circle.settings.enableActivityFeed,
            onChanged: (value) {
              // TODO: Update setting
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneSection(BuildContext context, Circle circle) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.errorContainer.withOpacity(0.3),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.archive_outlined,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Archive Circle',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Hide the circle but keep data'),
            onTap: () => _showArchiveDialog(context, circle),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Delete Circle',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Permanently delete this circle'),
            onTap: () => _showDeleteDialog(context, circle),
          ),
        ],
      ),
    );
  }

  void _showInviteMemberSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invite Members',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Share Invite Link'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('Show QR Code'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search for Users'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _handleMemberAction(String action, CircleMember member, Circle circle) {
    switch (action) {
      case 'promote':
        // TODO: Promote to admin
        break;
      case 'demote':
        // TODO: Remove admin status
        break;
      case 'remove':
        _showRemoveMemberDialog(context, member);
        break;
    }
  }

  void _showRemoveMemberDialog(BuildContext context, CircleMember member) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Member'),
          content:
              Text('Are you sure you want to remove ${member.displayName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                // TODO: Remove member
                Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _showArchiveDialog(BuildContext context, Circle circle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Archive Circle'),
          content: const Text(
            'Archiving will hide this circle from all members. You can restore it later.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                // TODO: Archive circle
                Navigator.pop(context);
                context.go('/unity/my-circles');
              },
              child: const Text('Archive'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Circle circle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Circle'),
          content: const Text(
            'Are you sure you want to permanently delete this circle? This action cannot be undone.\n\nAll challenges, posts, and member data will be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                // TODO: Delete circle
                Navigator.pop(context);
                context.go('/unity/my-circles');
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
