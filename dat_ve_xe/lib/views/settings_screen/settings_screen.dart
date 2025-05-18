import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dat_ve_xe/themes/theme_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged;

  const SettingsScreen({super.key, required this.onLanguageChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguageCode = 'vi'; // Lưu mã ngôn ngữ (vi, en)
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
      _selectedLanguageCode = _prefs.getString('languageCode') ?? 'vi';
      _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _updateLanguage(String languageCode) async {
    await _prefs.setString('languageCode', languageCode);
    setState(() {
      _selectedLanguageCode = languageCode;
    });
    // Gọi callback để thông báo cho MyApp thay đổi Locale
    widget.onLanguageChanged(Locale(languageCode));
  }

  Future<void> _updateDarkMode(bool isDark) async {
    await _prefs.setBool('isDarkMode', isDark);
    setState(() {
      _isDarkMode = isDark;
      themeManager.toggleTheme();
    });
  }

  String _getDisplayLanguage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return AppLocalizations.of(context)!.english;
      case 'vi':
        return AppLocalizations.of(context)!.vietnamese;
      default:
        return AppLocalizations.of(context)!.vietnamese;
    }
  }

  String _getLanguageCode(String displayLanguage) {
    if (displayLanguage == AppLocalizations.of(context)!.english) {
      return 'en';
    } else if (displayLanguage == AppLocalizations.of(context)!.vietnamese) {
      return 'vi';
    } else {
      return 'vi';
    }
  }

  List<String> _getLanguageList() {
    if (_selectedLanguageCode == 'en') {
      return [
        AppLocalizations.of(context)!.english,
        AppLocalizations.of(context)!.vietnamese,
      ];
    } else {
      return [
        AppLocalizations.of(context)!.vietnamese,
        AppLocalizations.of(context)!.english,
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
        ), // Sử dụng localization
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppLocalizations.of(context)!.language, // Sử dụng localization
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _getDisplayLanguage(_selectedLanguageCode),
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
                _getLanguageList()
                    .map(
                      (lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) {
                _updateLanguage(_getLanguageCode(value));
              }
            },
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.theme, // Sử dụng localization
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.darkMode, // Sử dụng localization
                style: const TextStyle(fontSize: 16),
              ),
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
          Text(
            AppLocalizations.of(context)!.notifications, // Sử dụng localization
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              AppLocalizations.of(context)!.notificationSettings,
            ), // Sử dụng localization
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const Placeholder(), // Thay sau = NotificationSettingsScreen()
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
