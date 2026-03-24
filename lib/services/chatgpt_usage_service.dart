import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chatgpt_models.dart';

class ChatGPTUsageService {
  static const _storage = FlutterSecureStorage();
  static const String _usageKey = 'chatgpt_usage';
  static const String _dailyUsageKey = 'chatgpt_daily_usage';

  // Token limits for different models
  static const Map<String, int> _modelTokenLimits = {
    'gpt-4o-mini': 128000, // Context window
    'gpt-4': 128000,
    'gpt-3.5-turbo': 16385,
  };

  // Pricing per 1M tokens (approximate)
  static const Map<String, double> _pricingPerMillion = {
    'gpt-4o-mini': 0.15, // Input: $0.15, Output: $0.60
    'gpt-4': 30.0, // Input: $30, Output: $60
    'gpt-3.5-turbo': 0.50, // Input: $0.50, Output: $1.50
  };

  static String get currentModel => 'gpt-4o-mini';
  static int get maxTokens => _modelTokenLimits[currentModel] ?? 128000;
  static double get pricePerMillion => _pricingPerMillion[currentModel] ?? 0.15;

  static Future<ChatGPTUsage> getCurrentUsage() async {
    try {
      final usageJson = await _storage.read(key: _usageKey);
      if (usageJson != null) {
        final Map<String, dynamic> json = jsonDecode(usageJson);
        return ChatGPTUsage.fromJson(json);
      }
    } catch (e) {
      // If there's an error, return default usage
    }

    return ChatGPTUsage(
      totalTokensUsed: 0,
      totalRequests: 0,
      currentContextTokens: 0,
      model: currentModel,
      lastReset: DateTime.now(),
      dailyUsage: DailyUsage(
        date: DateTime.now(),
        tokensUsed: 0,
        requests: 0,
        cost: 0.0,
      ),
    );
  }

  static Future<void> updateUsage(ChatGPTUsage usage) async {
    try {
      await _storage.write(key: _usageKey, value: jsonEncode(usage.toJson()));
    } catch (e) {
      print('Failed to update usage: $e');
    }
  }

  static Future<void> trackRequest(ChatGPTResponse response) async {
    try {
      final currentUsage = await getCurrentUsage();

      int inputTokens = response.usage.prompt_tokens;
      int outputTokens = response.usage.completion_tokens;
      int totalTokens = response.usage.total_tokens;

      // Update current usage
      final updatedUsage = currentUsage.copyWith(
        totalTokensUsed: currentUsage.totalTokensUsed + totalTokens,
        totalRequests: currentUsage.totalRequests + 1,
        currentContextTokens: _estimateCurrentContextTokens(
          currentUsage,
          totalTokens,
        ),
        lastReset: currentUsage.lastReset,
      );

      // Update daily usage
      final today = DateTime.now();
      final dailyUsage = _updateDailyUsage(
        currentUsage.dailyUsage,
        inputTokens,
        outputTokens,
        today,
      );

      final finalUsage = updatedUsage.copyWith(dailyUsage: dailyUsage);

      await updateUsage(finalUsage);
    } catch (e) {
      print('Failed to track request: $e');
    }
  }

  static int _estimateCurrentContextTokens(ChatGPTUsage usage, int newTokens) {
    // Simple estimation: assume recent conversations use about 25% of max tokens
    // In a real implementation, you'd track actual conversation context
    final estimatedContext = (maxTokens * 0.25).round();
    return estimatedContext < maxTokens ? estimatedContext : maxTokens - 1000;
  }

  static DailyUsage _updateDailyUsage(
    DailyUsage currentDaily,
    int inputTokens,
    int outputTokens,
    DateTime today,
  ) {
    // Check if it's a new day
    if (!_isSameDay(currentDaily.date, today)) {
      return DailyUsage(
        date: today,
        tokensUsed: inputTokens + outputTokens,
        requests: 1,
        cost: _calculateCost(inputTokens, outputTokens),
      );
    }

    return currentDaily.copyWith(
      tokensUsed: currentDaily.tokensUsed + inputTokens + outputTokens,
      requests: currentDaily.requests + 1,
      cost: currentDaily.cost + _calculateCost(inputTokens, outputTokens),
    );
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static double _calculateCost(int inputTokens, int outputTokens) {
    // Calculate cost based on pricing (simplified)
    final inputCost =
        (inputTokens / 1000000) *
        (pricePerMillion * 0.25); // Input is 25% of total
    final outputCost =
        (outputTokens / 1000000) *
        (pricePerMillion * 0.75); // Output is 75% of total
    return inputCost + outputCost;
  }

  static Future<void> resetUsage() async {
    try {
      final defaultUsage = ChatGPTUsage(
        totalTokensUsed: 0,
        totalRequests: 0,
        currentContextTokens: 0,
        model: currentModel,
        lastReset: DateTime.now(),
        dailyUsage: DailyUsage(
          date: DateTime.now(),
          tokensUsed: 0,
          requests: 0,
          cost: 0.0,
        ),
      );
      await updateUsage(defaultUsage);
    } catch (e) {
      print('Failed to reset usage: $e');
    }
  }

  static Future<TokenUsageInfo> getTokenUsageInfo() async {
    final usage = await getCurrentUsage();
    final remainingTokens = maxTokens - usage.currentContextTokens;
    final usagePercentage = (usage.currentContextTokens / maxTokens) * 100;

    return TokenUsageInfo(
      model: usage.model,
      maxTokens: maxTokens,
      usedTokens: usage.currentContextTokens,
      remainingTokens: remainingTokens,
      usagePercentage: usagePercentage,
      totalTokensUsed: usage.totalTokensUsed,
      totalRequests: usage.totalRequests,
      dailyTokensUsed: usage.dailyUsage.tokensUsed,
      dailyCost: usage.dailyUsage.cost,
    );
  }
}

class ChatGPTUsage {
  final int totalTokensUsed;
  final int totalRequests;
  final int currentContextTokens;
  final String model;
  final DateTime lastReset;
  final DailyUsage dailyUsage;

