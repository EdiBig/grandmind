import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../providers/providers.dart';

/// Screen showing user's circles with create option and pending invites
class MyCirclesScreen extends ConsumerWidget {
  const MyCirclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final circlesAsync = ref.watch(userCirclesProvider);
    final pendingInvitesAsync = ref.watch(pendingCircleInvitesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Circles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/unity/create-circle'),
            tooltip: 'Create Circle',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userCirclesProvider);
          ref.invalidate(pendingCircleInvitesProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Pending invites section
            pendingInvitesAsync.when(
              data: (invites) {
                if (invites.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverToBoxAdapter(
                  child: _buildPendingInvitesSection(context, ref, invites),
                );
              },
              loading: () =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // Join by code card
            SliverToBoxAdapter(
              child: _buildJoinByCodeCard(context),
            ),

            // My circles header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'My Circles',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Circles list
            circlesAsync.when(
              data: (circles) {
                if (circles.isEmpty) {
                  return SliverFillRemaining(
                    child: _buildEmptyState(context),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final circle = circles[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CircleListTile(
                            circle: circle,
                            onTap: () =>
                                context.push('/unity/circle/${circle.id}'),
                          ),
                        );
                      },
                      childCount: circles.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $e')),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/unity/create-circle'),
        icon: const Icon(Icons.add),
        label: const Text('Create Circle'),
      ),
    );
  }

  Widget _buildPendingInvitesSection(
    BuildContext context,
    WidgetRef ref,
    List<CircleInvite> invites,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.mail_outline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Pending Invites (${invites.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...invites.map((invite) => _InviteCard(
                invite: invite,
                onAccept: () {
                  ref.read(respondToInviteProvider.notifier).acceptInvite(invite);
                },
                onDecline: () {
                  ref.read(respondToInviteProvider.notifier).declineInvite(invite.id);
                },
              )),
        ],
      ),
    );
  }

  Widget _buildJoinByCodeCard(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.qr_code,
              color: theme.colorScheme.primary,
            ),
          ),
          title: const Text('Join with Invite Code'),
          subtitle: const Text('Enter a code from a friend'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showJoinByCodeDialog(context),
        ),
      ),
    );
  }

  void _showJoinByCodeDialog(BuildContext context) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final joinState = ref.watch(joinCircleProvider);

            return AlertDialog(
              title: const Text('Join Circle'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Invite Code',
                      hintText: 'Enter invite code',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  if (joinState.hasError) ...[
                    const SizedBox(height: 12),
                    Text(
                      joinState.error.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: joinState.isLoading
                      ? null
                      : () {
                          if (codeController.text.isNotEmpty) {
                            ref
                                .read(joinCircleProvider.notifier)
                                .joinByInviteCode(codeController.text.trim());
                          }
                        },
                  child: joinState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Join'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No circles yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a circle or join one with an invite code',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleListTile extends StatelessWidget {
  const _CircleListTile({
    required this.circle,
    this.onTap,
  });

  final Circle circle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circle.theme != null
                ? Color(int.parse(circle.theme!.replaceFirst('#', '0xFF')))
                : theme.colorScheme.primaryContainer,
            image: circle.avatarUrl != null
                ? DecorationImage(
                    image: NetworkImage(circle.avatarUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: circle.avatarUrl == null
              ? Center(
                  child: Text(
                    circle.name.isNotEmpty ? circle.name[0].toUpperCase() : '?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
        title: Text(
          circle.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          children: [
            Text(circle.type.displayName),
            const SizedBox(width: 8),
            Text(
              '${circle.memberCount} members',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (circle.activeChallengeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${circle.activeChallengeCount}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({
    required this.invite,
    required this.onAccept,
    required this.onDecline,
  });

  final CircleInvite invite;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Circle Invite',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (invite.message != null)
                  Text(
                    invite.message!,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: onDecline,
            child: const Text('Decline'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onAccept,
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}
