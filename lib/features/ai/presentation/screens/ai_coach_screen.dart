import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:kinesa/core/constants/route_constants.dart';
import 'package:kinesa/features/ai/presentation/providers/ai_providers.dart';
import 'package:kinesa/features/ai/presentation/widgets/ai_message_bubble.dart';
import 'package:kinesa/features/ai/presentation/widgets/quick_action_chips.dart';
import 'package:kinesa/features/ai/data/models/ai_conversation_model.dart';
import 'package:kinesa/features/ai/data/models/user_context.dart';
import 'package:kinesa/features/home/presentation/providers/dashboard_provider.dart';
import 'package:kinesa/features/user/data/models/user_model.dart';

/// AI Fitness Coach chat screen
class AICoachScreen extends ConsumerStatefulWidget {
  const AICoachScreen({super.key});

  @override
  ConsumerState<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends ConsumerState<AICoachScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showQuickActions = true;
  bool _hasLoadedConversation = false;

  @override
  void initState() {
    super.initState();
    // Load latest conversation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLatestConversation();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLatestConversation() async {
    if (_hasLoadedConversation) return;
    _hasLoadedConversation = true;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final state = ref.read(aiCoachProviderOverride);
    // Only load if no conversation is currently active
    if (!state.hasConversation) {
      await ref.read(aiCoachProviderOverride.notifier).loadLatestConversation(userId);
      // If conversation was loaded, hide quick actions
      final newState = ref.read(aiCoachProviderOverride);
      if (newState.messages.isNotEmpty) {
        setState(() {
          _showQuickActions = false;
        });
        _scrollToBottom();
      }
    }
  }

  /// Scroll to the bottom of the message list
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  /// Send a message to the AI coach
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Clear the input field
    _messageController.clear();

    // Hide quick actions after first message
    setState(() {
      _showQuickActions = false;
    });

    final user = ref.read(currentUserProvider).asData?.value;
    final userContext = _buildUserContext(user);

    // Send message
    await ref.read(aiCoachProviderOverride.notifier).sendMessage(
          message: message,
          userContext: userContext,
        );

    // Scroll to bottom to show new messages
    _scrollToBottom();
  }

  /// Handle quick action tap
  Future<void> _handleQuickAction(QuickAction action) async {
    setState(() {
      _showQuickActions = false;
    });

    final user = ref.read(currentUserProvider).asData?.value;
    final userContext = _buildUserContext(user);

    if (action.id == 'recommend_workout') {
      await ref.read(aiCoachProviderOverride.notifier).getWorkoutRecommendation(
            userContext: userContext,
            availableMinutes: 45,
          );
    } else if (action.id == 'form_check') {
      await ref.read(aiCoachProviderOverride.notifier).getFormCheck(
            userContext: userContext,
            exercise: 'Squat',
          );
    } else {
      // For other actions, send as regular message
      await ref.read(aiCoachProviderOverride.notifier).sendMessage(
            message: action.prompt,
            userContext: userContext,
          );
    }

    _scrollToBottom();
  }

  UserContext _buildUserContext(UserModel? user) {
    final authUser = FirebaseAuth.instance.currentUser;
    final resolvedId = user?.id ?? authUser?.uid ?? 'demo_user';
    final resolvedName = _resolveDisplayName(user);
    final coachTone = user?.onboarding?['coachTone'] as String? ??
        user?.preferences?['coachTone'] as String?;
    final age = user?.dateOfBirth != null
        ? _calculateAge(user!.dateOfBirth!)
        : null;
    final builder = UserContextBuilder()
      ..userId = resolvedId
      ..displayName = resolvedName
      ..age = age
      ..gender = user?.gender
      ..height = user?.height
      ..weight = user?.weight
      ..fitnessGoal = user?.goal
      ..fitnessLevel = user?.fitnessLevel
      ..coachTone = coachTone ?? 'friendly'
      ..physicalLimitations = []
      ..preferredWorkoutTypes = ['Strength Training', 'Cardio']
      ..preferredWorkoutDuration = user?.onboarding?['preferredDuration'] as int?
      ..weeklyWorkoutFrequency = user?.onboarding?['workoutsPerWeek'] as int?
      ..daysSinceLastWorkout = 1
      ..lastNightSleepHours = user?.preferences?['sleepHours'] as double?
      ..currentEnergyLevel = user?.preferences?['energyLevel'] as int?
      ..currentMood = user?.preferences?['moodLevel'] as int?
      ..timestamp = DateTime.now();

    return builder.build();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiCoachProviderOverride);
    final user = ref.watch(currentUserProvider).asData?.value;
    final displayName = _resolveDisplayName(user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Fitness Coach'),
        actions: [
          // History button
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Chat History',
            onPressed: () {
              context.push(RouteConstants.aiCoachHistory);
            },
          ),
          // New conversation button
          if (state.hasConversation)
            IconButton(
              icon: const Icon(Icons.add_comment_outlined),
              tooltip: 'New Conversation',
              onPressed: () {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId != null) {
                  ref.read(aiCoachProviderOverride.notifier).startNewConversation(userId);
                } else {
                  ref.read(aiCoachProviderOverride.notifier).clearConversation();
                }
                setState(() {
                  _showQuickActions = true;
                });
              },
            ),
          // Info button
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () {
              _showAboutDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: state.messages.isEmpty
                ? _buildEmptyState(displayName)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return AIMessageBubble(
                        message: message,
                        // Cost info hidden from users - only visible in debug builds if needed
                        showCostInfo: false,
                      );
                    },
                  ),
          ),

          // Loading indicator
          if (state.isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Coach is typing...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),

          // Error message
          if (state.error != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      ref.read(aiCoachProviderOverride.notifier).clearError();
                    },
                  ),
                ],
              ),
            ),

          // Quick actions (shown when conversation is empty)
          if (_showQuickActions && state.messages.isEmpty)
            QuickActionChips(
              onActionTap: _handleQuickAction,
            ),

          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String displayName) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            displayName.isEmpty
                ? 'Your AI Fitness Coach'
                : 'Hi $displayName, I’m your AI Coach',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Get personalized workout recommendations, form guidance, and fitness advice',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Choose a quick action or ask a question',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: colorScheme.shadow.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask your fitness coach...',
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send),
            color: colorScheme.primary,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Fitness Coach'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your personal AI-powered fitness coach, ready to help you with:',
            ),
            const SizedBox(height: 16),
            _buildFeatureItem('💪', 'Personalized workout recommendations'),
            _buildFeatureItem('✓', 'Exercise form guidance'),
            _buildFeatureItem('📈', 'Progress tracking and advice'),
            _buildFeatureItem('😴', 'Recovery and rest day suggestions'),
            const SizedBox(height: 16),
            Text(
              'Powered by Claude AI',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  String _resolveDisplayName(UserModel? user) {
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    final email = user?.email;
    if (email != null && email.trim().isNotEmpty) {
      return email.split('@').first;
    }
    final authName = FirebaseAuth.instance.currentUser?.displayName?.trim();
    if (authName != null && authName.isNotEmpty) {
      return authName;
    }
    return '';
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    final hasHadBirthdayThisYear =
        (now.month > birthDate.month) ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hasHadBirthdayThisYear) {
      age -= 1;
    }
    return age;
  }
}