  ChatGPTUsage({
    required this.totalTokensUsed,
    required this.totalRequests,
    required this.currentContextTokens,
    required this.model,
    required this.lastReset,
    required this.dailyUsage,
  });

  factory ChatGPTUsage.fromJson(Map<String, dynamic> json) {
    return ChatGPTUsage(
      totalTokensUsed: json['totalTokensUsed'] ?? 0,
      totalRequests: json['totalRequests'] ?? 0,
      currentContextTokens: json['currentContextTokens'] ?? 0,
      model: json['model'] ?? 'gpt-4o-mini',
      lastReset: DateTime.parse(
        json['lastReset'] ?? DateTime.now().toIso8601String(),
      ),
      dailyUsage: DailyUsage.fromJson(json['dailyUsage'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTokensUsed': totalTokensUsed,
      'totalRequests': totalRequests,
      'currentContextTokens': currentContextTokens,
      'model': model,
      'lastReset': lastReset.toIso8601String(),
      'dailyUsage': dailyUsage.toJson(),
    };
  }

  ChatGPTUsage copyWith({
    int? totalTokensUsed,
    int? totalRequests,
    int? currentContextTokens,
    String? model,
    DateTime? lastReset,
    DailyUsage? dailyUsage,
  }) {
    return ChatGPTUsage(
      totalTokensUsed: totalTokensUsed ?? this.totalTokensUsed,
      totalRequests: totalRequests ?? this.totalRequests,
      currentContextTokens: currentContextTokens ?? this.currentContextTokens,
      model: model ?? this.model,
      lastReset: lastReset ?? this.lastReset,
      dailyUsage: dailyUsage ?? this.dailyUsage,
    );
  }
}

class DailyUsage {
  final DateTime date;
  final int tokensUsed;
  final int requests;
  final double cost;

  DailyUsage({
    required this.date,
    required this.tokensUsed,
    required this.requests,
    required this.cost,
  });

  factory DailyUsage.fromJson(Map<String, dynamic> json) {
    return DailyUsage(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      tokensUsed: json['tokensUsed'] ?? 0,
      requests: json['requests'] ?? 0,
      cost: (json['cost'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'tokensUsed': tokensUsed,
      'requests': requests,
      'cost': cost,
    };
  }

  DailyUsage copyWith({
    DateTime? date,
    int? tokensUsed,
    int? requests,
    double? cost,
  }) {
    return DailyUsage(
      date: date ?? this.date,
      tokensUsed: tokensUsed ?? this.tokensUsed,
      requests: requests ?? this.requests,
      cost: cost ?? this.cost,
    );
  }
}

class TokenUsageInfo {
  final String model;
  final int maxTokens;
  final int usedTokens;
  final int remainingTokens;
  final double usagePercentage;
  final int totalTokensUsed;
  final int totalRequests;
  final int dailyTokensUsed;
  final double dailyCost;

  TokenUsageInfo({
    required this.model,
    required this.maxTokens,
    required this.usedTokens,
    required this.remainingTokens,
    required this.usagePercentage,
    required this.totalTokensUsed,
    required this.totalRequests,
    required this.dailyTokensUsed,
    required this.dailyCost,
  });

  String get usageLevel {
    if (usagePercentage >= 90) return 'Critical';
    if (usagePercentage >= 75) return 'High';
    if (usagePercentage >= 50) return 'Medium';
    return 'Low';
  }

  Color get usageColor {
    if (usagePercentage >= 90) return const Color(0xFFD32F2F); // Red
    if (usagePercentage >= 75) return const Color(0xFFFF9800); // Orange
    if (usagePercentage >= 50) return const Color(0xFFFFC107); // Yellow
    return const Color(0xFF4CAF50); // Green
  }
}

extension ColorExtension on Color {
  int get value => (alpha << 24) | (red << 16) | (green << 8) | blue;
}
