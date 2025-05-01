import 'package:flutter/material.dart';

// Data model for explore items
class ExploreItem {
  final IconData icon;
  final String title;
  final String description;

  ExploreItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Mock data for explore items
  final List<ExploreItem> exploreItems = [
    ExploreItem(
      icon: Icons.visibility_outlined,
      title: 'GPT-4 Vision',
      description: 'Analyze images with AI',
    ),
    ExploreItem(
      icon: Icons.image_outlined,
      title: 'Generate Images',
      description: 'Create stunning art',
    ),
    ExploreItem(
      icon: Icons.edit_outlined,
      title: 'Write Poetry',
      description: 'AI-powered verses',
    ),
    ExploreItem(
      icon: Icons.music_note_outlined,
      title: 'Generate Music',
      description: 'Create melodies',
    ),
    ExploreItem(
      icon: Icons.code,
      title: 'Code Assistant',
      description: 'Debug & write code',
    ),
    ExploreItem(
      icon: Icons.translate,
      title: 'Translate Text',
      description: 'Break language barriers',
    ),
  ];

  // State for selected filter chip
  int _selectedChipIndex = 0; // 0 for 'All' initially
  final List<String> _filterCategories = ['All', 'Image', 'Text', 'Audio', 'Video'];

  @override
  Widget build(BuildContext context) {
    // Currently showing all items, filtering can be implemented later
    final displayedItems = exploreItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 26),
            onPressed: () {
              // TODO: Implement Search functionality
              print('Search icon tapped');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, size: 26),
            onPressed: () {
              // TODO: Navigate to Notifications screen
              print('Notifications icon tapped');
            },
          ),
          const SizedBox(width: 8), // Padding for the last icon
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          _buildFilterChips(),

          // Grid Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 16.0, // Horizontal spacing
                  mainAxisSpacing: 16.0, // Vertical spacing
                  childAspectRatio: 0.75, // Width/height ratio of cards
                ),
                itemCount: displayedItems.length,
                itemBuilder: (context, index) {
                  final item = displayedItems[index];
                  return ExploreCard(item: item);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget: Filter Chips Row
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: List<Widget>.generate(_filterCategories.length, (index) {
          bool isSelected = _selectedChipIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(_filterCategories[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedChipIndex = index;
                  // TODO: Implement filtering based on selection
                  print('Selected category: ${_filterCategories[index]}');
                });
              },
            ),
          );
        }),
      ),
    );
  }
}

// Custom Widget for Explore Card
class ExploreCard extends StatelessWidget {
  final ExploreItem item;

  const ExploreCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Icon(item.icon, size: 36.0, color: Colors.white70),
          const Spacer(flex: 2),

          // Title
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6.0),

          // Description
          Text(
            item.description,
            style: TextStyle(
              fontSize: 13.0,
              color: theme.hintColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(flex: 3),

          // Try Now Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement action for this item
                print('Try Now tapped for ${item.title}');
              },
              child: const Text('Try Now'),
            ),
          ),
        ],
      ),
    );
  }
} 