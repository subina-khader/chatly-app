import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/learning_card.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';

final learningCardsProvider = StateNotifierProvider<LearningCardsNotifier, List<LearningCard>>((ref) {
  return LearningCardsNotifier(
    ref.read(databaseServiceProvider),
    ref.read(aiServiceProvider),
  );
});

class LearningCardsNotifier extends StateNotifier<List<LearningCard>> {
  LearningCardsNotifier(this._db, this._ai) : super([]) {
    loadCards();
    _initializeDefaultCards();
  }

  final DatabaseService _db;
  final AIService _ai;
  final _uuid = const Uuid();

  Future<void> loadCards() async {
    final cards = await _db.getLearningCards();
    state = cards;
  }

  Future<void> _initializeDefaultCards() async {
    if (state.isEmpty) {
      final defaultCategories = [
        'Tech News',
        'Programming Concepts',
        'Life Tips',
        'Motivation',
        'Vocabulary',
      ];

      for (var category in defaultCategories) {
        await createCard(category, category, refreshIntervalDays: 1);
      }
    }
  }

  Future<void> createCard(String title, String category, {int refreshIntervalDays = 1}) async {
    final card = LearningCard(
      id: _uuid.v4(),
      title: title,
      category: category,
      content: 'Loading...',
      lastRefreshed: DateTime.now(),
      nextRefreshDue: DateTime.now().add(Duration(days: refreshIntervalDays)),
      refreshIntervalDays: refreshIntervalDays,
      isCustom: true,
    );
    await _db.insertLearningCard(card);
    await loadCards();
    await refreshCard(card.id);
  }

  Future<void> refreshCard(String cardId) async {
    final card = state.firstWhere((c) => c.id == cardId);

    try {
      final prompt = 'Generate interesting and educational content about ${card.category}. '
          'Keep it concise (3-5 bullet points). Make it engaging and informative.';

      final stream = _ai.sendMessageStream(prompt);
      String content = '';

      await for (var chunk in stream) {
        content += chunk;
      }

      final updatedCard = card.copyWith(
        content: content,
        lastRefreshed: DateTime.now(),
        nextRefreshDue: DateTime.now().add(Duration(days: card.refreshIntervalDays)),
      );

      await _db.updateLearningCard(updatedCard);
      await loadCards();
    } catch (e) {
      // Handle error
      print('Error refreshing card: $e');
    }
  }

  Future<void> deleteCard(String id) async {
    await _db.deleteLearningCard(id);
    await loadCards();
  }

  Future<void> saveContentToCard(String cardId, String content) async {
    final card = state.firstWhere((c) => c.id == cardId);
    final updatedCard = card.copyWith(
      savedContent: [...card.savedContent, content],
    );
    await _db.updateLearningCard(updatedCard);
    await loadCards();
  }
}