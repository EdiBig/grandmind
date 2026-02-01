import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Standalone feed view for a challenge
class ChallengeFeedScreen extends ConsumerStatefulWidget {
  const ChallengeFeedScreen({
    super.key,
    required this.challengeId,
  });

  final String challengeId;

  @override
  ConsumerState<ChallengeFeedScreen> createState() =>
      _ChallengeFeedScreenState();
}

class _ChallengeFeedScreenState extends ConsumerState<ChallengeFeedScreen> {
  final TextEditingController _postController = TextEditingController();

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final challengeAsync = ref.watch(challengeByIdProvider(widget.challengeId));
    final feedAsync = ref.watch(challengeFeedProvider(widget.challengeId));

    return Scaffold(
      appBar: AppBar(
        title: challengeAsync.when(
          data: (challenge) => Text(challenge?.name ?? 'Challenge Feed'),
          loading: () => const Text('Challenge Feed'),
          error: (_, __) => const Text('Challenge Feed'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(challengeFeedProvider(widget.challengeId));
        },
        child: feedAsync.when(
          data: (posts) {
            if (posts.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FeedPostCard(
                    post: post,
                    onCheer: () => _showCheerSheet(context, post),
                    onComment: () => _showCommentSheet(context, post),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostSheet(context),
        child: const Icon(Icons.add),
      ),
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
              Icons.forum_outlined,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No posts yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share your progress!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showCreatePostSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Post'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostSheet(BuildContext context) {
    final theme = Theme.of(context);
    bool isAnonymous = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Create Post',
                          style: theme.textTheme.titleLarge,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _postController,
                      decoration: const InputDecoration(
                        hintText: 'Share your progress, thoughts, or encouragement...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        FilterChip(
                          label: const Text('Post Anonymously'),
                          selected: isAnonymous,
                          onSelected: (value) {
                            setSheetState(() => isAnonymous = value);
                          },
                          avatar: Icon(
                            isAnonymous
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 18,
                          ),
                        ),
                        const Spacer(),
                        Consumer(
                          builder: (context, ref, child) {
                            final createState = ref.watch(createPostProvider);

                            return FilledButton(
                              onPressed: createState.isLoading
                                  ? null
                                  : () {
                                      if (_postController.text
                                          .trim()
                                          .isNotEmpty) {
                                        ref
                                            .read(createPostProvider.notifier)
                                            .createTextPost(
                                              text: _postController.text.trim(),
                                              challengeId: widget.challengeId,
                                              isAnonymous: isAnonymous,
                                            );
                                        _postController.clear();
                                        Navigator.pop(context);
                                      }
                                    },
                              child: createState.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Post'),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCheerSheet(BuildContext context, FeedPost post) {
    final theme = Theme.of(context);

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
                'Send Encouragement',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: CheerType.values.map((cheerType) {
                  return Consumer(
                    builder: (context, ref, child) {
                      return ActionChip(
                        avatar: Text(
                          cheerType.emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        label: Text(cheerType.displayName),
                        onPressed: () {
                          // TODO: Send cheer via cheer provider
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Sent "${cheerType.message}" to ${post.displayAuthorName}',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showCommentSheet(BuildContext context, FeedPost post) {
    final theme = Theme.of(context);
    final commentController = TextEditingController();
    final commentsAsync = ref.watch(postCommentsProvider(post.id));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Comments',
                        style: theme.textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: commentsAsync.when(
                    data: (comments) {
                      if (comments.isEmpty) {
                        return Center(
                          child: Text(
                            'No comments yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: comment.authorAvatarUrl != null
                                  ? NetworkImage(comment.authorAvatarUrl!)
                                  : null,
                              child: comment.authorAvatarUrl == null
                                  ? Text(
                                      comment.displayAuthorName[0].toUpperCase())
                                  : null,
                            ),
                            title: Text(comment.displayAuthorName),
                            subtitle: Text(comment.text),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Consumer(
                        builder: (context, ref, child) {
                          final addState = ref.watch(addCommentProvider);

                          return IconButton.filled(
                            onPressed: addState.isLoading
                                ? null
                                : () {
                                    if (commentController.text
                                        .trim()
                                        .isNotEmpty) {
                                      ref
                                          .read(addCommentProvider.notifier)
                                          .addComment(
                                            postId: post.id,
                                            text: commentController.text.trim(),
                                          );
                                      commentController.clear();
                                    }
                                  },
                            icon: addState.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
