import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinesa/features/ai/presentation/providers/ai_coach_provider.dart';
import 'package:kinesa/features/ai/presentation/widgets/ai_message_bubble.dart';
import 'package:kinesa/features/ai/presentation/widgets/quick_action_chips.dart';
import 'package:kinesa/features/ai/data/models/ai_conversation_model.dart';
import 'package:kinesa/features/ai/data/models/user_context.dart';

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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

    // Get user context (in production, this would come from user profile)
    final userContext = _buildMockUserContext();

    // Send message
    await ref.read(aiCoachProvider.notifier).sendMessage(
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

    final userContext = _buildMockUserContext();

    if (action.id == 'recommend_workout') {
      await ref.read(aiCoachProvider.notifier).getWorkoutRecommendation(
            userContext: userContext,
            availableMinutes: 45,
          );
    } else if (action.id == 'form_check') {
      await ref.read(aiCoachProvider.notifier).getFormCheck(
            userContext: userContext,
            exercise: 'Squat',
          );
    } else {
      // For other actions, send as regular message
      await ref.read(aiCoachProvider.notifier).sendMessage(
            message: action.prompt,
            userContext: userContext,
          );
    }

    _scrollToBottom();
  }

  /// Build mock user context (temporary - will be replaced with real data)
  UserContext _buildMockUserContext() {
    final builder = UserContextBuilder()
      ..userId = 'demo_user'
      ..displayName = 'Demo User'
      ..age = 30
      ..gender = 'Male'
      ..height = 175
      ..weight = 70
      ..fitnessGoal = 'Build Muscle'
      ..fitnessLevel = 'Intermediate'
      ..coachTone = 'friendly'
      ..physicalLimitations = []
      ..preferredWorkoutTypes = ['Strength Training', 'Cardio']
      ..preferredWorkoutDuration = 45
      ..weeklyWorkoutFrequency = 4
      ..daysSinceLastWorkout = 1
      ..lastNightSleepHours = 7.5
      ..currentEnergyLevel = 4
      ..currentMood = 4
      ..timestamp = DateTime.now();

    return builder.build();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiCoachProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Fitness Coach'),
        actions: [
          if (state.hasConversation)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'New Conversation',
              onPressed: () {
                ref.read(aiCoachProvider.notifier).clearConversation();
                setState(() {
                  _showQuickActions = true;
                });
              },
            ),
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
          // Cost indicator (if there are messages)
          if (state.messages.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.messages.length} messages',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    'Cost: \$${state.totalCost.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: state.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return AIMessageBubble(
                        message: message,
                        showCostInfo: true,
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
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      ref.read(aiCoachProvider.notifier).clearError();
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

  Widget _buildEmptyState() {
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
            'Your AI Fitness Coach',
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
            icon: const Icon(Icons.send),
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
}
