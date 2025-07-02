// main_settings_view.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  String? hoveredTile;

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    final isHovered = hoveredTile == title;
    
    return Container(
      width: MediaQuery.of(context).size.width * 100,
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(
            color: Colors.white,
            width: 0.7,
          ),
        ),
        color: isHovered ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: InkWell(
        onTap: onTap,
        onHover: (value) {
          setState(() {
            hoveredTile = value ? title : null;
          });
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon, 
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios, 
                size: 10,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, {Color? color, String? url}) {
    return GestureDetector(
      onTap: () async {
        if (url != null) {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FaIcon(
          icon,
          size: 12,
          color: color ?? Colors.white,
        ),
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xff491475),
          title: const Text(
            'Delete Saved Data',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          content: const Text(
            'Are you sure you want to delete all saved data? This action cannot be undone.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xff491475),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_token');
                Navigator.of(context).pop();
                context.go('/signin');
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff280446),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.67,
          margin: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xff491475),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 16),
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      _buildSettingTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () {
                          context.go('/dashboard/settings/notification');
                        },
                      ),
                      _buildSettingTile(
                        icon: Icons.delete_outline,
                        title: 'Delete Saved Data',
                        onTap: _showDeleteDataDialog,
                      ),
                      _buildSettingTile(
                        icon: Icons.favorite_outline,
                        title: 'Rate Us',
                        onTap: () async {
                          const url = 'https://play.google.com/store/apps/details?id=your.app.package';
                          final Uri uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                      ),
                      // _buildSettingTile(
                      //   icon: Icons.import_export_outlined,
                      //   title: 'Import and Export',
                      //   onTap: () {
                      //     context.go('/dashboard/settings/import-export');
                      //   },
                      // ),
                      _buildSettingTile(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () {
                          context.go('/dashboard/settings/about');
                        },
                      ),
                      // _buildSettingTile(
                      //   icon: Icons.language_outlined,
                      //   title: 'Language',
                      //   onTap: () {
                      //     context.go('/dashboard/settings/language');
                      //   },
                      // ),
                      // _buildSettingTile(
                      //   icon: Icons.palette_outlined,
                      //   title: 'Theme',
                      //   onTap: () {
                      //     context.go('/dashboard/settings/theme');
                      //   },
                      // ),
                      // _buildSettingTile(
                      //   icon: Icons.support_outlined,
                      //   title: 'Supported By',
                      //   onTap: () {
                      //     context.go('/dashboard/settings/supported-by');
                      //   },
                      // ),
                      _buildSettingTile(
                        icon: Icons.logout_outlined,
                        title: 'Logout',
                        onTap: _showLogoutDialog,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Follow Us On',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialIcon(
                      FontAwesomeIcons.instagram,
                      color: const Color(0xFFE4405F),
                      url: 'https://instagram.com/yourapp',
                    ),
                    const SizedBox(width: 8),
                    _buildSocialIcon(
                      Icons.language,
                      color: Colors.blue[600],
                      url: 'https://yourwebsite.com',
                    ),
                    const SizedBox(width: 8),
                    _buildSocialIcon(
                      FontAwesomeIcons.facebook,
                      color: const Color(0xFF1877F2),
                      url: 'https://facebook.com/yourapp',
                    ),
                    const SizedBox(width: 8),
                    _buildSocialIcon(
                      FontAwesomeIcons.xTwitter,
                      color: Colors.black87,
                      url: 'https://twitter.com/yourapp',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import_export_view.dart
class ImportExportView extends StatelessWidget {
  const ImportExportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        title: const Text(
          'Import & Export',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff280446),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xff491475),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Backup & Restore',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              
              // Import Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement import functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Import functionality coming soon')),
                    );
                  },
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                  label: const Text(
                    'Import Data',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Export Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement export functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export functionality coming soon')),
                    );
                  },
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: const Text(
                    'Export Data',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// about_view.dart
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff280446),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xff491475),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Icon/Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.apps,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Your App Name',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                const Text(
                  'App Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 15),
                
                const Text(
                  'This is a comprehensive mobile application designed to provide users with an intuitive and seamless experience. Our app focuses on delivering high-quality features with a modern and user-friendly interface.\n\nBuilt with Flutter, this application demonstrates the power of cross-platform development while maintaining native performance and beautiful design aesthetics.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 30),
                
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 15),
                
                const Text(
                  'Email: support@yourapp.com\nWebsite: www.yourapp.com\nPhone: +1 (555) 123-4567',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 30),
                
                const Text(
                  '© 2024 Your Company Name. All rights reserved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// language_view.dart
class LanguageView extends StatefulWidget {
  const LanguageView({super.key});

  @override
  State<LanguageView> createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView> {
  String selectedLanguage = 'English';
  
  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'Spanish', 'code': 'es'},
    {'name': 'French', 'code': 'fr'},
    {'name': 'German', 'code': 'de'},
    {'name': 'Italian', 'code': 'it'},
    {'name': 'Portuguese', 'code': 'pt'},
    {'name': 'Chinese', 'code': 'zh'},
    {'name': 'Japanese', 'code': 'ja'},
    {'name': 'Korean', 'code': 'ko'},
    {'name': 'Arabic', 'code': 'ar'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selected_language') ?? 'English';
    });
  }

  _saveLanguage(String language, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);
    await prefs.setString('language_code', code);
    
    // TODO: Implement language change API call here
    // await changeAppLanguage(code);
    
    setState(() {
      selectedLanguage = language;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Language changed to $language')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        title: const Text(
          'Language',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff280446),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xff491475),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index];
              final isSelected = selectedLanguage == language['name'];
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(
                    language['name']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected 
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                  onTap: () {
                    _saveLanguage(language['name']!, language['code']!);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// theme_view.dart
class ThemeView extends StatefulWidget {
  const ThemeView({super.key});

  @override
  State<ThemeView> createState() => _ThemeViewState();
}

class _ThemeViewState extends State<ThemeView> {
  String selectedTheme = 'Dark';
  
  final List<Map<String, dynamic>> themes = [
    {
      'name': 'Light',
      'colors': [Colors.white, Colors.grey[100]],
      'textColor': Colors.black,
    },
    {
      'name': 'Dark',
      'colors': [const Color(0xff280446), const Color(0xff491475)],
      'textColor': Colors.white,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedTheme();
  }

  _loadSelectedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTheme = prefs.getString('selected_theme') ?? 'Dark';
    });
  }

  _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', theme);
    
    setState(() {
      selectedTheme = theme;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Theme changed to $theme')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        title: const Text(
          'Theme',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff280446),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xff491475),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: themes.map((theme) {
              final isSelected = selectedTheme == theme['name'];
              
              return GestureDetector(
                onTap: () => _saveTheme(theme['name']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Theme Preview
                      Container(
                        width: 60,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: theme['colors'],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      
                      Expanded(
                        child: Text(
                          '${theme['name']} Theme',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                        ),
                      ),
                      
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// supported_by_view.dart
class SupportedByView extends StatelessWidget {
  const SupportedByView({super.key});

  final List<Map<String, String>> sponsors = const [
    {
      'name': 'Tech Innovations Inc.',
      'description': 'Leading technology solutions provider',
      'logo': '🏢',
    },
    {
      'name': 'Digital Solutions Ltd.',
      'description': 'Expert digital transformation consultancy',
      'logo': '💼',
    },
    {
      'name': 'Future Tech Foundation',
      'description': 'Supporting innovative technology projects',
      'logo': '🚀',
    },
    {
      'name': 'Cloud Services Pro',
      'description': 'Premium cloud infrastructure provider',
      'logo': '☁️',
    },
    {
      'name': 'Mobile First Company',
      'description': 'Mobile-first development specialists',
      'logo': '📱',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        title: const Text(
          'Supported By',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff280446),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xff491475),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Our Amazing Sponsors',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: sponsors.length,
                  itemBuilder: (context, index) {
                    final sponsor = sponsors[index];
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                sponsor['logo']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 15),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sponsor['name']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  sponsor['description']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Thank you for your continued support!',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}