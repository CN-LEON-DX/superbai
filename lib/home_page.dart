import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
// Loại bỏ import không cần thiết cho navigation vì giờ đây MainScreen đã xử lý
// import 'profile_page.dart'; 
// import 'widgets/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Maps để theo dõi trạng thái của các card
  final Map<String, bool> _isConversationCardPressed = {};
  final Map<String, bool> _isModelCardPressed = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            const SizedBox(height: 50.0),
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Continue your AI conversation or start a new one',
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 30.0),

            
            
            // Start New Chat Section
            _buildSectionTitle('Accounting & Finance'),
            const SizedBox(height: 16.0),
            
            // AI Model Selection Cards
            _buildModelCard(
              context: context,
              icon: Icons.smart_toy_outlined,
              iconBgColor: Colors.blueGrey.shade700,
              title: 'Model X',
              description: 'Advanced reasoning & analysis',
              tag: 'GPT-4',
              tagColor: Colors.deepPurple.shade300.withOpacity(0.3),
              tagTextColor: Colors.deepPurple.shade100,
              onTap: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      aiModelName: 'Model X',
                      modelType: 'GPT-4',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20.0),
            _buildSectionTitle('Marketing & Sales'),
            const SizedBox(height: 20.0),
            _buildModelCard(
              context: context,
              icon: Icons.psychology_outlined,
              iconBgColor: Colors.teal.shade700,
              title: 'Model Y',
              description: 'Creative & storytelling',
              tag: 'UX Pilot',
              tagColor: Colors.cyan.shade300.withOpacity(0.3),
              tagTextColor: Colors.cyan.shade100,
              onTap: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      aiModelName: 'Model Y',
                      modelType: 'UX Pilot',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12.0),
            _buildModelCard(
              context: context,
              icon: Icons.memory_outlined,
              iconBgColor: Colors.orange.shade800,
              title: 'Model Z',
              description: 'Code & technical tasks',
              tag: 'PaLM',
              tagColor: Colors.amber.shade300.withOpacity(0.3),
              tagTextColor: Colors.amber.shade100,
              onTap: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      aiModelName: 'Model Z',
                      modelType: 'PaLM',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to create section titles
  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
      ],
    );
  }

  // Helper widget to create conversation history cards
  Widget _buildConversationCard({
    required String title,
    required String subtitle,
    required String time,
    required String modelTag,
    required Color tagColor,
    required Color tagTextColor,
    required VoidCallback onTap,
  }) {
    // Initialize press state if not already set
    _isConversationCardPressed[title] ??= false;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isConversationCardPressed[title] = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isConversationCardPressed[title] = false;
        });
        // Navigate to ChatScreen when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              aiModelName: title,
              modelType: modelTag,
            ),
          ),
        );
      },
      onTapCancel: () {
        setState(() {
          _isConversationCardPressed[title] = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: _isConversationCardPressed[title]! 
              ? const Color(0xFF353945) // Slightly lighter when pressed
              : const Color(0xFF2A2D37),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isConversationCardPressed[title]! ? 0.3 : 0.1),
              spreadRadius: _isConversationCardPressed[title]! ? 1 : 0,
              blurRadius: _isConversationCardPressed[title]! ? 4 : 2,
              offset: Offset(0, _isConversationCardPressed[title]! ? 2 : 1),
            ),
          ],
        ),
        transform: _isConversationCardPressed[title]! 
            ? (Matrix4.identity()..scale(0.98))
            : Matrix4.identity(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.grey[400],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                modelTag,
                style: TextStyle(
                  color: tagTextColor,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to create AI model cards
  Widget _buildModelCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String description,
    required String tag,
    required Color tagColor,
    required Color tagTextColor,
    required VoidCallback onTap,
  }) {
    // Initialize press state if not already set
    _isModelCardPressed[title] ??= false;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isModelCardPressed[title] = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isModelCardPressed[title] = false;
        });
        // Navigate to ChatScreen when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              aiModelName: title,
              modelType: tag,
            ),
          ),
        );
      },
      onTapCancel: () {
        setState(() {
          _isModelCardPressed[title] = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: _isModelCardPressed[title]! 
              ? const Color(0xFF353945) // Slightly lighter when pressed
              : const Color(0xFF2A2D37),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isModelCardPressed[title]! ? 0.3 : 0.1),
              spreadRadius: _isModelCardPressed[title]! ? 1 : 0,
              blurRadius: _isModelCardPressed[title]! ? 4 : 2,
              offset: Offset(0, _isModelCardPressed[title]! ? 2 : 1),
            ),
          ],
        ),
        transform: _isModelCardPressed[title]! 
            ? (Matrix4.identity()..scale(0.98))
            : Matrix4.identity(),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: _isModelCardPressed[title]! 
                    ? iconBgColor 
                    : iconBgColor.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                color: _isModelCardPressed[title]!
                    ? Colors.white
                    : Colors.white.withOpacity(0.9), 
                size: 24
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.grey[400],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: _isModelCardPressed[title]! 
                          ? tagColor.withOpacity(0.6) 
                          : tagColor,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: tagTextColor,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                Icons.arrow_forward_ios,
                color: _isModelCardPressed[title]!
                    ? Colors.grey[400]
                    : Colors.grey[600],
                size: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 