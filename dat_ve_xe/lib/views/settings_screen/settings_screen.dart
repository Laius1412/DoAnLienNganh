import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dat_ve_xe/themes/theme_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'Tiếng Việt';
  bool _isDarkMode = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = _prefs.getString('language') ?? 'Tiếng Việt';
      _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _updateLanguage(String language) async {
    await _prefs.setString('language', language);
    setState(() {
      _selectedLanguage = language;
    });
  }

  Future<void> _updateDarkMode(bool isDark) async {
    await _prefs.setBool('isDarkMode', isDark);
    setState(() {
      _isDarkMode = isDark;
      themeManager.toggleTheme(); // toggle theme
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Ngôn ngữ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            items:
                ['Tiếng Anh', 'Tiếng Việt', 'Tiếng Việt (Nghệ An)']
                    .map(
                      (lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) _updateLanguage(value);
            },
          ),
          const SizedBox(height: 24),

          const Text(
            'Chế độ giao diện',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Chế độ tối", style: TextStyle(fontSize: 16)),
              FlutterSwitch(
                value: _isDarkMode,
                activeColor: const Color.fromARGB(255, 253, 109, 37),
                inactiveColor: Colors.grey.shade400,
                width: 60.0,
                height: 30.0,
                toggleSize: 25.0,
                borderRadius: 20.0,
                padding: 4.0,
                onToggle: _updateDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'Thông báo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Cài đặt thông báo'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          Placeholder(), // Thay sau = NotificationSettingsScreen()
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
