import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Circle detail screen showing circle info, members, challenges, and feed
class CircleDetailScreen extends ConsumerStatefulWidget {
  const CircleDetailScreen({
    super.key,
    required this.circleId,
  });

  final String circleId;

  @override
  ConsumerState<CircleDetailScreen> createState() => _CircleDetailScreenState();
}

class _CircleDetailScreenState extends ConsumerState<CircleDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circleAsync = ref.watch(circleByIdProvider(widget.circleId));
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return circleAsync.when(
      data: (circle) {
        if (circle == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Circle not found')),
          );
        }

        final isAdmin = circle.isAdmin(currentUserId ?? '');

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildAppBar(context, circle, isAdmin),
                SliverToBoxAdapter(
                  child: _buildCircleHeader(context, circle),
                ),
                SliverPersistentHeader(
                  delegate: _TabBarDelegate(tabController: _tabController),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildFeedTab(context, circle),
                _buildMembersTab(context, circle),
                _buildChallengesTab(context, circle),
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

  Widget _buildAppBar(BuildContext context, Circle circle, bool isAdmin) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(circle.name),
        background: circle.coverImageUrl != null
            ? Image.network(
                circle.coverImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultBackground(context),
              )
            : _buildDefaultBackground(context),
      ),
      actions: [
        if (isAdmin)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/unity/circle/${widget.circleId}/settings'),
          ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'invite':
                _showInviteSheet(context, circle);
                break;
              case 'leave':
                _showLeaveDialog(context, circle);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'invite',
              child: ListTile(
                leading: Icon(Icons.person_add),
                title: Text('Invite Members'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'leave',
              child: ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Leave Circle'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultBackground(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildCircleHeader(BuildContext context, Circle circle) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar and basic info
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
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
                          circle.name.isNotEmpty
                              ? circle.name[0].toUpperCase()
                              : '?',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Chip(
                          label: Text(circle.type.displayName),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(circle.visibility.displayName),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${circle.memberCount} members',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.emoji_events,
                          size: 16,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${circle.activeChallengeCount} active challenges',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (circle.description != null) ...[
            const SizedBox(height: 16),
            Text(
              circle.description!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (circle.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: circle.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedTab(BuildContext context, Circle circle) {
    final feedAsync = ref.watch(circleFeedProvider(widget.circleId));

    return feedAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.forum_outlined,
            title: 'No posts yet',
            subtitle: 'Be the first to share something!',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FeedPostCard(post: posts[index]),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildMembersTab(BuildContext context, Circle circle) {
    final membersAsync = ref.watch(circleMembersProvider(widget.circleId));
    final theme = Theme.of(context);

    return membersAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.people_outline,
            title: 'No members',
            subtitle: 'Invite friends to join your circle!',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
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
              trailing: member.role == CircleMemberRole.owner
                  ? Icon(Icons.star, color: Colors.amber)
                  : member.role == CircleMemberRole.admin
                      ? Icon(Icons.shield, color: theme.colorScheme.primary)
                      : null,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildChallengesTab(BuildContext context, Circle circle) {
    // TODO: Add circle challenges provider
    return _buildEmptyState(
      context,
      icon: Icons.emoji_events_outlined,
      title: 'No circle challenges',
      subtitle: 'Create a challenge for your circle!',
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
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

  void _showInviteSheet(BuildContext context, Circle circle) {
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
              if (circle.inviteCode != null) ...[
                ListTile(
                  leading: const Icon(Icons.content_copy),
                  title: const Text('Share Invite Code'),
                  subtitle: Text(circle.inviteCode!),
                  onTap: () {
                    // Copy to clipboard
                    Navigator.pop(context);
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('Show QR Code'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share Link'),
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

  void _showLeaveDialog(BuildContext context, Circle circle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leave Circle'),
          content: Text('Are you sure you want to leave ${circle.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(leaveCircleProvider.notifier).leaveCircle(widget.circleId);
                Navigator.pop(context);
                context.pop();
              },
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate({required this.tabController});

  final TabController tabController;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: TabBar(
        controller: tabController,
        tabs: const [
          Tab(text: 'Feed'),
          Tab(text: 'Members'),
          Tab(text: 'Challenges'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
