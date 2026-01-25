import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use Chatly'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            '🏠 Getting Started',
            'Chatly is your AI-powered learning assistant with 5 main sections accessible from the bottom navigation bar.',
          ),

          _buildFeature(
            '💬 1. Chat Tab',
            [
              '• Type messages to chat with AI (OpenAI or Gemini)',
              '• Tap 🎤 microphone to speak your question',
              '• Tap 🖼️ image icon to upload/take photos for AI analysis',
              '• Long-press any AI response to:',
              '  - 📝 Add to Notes (save in Workspace)',
              '  - 🔖 Save to Snippets (quick save)',
              '  - 🔊 Read aloud',
              '  - 📋 Copy text',
            ],
          ),

          _buildFeature(
            '📚 2. Workspace Tab (Your Study Notebook)',
            [
              '✨ Create Folders:',
              '• Tap ➕ "New Folder" button',
              '• Name it (e.g., "Flutter", "Math", "Python")',
              '• Organize by subjects, chapters, or topics',
              '',
              '📝 Create Notes:',
              '• Open any folder',
              '• Tap ➕ "New Note" button',
              '• Use the rich text editor:',
              '  - Bold, italic, underline',
              '  - Bullet points, numbered lists',
              '  - Color highlights',
              '  - Code blocks',
              '',
              '🤖 Smart Edit Feature:',
              '• Select any text in your note',
              '• Tap ✨ Smart Edit button',
              '• Choose:',
              '  - Fix Grammar',
              '  - Rephrase',
              '  - Simplify',
              '  - Make Professional',
              '  - Expand',
              '  - Shorten',
              '',
              '🔍 Search Notes:',
              '• Tap 🔍 search icon',
              '• Search across all notes',
              '',
              '📌 Pin Important Notes:',
              '• Tap ⋮ menu on any note',
              '• Select "Pin" to keep it at top',
            ],
          ),

          _buildFeature(
            '📌 3. Snippets Tab (Quick Save)',
            [
              'Save quick information without full notes:',
              '',
              '• Links (URLs, websites)',
              '• Phone numbers',
              '• Code snippets',
              '• Short text/quotes',
              '• Audio notes',
              '',
              'How to use:',
              '• Tap ➕ "Add Snippet"',
              '• Choose type (Text, Link, Number, etc.)',
              '• Paste/type content',
              '• Save!',
              '',
              'Tap any snippet to view/copy',
            ],
          ),

          _buildFeature(
            '🎴 4. Learn Tab (Learning Cards)',
            [
              'Daily learning content that refreshes automatically!',
              '',
              '📋 Default Cards:',
              '• Tech News',
              '• Programming Concepts',
              '• Life Tips',
              '• Motivation',
              '• Vocabulary',
              '',
              '🔄 How It Works:',
              '• Each card has a refresh schedule (1, 3, 7 days)',
              '• When you open a card after the time period, AI generates NEW content',
              '• Example: "Tech News" card set to 3 days',
              '  - Day 1: Open card → Shows today\'s content',
              '  - Day 2-3: Same content',
              '  - Day 4: Open card → AUTO-REFRESHES with new content!',
              '',
              '✅ Features:',
              '• Tap 🔄 to manually refresh anytime',
              '• Tap 💾 "Save to Notes" to keep content',
              '• Create custom cards with your own topics',
              '',
              '➕ Create Custom Card:',
              '• Tap ➕ "New Card"',
              '• Enter title (e.g., "Daily Spanish")',
              '• Choose refresh interval',
              '• AI generates content based on your topic!',
            ],
          ),

          _buildFeature(
            '⚙️ 5. Settings Tab',
            [
              '🔑 Setup API Key (Required First Time):',
              '• Choose AI Provider:',
              '  - OpenAI (ChatGPT) - More creative',
              '  - Google Gemini - Faster, free tier',
              '',
              '• Get API Key:',
              '  - OpenAI: platform.openai.com → API Keys',
              '  - Gemini: makersuite.google.com → Get API Key',
              '',
              '• Paste key and tap 💾 Save',
              '',
              '🎛️ Other Settings:',
              '• Text-to-Speech: Auto-read AI responses',
              '• Auto-save Chats: Save conversation history',
            ],
          ),

          const SizedBox(height: 24),

          _buildTipsSection(),

          const SizedBox(height: 24),

          _buildWorkflowExample(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String title, List<String> points) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ...points.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                point,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '💡 Pro Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTip('Organize by Subject', 'Create folders like "Math Chapter 1", "Python Basics"'),
            _buildTip('Save AI Explanations', 'When AI explains something well, tap "Add to Notes"'),
            _buildTip('Use Smart Edit', 'Select messy text and let AI fix grammar/rephrase'),
            _buildTip('Quick Save with Snippets', 'Save important links, numbers, or code without creating full notes'),
            _buildTip('Daily Learning', 'Check Learning Cards daily for fresh content'),
            _buildTip('Voice Input', 'Use mic while cooking/driving to ask questions hands-free'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✅ ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowExample() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '🎯 Example Workflow: Studying for Exam',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStep('1', 'Create folder "Physics Exam"'),
            _buildStep('2', 'Go to Chat, ask: "Explain Newton\'s Laws"'),
            _buildStep('3', 'Tap "Add to Notes" on AI response'),
            _buildStep('4', 'Select "Physics Exam" folder'),
            _buildStep('5', 'Create note "Newton\'s Laws"'),
            _buildStep('6', 'In the note, use Smart Edit to simplify text'),
            _buildStep('7', 'Add your own examples and highlights'),
            _buildStep('8', 'Pin the note for quick access'),
            _buildStep('9', 'Repeat for other topics!'),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}