import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Thêm import cho HapticFeedback
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onLogout;
  
  const ProfilePage({
    Key? key, 
    this.onLogout,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  // Giữ trạng thái cho các hiệu ứng
  final Map<String, bool> _isOptionHovered = {};
  
  // Controller cho animation
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Hiển thị hộp thoại xác nhận đăng xuất
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2F37),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(), // Đóng dialog
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
                Navigator.of(dialogContext).pop(); // Đóng dialog
                _logout(context); // Thực hiện đăng xuất
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Hiển thị popup chỉnh sửa hồ sơ
  void _showEditProfileDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2F37),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.grey),
              title: const Text('Change Display Name', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Hiển thị dialog chỉnh sửa tên
                _showNameEditDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: Colors.grey),
              title: const Text('Update Profile Picture', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Hiển thị dialog chọn ảnh
                _showImageSourceDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text('Update Personal Information', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Hiển thị màn hình chỉnh sửa thông tin
              },
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị dialog chỉnh sửa tên
  void _showNameEditDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: "Alex Mitchell");
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2F37),
        title: const Text('Edit Name', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter your name",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () {
              // Lưu tên mới
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Hiển thị dialog chọn nguồn ảnh
  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2F37),
        title: const Text('Select Image From', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.grey),
              title: const Text('Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Mở thư viện ảnh
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.grey),
              title: const Text('Camera', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Mở máy ảnh
              },
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị popup đổi mật khẩu
  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2F37),
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Current Password",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "New Password",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Confirm New Password",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () {
              // Đổi mật khẩu
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Hiển thị popup cài đặt thông báo
  void _showNotificationsDialog(BuildContext context) {
    bool pushEnabled = true;
    bool emailEnabled = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF2C2F37),
          title: const Text('Notification Settings', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Push Notifications', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Receive notifications on this device', style: TextStyle(color: Colors.grey)),
                value: pushEnabled,
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    pushEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Email Notifications', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Receive notifications via email', style: TextStyle(color: Colors.grey)),
                value: emailEnabled,
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    emailEnabled = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
            ),
            ElevatedButton(
              onPressed: () {
                // Lưu cài đặt
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị popup cài đặt theme
  void _showThemeDialog(BuildContext context) {
    String selectedTheme = 'dark';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2F37),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Theme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              RadioListTile<String>(
                title: const Text('Light', style: TextStyle(color: Colors.white)),
                value: 'light',
                groupValue: selectedTheme,
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    selectedTheme = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Dark', style: TextStyle(color: Colors.white)),
                value: 'dark',
                groupValue: selectedTheme,
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    selectedTheme = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('System Default', style: TextStyle(color: Colors.white)),
                value: 'system',
                groupValue: selectedTheme,
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    selectedTheme = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Áp dụng theme
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Apply', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hiển thị popup trợ giúp và hỗ trợ
  void _showHelpSupportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2C2F37),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Help & Support',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _helpSupportItem(
                    icon: Icons.help_outline,
                    title: 'Frequently Asked Questions',
                    onTap: () {
                      Navigator.pop(context);
                      // Mở màn hình FAQ
                    },
                  ),
                  _helpSupportItem(
                    icon: Icons.contact_support_outlined,
                    title: 'Contact Support',
                    onTap: () {
                      Navigator.pop(context);
                      // Mở màn hình liên hệ
                    },
                  ),
                  _helpSupportItem(
                    icon: Icons.chat_outlined,
                    title: 'Chat with Us',
                    onTap: () {
                      Navigator.pop(context);
                      // Mở chat support
                    },
                  ),
                  _helpSupportItem(
                    icon: Icons.policy_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.pop(context);
                      // Mở trang chính sách
                    },
                  ),
                  _helpSupportItem(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () {
                      Navigator.pop(context);
                      // Mở trang điều khoản
                    },
                  ),
                  _helpSupportItem(
                    icon: Icons.info_outline,
                    title: 'App Information',
                    subtitle: 'Version 1.0.0',
                    onTap: () {
                      Navigator.pop(context);
                      // Hiển thị thông tin ứng dụng
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Item cho phần help & support
  Widget _helpSupportItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: const Color(0xFF34373F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: subtitle != null
            ? Text(subtitle, style: TextStyle(color: Colors.grey[400]))
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // Xử lý đăng xuất
  Future<void> _logout(BuildContext context) async {
    const secureStorage = FlutterSecureStorage();
    
    // Xóa thông tin người dùng khỏi bộ nhớ
    await secureStorage.deleteAll();
    
    // Gọi callback nếu được cung cấp
    widget.onLogout?.call();
    
    // Chuyển đến màn hình đăng nhập và xóa stack điều hướng
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF2C2F37),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.grey),
                      title: const Text('App Information', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        // Hiển thị thông tin ứng dụng
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.security_outlined, color: Colors.grey),
                      title: const Text('Account Security', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        // Hiển thị màn hình bảo mật
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- User Info Section ---
            Center(
              child: Column(
                children: [
                  // Avatar with tap effect
                  GestureDetector(
                    onTap: () => _showImageSourceDialog(context),
                    child: Hero(
                      tag: 'profile-avatar',
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[700],
                            backgroundImage: const NetworkImage('https://img.icons8.com/fluency/96/user-male-circle--v1.png'),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Alex Mitchell',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    'alex.mitchell@email.com',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40.0),

            // --- Account Section ---
            _buildSectionHeader('Account'),
            _buildOptionGroupContainer(
              context,
              children: [
                _buildProfileOptionTile(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  onTap: () => _showEditProfileDialog(context),
                ),
                const Divider(height: 0.5),
                _buildProfileOptionTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () => _showChangePasswordDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // --- Preferences Section ---
            _buildSectionHeader('Preferences'),
            _buildOptionGroupContainer(
              context,
              children: [
                _buildProfileOptionTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () => _showNotificationsDialog(context),
                ),
                const Divider(height: 0.5),
                _buildProfileOptionTile(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  onTap: () => _showThemeDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // --- Help & Support ---
            _buildOptionGroupContainer(
              context,
              children: [
                _buildProfileOptionTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => _showHelpSupportDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // --- Logout ---
            _buildOptionGroupContainer(
              context,
              children: [
                _buildProfileOptionTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  iconColor: Colors.redAccent[100],
                  textColor: Colors.redAccent[100],
                  onTap: () => _showLogoutConfirmationDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildOptionGroupContainer(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildProfileOptionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    // Khởi tạo trạng thái hover nếu chưa có
    _isOptionHovered[title] ??= false;

    return InkWell(
      onTap: onTap,
      onHover: (isHovered) {
        setState(() {
          _isOptionHovered[title] = isHovered;
        });
      },
      onTapDown: (_) {
        setState(() {
          _isOptionHovered[title] = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isOptionHovered[title] = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isOptionHovered[title] = false;
        });
      },
      highlightColor: Colors.grey.withOpacity(0.1),
      splashColor: Colors.grey.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _isOptionHovered[title]! 
              ? Colors.grey.withOpacity(0.05) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListTile(
          leading: Icon(icon, size: 22, color: iconColor),
          title: Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor),
          ),
          subtitle: subtitle != null 
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ) 
            : null,
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        ),
      ),
    );
  }
} 