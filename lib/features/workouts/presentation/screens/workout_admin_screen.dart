import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../firebase_options.dart';
import '../providers/wger_workouts_provider.dart';

class WorkoutAdminScreen extends ConsumerStatefulWidget {
  const WorkoutAdminScreen({super.key});

  @override
  ConsumerState<WorkoutAdminScreen> createState() => _WorkoutAdminScreenState();
}

class _WorkoutAdminScreenState extends ConsumerState<WorkoutAdminScreen> {
  static const String _tokenKey = 'wger_sync_token';
  static const String _region = 'us-central1';

  // Use secure storage for sensitive tokens
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  final _tokenController = TextEditingController();
  bool _isWorking = false;
  String? _statusMessage;
  String? _debugDetails;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final token = await _secureStorage.read(key: _tokenKey) ?? '';
    if (!mounted) return;
    setState(() => _tokenController.text = token);
  }

  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token.trim());
  }

  Future<void> _runSync(String path) async {
    if (_isWorking) return;
    if (kIsWeb) {
      setState(() => _statusMessage = 'Sync is not supported on web.');
      return;
    }
    setState(() {
      _isWorking = true;
      _statusMessage = null;
      _debugDetails = null;
    });
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Sync token is required.';
        _isWorking = false;
      });
      return;
    }
    await _saveToken(token);
    try {
      final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
      final uri = Uri.https(
        '$_region-$projectId.cloudfunctions.net',
        '/$path',
        {'token': token},
      );
      final response = await _postWithToken(uri, token);
      if (!mounted) return;
      setState(() {
        _statusMessage = response;
        _debugDetails = _buildDebugDetails(uri, token, response);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Error: $e';
        _debugDetails = _buildDebugDetails(null, token, 'Error: $e');
      });
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  Future<String> _postWithToken(Uri uri, String token) async {
    final client = HttpClient();
    final request = await client.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    if (token.isNotEmpty) {
      request.headers.set('x-sync-token', token);
    }
    request.write(jsonEncode({'token': token}));
    final response = await request.close();
    final body = await response.transform(const Utf8Decoder()).join();
    client.close();
    return 'Status ${response.statusCode}: ${body.isEmpty ? 'ok' : body}';
  }

  String _buildDebugDetails(Uri? uri, String token, String response) {
    final maskedToken = token.isEmpty
        ? '(empty)'
        : '${token.substring(0, 4)}…${token.substring(token.length - 4)}';
    final tokenLength = token.length;
    final uriText = uri?.toString() ?? '(none)';
    return 'Request URL: $uriText\nToken: $maskedToken (len $tokenLength)\n$response';
  }

  @override
  Widget build(BuildContext context) {
    final syncStatusAsync = ref.watch(wgerSyncStatusProvider);
    final workoutsCountAsync = ref.watch(wgerWorkoutsCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Library Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sync Status Card
          _buildSyncStatusCard(context, syncStatusAsync, workoutsCountAsync),
          const SizedBox(height: 24),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Setup Instructions',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '1. Get a wger API key from wger.de\n'
                  '2. Set Firebase secrets:\n'
                  '   firebase functions:secrets:set WGER_API_KEY\n'
                  '   firebase functions:secrets:set WGER_SYNC_TOKEN\n'
                  '3. Deploy functions: firebase deploy --only functions\n'
                  '4. Enter your sync token below and click Sync',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Token Input
          Text(
            'Sync Configuration',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tokenController,
            decoration: InputDecoration(
              labelText: 'Sync Token',
              hintText: 'Enter your WGER_SYNC_TOKEN value',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.key),
            ),
            obscureText: true,
            onSubmitted: _saveToken,
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isWorking ? null : () => _runSync('syncWgerWorkoutsNow'),
                  icon: _isWorking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                  label: Text(_isWorking ? 'Syncing...' : 'Sync wger Exercises'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isWorking
                ? null
                : () => _runSync('configureAlgoliaIndex'),
            icon: const Icon(Icons.search),
            label: const Text('Configure Algolia Search Index'),
          ),

          // Response Status
          if (_statusMessage != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _statusMessage!.contains('200')
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _statusMessage!.contains('200')
                      ? AppColors.success.withValues(alpha: 0.3)
                      : AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _statusMessage!.contains('200')
                            ? Icons.check_circle
                            : Icons.error,
                        color: _statusMessage!.contains('200')
                            ? AppColors.success
                            : AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Response',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusMessage!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],

          // Debug Details
          if (_debugDetails != null) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              title: const Text('Debug Details'),
              tilePadding: EdgeInsets.zero,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _debugDetails!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncStatusCard(
    BuildContext context,
    AsyncValue<WgerSyncStatus> syncStatusAsync,
    AsyncValue<int> workoutsCountAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, color: AppColors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'wger Exercise Library',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Exercises',
                  workoutsCountAsync.when(
                    data: (count) => count.toString(),
                    loading: () => '...',
                    error: (_, __) => '0',
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: syncStatusAsync.when(
                  data: (status) => _buildStatItem(
                    context,
                    'Last Sync',
                    status.hasNeverSynced
                        ? 'Never'
                        : _formatTimeAgo(status.lastSyncAt!),
                  ),
                  loading: () => _buildStatItem(context, 'Last Sync', '...'),
                  error: (_, __) => _buildStatItem(context, 'Last Sync', 'Unknown'),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: syncStatusAsync.when(
                  data: (status) => _buildStatItem(
                    context,
                    'Status',
                    status.isSyncing
                        ? 'Syncing...'
                        : status.isSuccessful
                            ? 'OK'
                            : status.hasFailed
                                ? 'Failed'
                                : 'Unknown',
                  ),
                  loading: () => _buildStatItem(context, 'Status', '...'),
                  error: (_, __) => _buildStatItem(context, 'Status', 'Unknown'),
                ),
              ),
            ],
          ),
          syncStatusAsync.when(
            data: (status) {
              if (status.hasFailed && status.errorMessage != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Error: ${status.errorMessage}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
