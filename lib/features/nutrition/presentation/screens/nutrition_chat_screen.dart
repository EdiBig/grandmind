import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kinesa/core/theme/theme_extensions.dart';
import 'package:kinesa/core/theme/app_colors.dart';
import 'package:kinesa/features/ai/presentation/providers/ai_providers.dart';
import 'package:kinesa/features/ai/presentation/widgets/ai_message_bubble.dart';
import 'package:kinesa/features/ai/data/models/user_context.dart';
import 'package:kinesa/features/nutrition/presentation/providers/nutrition_ai_provider.dart';
import 'package:kinesa/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:kinesa/features/home/presentation/providers/dashboard_provider.dart';
import 'package:kinesa/features/user/data/models/user_model.dart';

/// AI Nutritionist chat screen
class NutritionChatScreen extends ConsumerStatefulWidget {
  final String userId;

  const NutritionChatScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<NutritionChatScreen> createState() => _NutritionChatScreenState();
}

class _NutritionChatScreenState extends ConsumerState<NutritionChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showQuickActions = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load existing conversation or start new one after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true;
        _loadConversation();
      }
    });
  }

  Future<void> _loadConversation() async {
    await ref.read(nutritionistChatProviderOverride.notifier)
        .loadOrStartConversation(widget.userId);

    // If conversation has messages, hide quick actions
    final state = ref.read(nutritionistChatProviderOverride);
    if (state.messages.isNotEmpty) {
      setState(() {
        _showQuickActions = false;
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    setState(() {
      _showQuickActions = false;
    });

    final user = ref.read(currentUserProvider).asData?.value;
    final userContext = _buildUserContext(user);
    final goal = ref.read(userNutritionGoalProvider).asData?.value;
    final summary = ref.read(todayNutritionSummaryProvider).asData?.value;

    await ref.read(nutritionistChatProviderOverride.notifier).sendMessage(
          message: message,
          userContext: userContext,
          goal: goal,
          todaySummary: summary,
        );

    _scrollToBottom();
  }

  Future<void> _handleQuickAction(String actionId, String prompt) async {
    setState(() {
      _showQuickActions = false;
    });

    final user = ref.read(currentUserProvider).asData?.value;
    final userContext = _buildUserContext(user);
    final goal = ref.read(userNutritionGoalProvider).asData?.value;
    final summary = ref.read(todayNutritionSummaryProvider).asData?.value;

    if (actionId == 'meal_recommendations' && goal != null && summary != null) {
      await ref.read(nutritionistChatProviderOverride.notifier).getMealRecommendations(
            userId: widget.userId,
            userContext: userContext,
            goal: goal,
            todaySummary: summary,
          );
    } else {
      await ref.read(nutritionistChatProviderOverride.notifier).sendMessage(
            message: prompt,
            userContext: userContext,
            goal: goal,
            todaySummary: summary,
          );
    }

    _scrollToBottom();
  }

  UserContext _buildUserContext(UserModel? user) {
    final authUser = FirebaseAuth.instance.currentUser;
    final resolvedId = user?.id ?? authUser?.uid ?? widget.userId;
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
      ..timestamp = DateTime.now();

    return builder.build();
  }

  String _resolveDisplayName(UserModel? user) {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser?.displayName != null && authUser!.displayName!.isNotEmpty) {
      return authUser.displayName!;
    }
    if (authUser?.email != null) {
      return authUser!.email!.split('@').first;
    }
    return 'there';
  }

  int _calculateAge(DateTime dateOfBirth) {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionistChatProviderOverride);
    final user = ref.watch(currentUserProvider).asData?.value;
    final displayName = _resolveDisplayName(user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Nutritionist'),
        actions: [
          if (state.hasConversation)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'New Conversation',
              onPressed: () async {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Start New Conversation?'),
                    content: const Text(
                      'This will clear the current conversation and start fresh.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Start New'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  ref.read(nutritionistChatProviderOverride.notifier)
                      .startNewConversation(widget.userId);
                  setState(() {
                    _showQuickActions = true;
                  });
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty
                ? _buildWelcomeView(displayName)
                : _buildMessageList(state),
          ),
          if (state.error != null) _buildErrorBanner(state.error!),
          _buildInputArea(state.isLoading),
        ],
      ),
    );
  }

  Widget _buildWelcomeView(String displayName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.colors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: context.colors.success,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hi $displayName!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'I\'m your AI Nutritionist. Ask me anything about nutrition, meal planning, or dietary advice.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (_showQuickActions) ...[
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              icon: Icons.restaurant,
              title: 'Meal Recommendations',
              description: 'Get meal suggestions based on your remaining macros',
              onTap: () => _handleQuickAction(
                'meal_recommendations',
                'What should I eat to meet my macro goals today?',
              ),
            ),
            _buildQuickActionCard(
              icon: Icons.egg,
              title: 'Protein Sources',
              description: 'Learn about good protein sources for your goals',
              onTap: () => _handleQuickAction(
                'protein_sources',
                'What are some good protein sources I can add to my diet?',
              ),
            ),
            _buildQuickActionCard(
              icon: Icons.calendar_today,
              title: 'Meal Prep Tips',
              description: 'Get advice on meal preparation and planning',
              onTap: () => _handleQuickAction(
                'meal_prep',
                'Can you give me some meal prep tips for eating healthy during busy weeks?',
              ),
            ),
            _buildQuickActionCard(
              icon: Icons.local_drink,
              title: 'Hydration Advice',
              description: 'Learn about proper hydration and water intake',
              onTap: () => _handleQuickAction(
                'hydration',
                'How much water should I be drinking daily, and any tips for staying hydrated?',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.colors.success.withValues(alpha: 0.1),
          child: Icon(icon, color: context.colors.success),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMessageList(NutritionistChatState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.messages.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (state.isLoading && index == state.messages.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildLoadingBubble(),
          );
        }

        final message = state.messages[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: AIMessageBubble(message: message),
        );
      },
    );
  }

  Widget _buildLoadingBubble() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.restaurant_menu,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Thinking...',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: context.colors.error.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: context.colors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: context.colors.error, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              ref.read(nutritionistChatProviderOverride.notifier).clearError();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ask about nutrition...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                enabled: !isLoading,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: isLoading ? null : _sendMessage,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
