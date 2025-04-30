import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({Key? key}) : super(key: key);

  // Mock data structure for chat history entries
  final List<HistoryEntry> chatHistory = [
    HistoryEntry(
      icon: Icons.smart_toy_outlined,
      modelName: 'GPT-4',
      lastMessagePreview: 'Here\'s the analysis of the market trends you requested, focusing on ke...',
      timestamp: '2 min ago',
      iconBackgroundColor: const Color(0xFF3A6EA5),
    ),
    HistoryEntry(
      icon: Icons.image_outlined,
      modelName: 'DALL-E 3',
      lastMessagePreview: 'Generated 4 variations of the sunset landscape as requested...',
      timestamp: '1h ago',
      iconBackgroundColor: const Color(0xFF9C27B0),
    ),
    HistoryEntry(
      icon: Icons.code,
      modelName: 'Code Assistant',
      lastMessagePreview: 'Here\'s the React component implementation with TypeScript...',
      timestamp: 'Yesterday',
      iconBackgroundColor: const Color(0xFF26A69A),
    ),
    HistoryEntry(
      icon: Icons.smart_toy_outlined,
      modelName: 'GPT-4',
      lastMessagePreview: 'Let me help you brainstorm some creative ideas for your project...',
      timestamp: '2 days ago',
      iconBackgroundColor: const Color(0xFF3A6EA5),
    ),
    HistoryEntry(
      icon: Icons.lightbulb_outline,
      modelName: 'Model Y',
      lastMessagePreview: 'Sure, let\'s continue our story about the brave knight...',
      timestamp: '3 days ago',
      iconBackgroundColor: const Color(0xFFFF9800),
    ),
    HistoryEntry(
      icon: Icons.bar_chart,
      modelName: 'Analytics AI',
      lastMessagePreview: 'Based on your data, I can see three main trends emerging...',
      timestamp: '5 days ago',
      iconBackgroundColor: const Color(0xFF7E57C2),
    ),
    HistoryEntry(
      icon: Icons.description_outlined,
      modelName: 'Document AI',
      lastMessagePreview: 'I\'ve analyzed your PDF and extracted the key information...',
      timestamp: '1 week ago',
      iconBackgroundColor: const Color(0xFF42A5F5),
    ),
    HistoryEntry(
      icon: Icons.translate,
      modelName: 'Translator',
      lastMessagePreview: 'Here\'s the translation of the document from English to French...',
      timestamp: '1 week ago',
      iconBackgroundColor: const Color(0xFF66BB6A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Chat History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search feature coming soon'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: chatHistory.isEmpty 
          ? _buildEmptyState() 
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final entry = chatHistory[index];
                return HistoryListItem(entry: entry);
              },
            ),
    );
  }

  // Empty state when no history is available
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No chat history yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Your conversation history will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Options menu for the history screen
  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2F37),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.grey),
              title: const Text('Clear All History', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showClearHistoryConfirmation(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined, color: Colors.grey),
              title: const Text('Archive Selected', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Archive functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort, color: Colors.grey),
              title: const Text('Sort By', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showSortOptions(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Confirmation dialog for clearing history
  void _showClearHistoryConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2F37),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Clear History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to clear all chat history? This action cannot be undone.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Clear history logic would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('History cleared'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  // Sort options for history items
  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2F37),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption(context, 'Newest First', true),
            _buildSortOption(context, 'Oldest First', false),
            _buildSortOption(context, 'Model Name', false),
          ],
        ),
      ),
    );
  }

  // Individual sort option item
  Widget _buildSortOption(BuildContext context, String title, bool isSelected) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Apply sorting
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.white : Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget for history list items
class HistoryListItem extends StatelessWidget {
  final HistoryEntry entry;

  const HistoryListItem({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          // Navigate to the specific chat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening chat with ${entry.modelName}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Model icon with background color
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: entry.iconBackgroundColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: entry.iconBackgroundColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  entry.icon, 
                  size: 22.0, 
                  color: entry.iconBackgroundColor,
                ),
              ),
              const SizedBox(width: 14.0),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Model name and timestamp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            entry.modelName,
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.timestamp,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),

                    // Message preview
                    Text(
                      entry.lastMessagePreview,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey[400],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data model for history entries
class HistoryEntry {
  final IconData icon;
  final String modelName;
  final String lastMessagePreview;
  final String timestamp;
  final Color iconBackgroundColor;

  const HistoryEntry({
    required this.icon,
    required this.modelName,
    required this.lastMessagePreview,
    required this.timestamp,
    required this.iconBackgroundColor,
  });
} 