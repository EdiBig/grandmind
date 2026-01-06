import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:kinesa/core/config/ai_config.dart';
import 'package:kinesa/features/ai/data/repositories/ai_cache_repository.dart';
import 'package:kinesa/features/ai/data/models/cache_entry.dart';

/// Response from Claude API
class ClaudeResponse {
  final String id;
  final String content;
  final String model;
  final String stopReason;
  final int inputTokens;
  final int outputTokens;
  final bool fromCache;
  final DateTime timestamp;

  ClaudeResponse({
    required this.id,
    required this.content,
    required this.model,
    required this.stopReason,
    required this.inputTokens,
    required this.outputTokens,
    this.fromCache = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Calculate cost of this response
  double get cost => AICostConfig.calculateCost(
        inputTokens: inputTokens,
        outputTokens: outputTokens,
        useHaiku: model.contains('haiku'),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'model': model,
        'stopReason': stopReason,
        'inputTokens': inputTokens,
        'outputTokens': outputTokens,
        'fromCache': fromCache,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ClaudeResponse.fromJson(Map<String, dynamic> json) {
    return ClaudeResponse(
      id: json['id'] as String,
      content: json['content'] as String,
      model: json['model'] as String,
      stopReason: json['stopReason'] as String,
      inputTokens: json['inputTokens'] as int,
      outputTokens: json['outputTokens'] as int,
      fromCache: json['fromCache'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Message in a conversation
class ClaudeMessage {
  final String role;  // 'user' or 'assistant'
  final String content;

  const ClaudeMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ClaudeMessage.fromJson(Map<String, dynamic> json) {
    return ClaudeMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }

  factory ClaudeMessage.user(String content) {
    return ClaudeMessage(role: 'user', content: content);
  }

  factory ClaudeMessage.assistant(String content) {
    return ClaudeMessage(role: 'assistant', content: content);
  }
}

/// Exception thrown when Claude API returns an error
class ClaudeAPIException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorType;

  ClaudeAPIException(this.message, {this.statusCode, this.errorType});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ClaudeAPIException ($statusCode): $message';
    }
    return 'ClaudeAPIException: $message';
  }
}

/// Service for interacting with Claude API
class ClaudeAPIService {
  final Dio _dio;
  final AICacheRepository? _cacheRepository;
  final Logger _logger = Logger();
  String? _apiKey;

  ClaudeAPIService({
    Dio? dio,
    AICacheRepository? cacheRepository,
  })  : _dio = dio ?? Dio(),
        _cacheRepository = cacheRepository {
    _configureDio();
  }

  void _configureDio() {
    _dio.options.baseUrl = AIConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };

    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => _logger.d(obj),
    ));

    // Add retry interceptor for network failures
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            // Retry once on timeout
            _logger.w('Request timeout, retrying...');
            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Initialize the service with API key
  Future<void> initialize() async {
    _apiKey = await AIConfig.getApiKey();

    if (_apiKey == null) {
      _logger.w('Claude API key not configured');
      throw ClaudeAPIException('API key not configured');
    }

    _dio.options.headers['x-api-key'] = _apiKey;
    _dio.options.headers['anthropic-version'] = AIConfig.apiVersion;

    _logger.i('ClaudeAPIService initialized');
  }

  /// Send a message to Claude and get a response
  Future<ClaudeResponse> sendMessage({
    required String prompt,
    List<ClaudeMessage>? conversationHistory,
    String? systemPrompt,
    String? model,
    double? temperature,
    int? maxTokens,
    String? userId,
    String? promptType,
    bool bypassCache = false,
  }) async {
    try {
      // Ensure initialized
      if (_apiKey == null) {
        await initialize();
      }

      // Check cache first (if available and not bypassed)
      if (_cacheRepository != null && !bypassCache) {
        final cachedEntry = await _cacheRepository!.getCachedResponse(
          systemPrompt: systemPrompt ?? '',
          userPrompt: prompt,
          userId: userId,
          promptType: promptType,
        );

        if (cachedEntry != null) {
          _logger.i('✓ Cache HIT - Returning cached response');
          return ClaudeResponse(
            id: cachedEntry.id,
            content: cachedEntry.response,
            model: model ?? AIConfig.defaultModel,
            stopReason: 'end_turn',
            inputTokens: cachedEntry.inputTokens,
            outputTokens: cachedEntry.outputTokens,
            fromCache: true,
            timestamp: cachedEntry.createdAt,
          );
        } else {
          _logger.d('✗ Cache MISS - Making API call');
        }
      }

      // Build messages array
      final messages = <Map<String, dynamic>>[];

      // Add conversation history
      if (conversationHistory != null) {
        messages.addAll(conversationHistory.map((m) => m.toJson()));
      }

      // Add current user message
      messages.add(ClaudeMessage.user(prompt).toJson());

      // Build request body
      final requestBody = {
        'model': model ?? AIConfig.defaultModel,
        'messages': messages,
        'max_tokens': maxTokens ?? AIConfig.defaultMaxTokens,
        'temperature': temperature ?? AIConfig.defaultTemperature,
      };

      // Add system prompt if provided
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        requestBody['system'] = systemPrompt;
      }

      _logger.i('Sending message to Claude API');
      _logger.d('Model: ${requestBody['model']}');
      _logger.d('Max tokens: ${requestBody['max_tokens']}');

      // Make API request
      final response = await _dio.post(
        '/messages',
        data: requestBody,
      );

      // Parse response
      final responseData = response.data as Map<String, dynamic>;

      // Extract content from response
      final contentList = responseData['content'] as List;
      final content = contentList.isNotEmpty
          ? (contentList.first as Map<String, dynamic>)['text'] as String
          : '';

      // Extract usage information
      final usage = responseData['usage'] as Map<String, dynamic>;
      final inputTokens = usage['input_tokens'] as int;
      final outputTokens = usage['output_tokens'] as int;

      final claudeResponse = ClaudeResponse(
        id: responseData['id'] as String,
        content: content,
        model: responseData['model'] as String,
        stopReason: responseData['stop_reason'] as String,
        inputTokens: inputTokens,
        outputTokens: outputTokens,
      );

      _logger.i('Received response from Claude');
      _logger.d('Input tokens: $inputTokens');
      _logger.d('Output tokens: $outputTokens');
      _logger.d('Cost: \$${claudeResponse.cost.toStringAsFixed(4)}');

      // Save response to cache (if cache is available)
      if (_cacheRepository != null) {
        await _cacheRepository!.cacheResponse(
          systemPrompt: systemPrompt ?? '',
          userPrompt: prompt,
          response: content,
          inputTokens: inputTokens,
          outputTokens: outputTokens,
          cost: claudeResponse.cost,
          userId: userId,
          promptType: promptType,
          metadata: {
            'model': claudeResponse.model,
            'stopReason': claudeResponse.stopReason,
          },
        );
        _logger.d('Response saved to cache');
      }

      return claudeResponse;
    } on DioException catch (e) {
      _logger.e('Dio error: ${e.message}', error: e);
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      _logger.e('Unexpected error', error: e, stackTrace: stackTrace);
      throw ClaudeAPIException('Unexpected error: $e');
    }
  }

  /// Send a message with streaming response
  Stream<String> sendMessageStream({
    required String prompt,
    List<ClaudeMessage>? conversationHistory,
    String? systemPrompt,
    String? model,
    double? temperature,
    int? maxTokens,
  }) async* {
    try {
      // Ensure initialized
      if (_apiKey == null) {
        await initialize();
      }

      // Build messages array
      final messages = <Map<String, dynamic>>[];

      // Add conversation history
      if (conversationHistory != null) {
        messages.addAll(conversationHistory.map((m) => m.toJson()));
      }

      // Add current user message
      messages.add(ClaudeMessage.user(prompt).toJson());

      // Build request body
      final requestBody = {
        'model': model ?? AIConfig.defaultModel,
        'messages': messages,
        'max_tokens': maxTokens ?? AIConfig.streamingMaxTokens,
        'temperature': temperature ?? AIConfig.defaultTemperature,
        'stream': true,  // Enable streaming
      };

      // Add system prompt if provided
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        requestBody['system'] = systemPrompt;
      }

      _logger.i('Starting streaming request to Claude API');

      // Make streaming request
      final response = await _dio.post(
        '/messages',
        data: requestBody,
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      // Process streaming response
      final stream = response.data.stream;

      await for (final chunk in stream) {
        final lines = utf8.decode(chunk).split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);

            if (data == '[DONE]') {
              _logger.i('Streaming completed');
              break;
            }

            try {
              final json = jsonDecode(data) as Map<String, dynamic>;

              // Check for content delta
              if (json['type'] == 'content_block_delta') {
                final delta = json['delta'] as Map<String, dynamic>;
                if (delta['type'] == 'text_delta') {
                  yield delta['text'] as String;
                }
              }
            } catch (e) {
              _logger.w('Error parsing streaming chunk: $e');
            }
          }
        }
      }
    } on DioException catch (e) {
      _logger.e('Dio error in streaming: ${e.message}', error: e);
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      _logger.e('Unexpected error in streaming', error: e, stackTrace: stackTrace);
      throw ClaudeAPIException('Unexpected streaming error: $e');
    }
  }

  /// Handle Dio errors and convert to ClaudeAPIException
  ClaudeAPIException _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    if (statusCode == 401) {
      return ClaudeAPIException(
        'Invalid API key or authentication failed',
        statusCode: 401,
        errorType: 'authentication_error',
      );
    }

    if (statusCode == 429) {
      return ClaudeAPIException(
        'Rate limit exceeded. Please try again later.',
        statusCode: 429,
        errorType: 'rate_limit_error',
      );
    }

    if (statusCode == 500 || statusCode == 502 || statusCode == 503) {
      return ClaudeAPIException(
        'Claude API is temporarily unavailable. Please try again later.',
        statusCode: statusCode,
        errorType: 'server_error',
      );
    }

    if (responseData is Map<String, dynamic>) {
      final errorObj = responseData['error'] as Map<String, dynamic>?;
      if (errorObj != null) {
        return ClaudeAPIException(
          errorObj['message'] as String? ?? 'Unknown API error',
          statusCode: statusCode,
          errorType: errorObj['type'] as String?,
        );
      }
    }

    return ClaudeAPIException(
      error.message ?? 'Network error occurred',
      statusCode: statusCode,
    );
  }

  /// Check if the service is properly configured
  Future<bool> isConfigured() async {
    return await AIConfig.isConfigured();
  }
}
