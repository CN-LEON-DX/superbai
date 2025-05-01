import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
// Loại bỏ import không cần thiết cho navigation vì giờ đây MainScreen đã xử lý
// import 'profile_page.dart'; 
// import 'widgets/bottom_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, bool> _isWorkflowCardPressed = {};
  final _secureStorage = const FlutterSecureStorage();
  final _supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _workflows = [];
  
  Map<String, List<Map<String, dynamic>>> _categorizedWorkflows = {};

  @override
  void initState() {
    super.initState();
    _loadUserWorkflows();
  }

  Future<void> _loadUserWorkflows() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userId = await _secureStorage.read(key: 'user_id');
      
      if (userId == null) {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      // Gọi function trong Supabase
      final response = await _supabase.rpc(
        'get_user_workflows',
        params: {
          'p_user_id': userId,
        },
      );

      if (response != null && response['success'] == true) {
        final workflowList = response['workflows'] as List<dynamic>;
        final workflows = workflowList.map((item) => item as Map<String, dynamic>).toList();
        
        final categorized = <String, List<Map<String, dynamic>>>{};
        
        for (var workflow in workflows) {
          final tags = (workflow['tag'] as List?)?.map((t) => t.toString()).toList() ?? [];
          final category = tags.isNotEmpty ? tags[0] : "Other";
          
          if (!categorized.containsKey(category)) {
            categorized[category] = [];
          }
          
          categorized[category]!.add(workflow);
        }
        
        setState(() {
          _workflows = workflows;
          _categorizedWorkflows = categorized;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load workflows';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _buildContent(),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: Colors.black,
        onPressed: _loadUserWorkflows,
        tooltip: 'Refresh Workflows',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadUserWorkflows,
      child: SingleChildScrollView(
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
            const SizedBox(height: 12.0),
            Text(
              'Continue your AI workflows or start a new one',
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 40.0),
            
            if (_workflows.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.analytics_outlined, size: 60, color: Colors.grey[600]),
                    const SizedBox(height: 16),
                    Text(
                      'No workflows available',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              
            // Hiển thị các workflows theo category
            ..._categorizedWorkflows.entries.map((entry) {
              final category = entry.key;
              final categoryWorkflows = entry.value;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(category),
                  const SizedBox(height: 16.0),
                  ...categoryWorkflows.map((workflow) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildWorkflowCard(
                      context: context,
                      workflow: workflow,
                    ),
                  )).toList(),
                  const SizedBox(height: 16.0),
                ],
              );
            }).toList(),
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

  Widget _buildWorkflowCard({
    required BuildContext context,
    required Map<String, dynamic> workflow,
  }) {
    final String id = workflow['id_workflow'] ?? '';
    final String title = workflow['name'] ?? 'Unnamed Workflow';
    final String description = workflow['description'] ?? 'No description';
    final List<dynamic> tags = workflow['tag'] ?? [];
    final String tag = tags.isNotEmpty ? tags[0].toString() : '';
    final String logoUrl = workflow['logo'] ?? '';
    final Map<String, dynamic> permissions = workflow['permissions'] ?? {};
    
    // Initialize press state if not already set
    _isWorkflowCardPressed[id] ??= false;
    
    // Determine icon and colors based on tag or default
    IconData icon = Icons.smart_toy_outlined;
    Color iconBgColor = Colors.blueGrey.shade700;
    Color tagColor = Colors.deepPurple.shade300.withOpacity(0.3);
    Color tagTextColor = Colors.deepPurple.shade100;
    
    if (tag.contains('GPT-4')) {
      icon = Icons.smart_toy_outlined;
      iconBgColor = Colors.blueGrey.shade700;
      tagColor = Colors.deepPurple.shade300.withOpacity(0.3);
      tagTextColor = Colors.deepPurple.shade100;
    } else if (tag.contains('AI')) {
      icon = Icons.psychology_outlined;
      iconBgColor = Colors.teal.shade700;
      tagColor = Colors.cyan.shade300.withOpacity(0.3);
      tagTextColor = Colors.cyan.shade100;
    } else {
      icon = Icons.memory_outlined;
      iconBgColor = Colors.orange.shade800;
      tagColor = Colors.amber.shade300.withOpacity(0.3);
      tagTextColor = Colors.amber.shade100;
    }
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isWorkflowCardPressed[id] = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isWorkflowCardPressed[id] = false;
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
          _isWorkflowCardPressed[id] = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: _isWorkflowCardPressed[id]! 
              ? const Color(0xFF353945) // Slightly lighter when pressed
              : const Color(0xFF2A2D37),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isWorkflowCardPressed[id]! ? 0.3 : 0.1),
              spreadRadius: _isWorkflowCardPressed[id]! ? 1 : 0,
              blurRadius: _isWorkflowCardPressed[id]! ? 4 : 2,
              offset: Offset(0, _isWorkflowCardPressed[id]! ? 2 : 1),
            ),
          ],
        ),
        transform: _isWorkflowCardPressed[id]! 
            ? (Matrix4.identity()..scale(0.98))
            : Matrix4.identity(),
        child: Row(
          children: [
            // Logo or default icon
            logoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      logoUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: _isWorkflowCardPressed[id]! 
                              ? iconBgColor 
                              : iconBgColor.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: Colors.white, size: 24),
                      ),
                    ),
                  )
                : AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: _isWorkflowCardPressed[id]! 
                          ? iconBgColor 
                          : iconBgColor.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon, 
                      color: _isWorkflowCardPressed[id]!
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
                  Row(
                    children: [
                      // Tag chip
                      if (tag.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: _isWorkflowCardPressed[id]! 
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
                      const SizedBox(width: 8),
                      // Permission indicator
                      if (permissions['can_edit'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              color: Colors.blue[100],
                              fontSize: 11.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                Icons.arrow_forward_ios,
                color: _isWorkflowCardPressed[id]!
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