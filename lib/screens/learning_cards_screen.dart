import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning_card.dart';
import '../providers/learning_cards_provider.dart';

class LearningCardsScreen extends ConsumerStatefulWidget {
  const LearningCardsScreen({super.key});

  @override
  ConsumerState<LearningCardsScreen> createState() => _LearningCardsScreenState();
}

class _LearningCardsScreenState extends ConsumerState<LearningCardsScreen> {
  void _showCreateCardDialog() {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
    int intervalDays = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Learning Card'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g., Daily Python Tips',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'e.g., Programming, Science',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Refresh every:'),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: intervalDays,
                      items: [1, 2, 3, 7, 14, 30].map((days) {
                        return DropdownMenuItem(
                          value: days,
                          child: Text('$days ${days == 1 ? 'day' : 'days'}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => intervalDays = value);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty &&
                    categoryController.text.trim().isNotEmpty) {
                  ref.read(learningCardsProvider.notifier).createCard(
                    titleController.text.trim(),
                    categoryController.text.trim(),
                    refreshIntervalDays: intervalDays,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(learningCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How Learning Cards Work'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Learning Cards are your personalized daily learning companion!\n\n'
                          '• Each card refreshes based on YOUR schedule\n'
                          '• If you skip days, content waits until you open it\n'
                          '• Tap refresh anytime for new content\n'
                          '• Save valuable content to your notes\n'
                          '• Customize topics to match your interests\n\n'
                          'Example: Set a "Tech News" card to refresh every 3 days. '
                          'When you open it on day 4, it auto-generates fresh content!',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it!'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: cards.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No learning cards yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Create cards for daily learning',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return _LearningCardWidget(
            card: card,
            onRefresh: () {
              ref.read(learningCardsProvider.notifier).refreshCard(card.id);
            },
            onDelete: () {
              ref.read(learningCardsProvider.notifier).deleteCard(card.id);
            },
            onSave: (content) {
              ref.read(learningCardsProvider.notifier).saveContentToCard(card.id, content);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to card history!')),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'learn_fab', // Add unique hero tag
        onPressed: _showCreateCardDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Card'),
      ),    );
  }
}

class _LearningCardWidget extends StatefulWidget {
  final LearningCard card;
  final VoidCallback onRefresh;
  final VoidCallback onDelete;
  final Function(String) onSave;

  const _LearningCardWidget({
    required this.card,
    required this.onRefresh,
    required this.onDelete,
    required this.onSave,
  });

  @override
  State<_LearningCardWidget> createState() => _LearningCardWidgetState();
}

class _LearningCardWidgetState extends State<_LearningCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final needsRefresh = widget.card.needsRefresh;
    final daysSinceRefresh = DateTime.now().difference(widget.card.lastRefreshed).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: needsRefresh ? 4 : 2,
      color: needsRefresh
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                widget.card.category[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              widget.card.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  widget.card.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      needsRefresh ? Icons.fiber_new : Icons.check_circle,
                      size: 16,
                      color: needsRefresh ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      needsRefresh
                          ? 'New content available!'
                          : 'Refreshed $daysSinceRefresh ${daysSinceRefresh == 1 ? 'day' : 'days'} ago',
                      style: TextStyle(
                        fontSize: 11,
                        color: needsRefresh ? Colors.orange : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: widget.onRefresh,
                  tooltip: 'Refresh Now',
                ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() => _isExpanded = !_isExpanded);
                    if (_isExpanded && needsRefresh) {
                      widget.onRefresh();
                    }
                  },
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.card.content == 'Loading...') ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ] else ...[
                    SelectableText(
                      widget.card.content,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.card.isCustom)
                          TextButton.icon(
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Delete'),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Card'),
                                  content: const Text('Are you sure?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) widget.onDelete();
                            },
                          ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.bookmark, size: 18),
                          label: const Text('Save to Notes'),
                          onPressed: () {
                            widget.onSave(widget.card.content);
                          },
                        ),
                      ],
                    ),
                  ],
                  if (widget.card.savedContent.isNotEmpty) ...[
                    const Divider(height: 32),
                    Text(
                      'Saved Content (${widget.card.savedContent.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...widget.card.savedContent.take(3).map((content) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• ${content.substring(0, content.length > 100 ? 100 : content.length)}...',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}