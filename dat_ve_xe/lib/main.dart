import 'package:flutter/material.dart';
import 'layouts/main_layout.dart';
import 'themes/theme_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/myticket_screen/myticket_screen.dart';
import 'package:provider/provider.dart';
import 'service/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ConnectivityService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _currentLocale = const Locale('vi'); // Ngôn ngữ mặc định

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString('languageCode') ?? 'vi';
    setState(() {
      _currentLocale = Locale(savedLanguageCode);
    });
  }

  void _changeLanguage(Locale newLocale) {
    setState(() {
      _currentLocale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeManager,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'App Layout',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            primaryColor: Colors.orange,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orange),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orange, width: 2),
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            primaryColor: Colors.orange,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orange),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orange, width: 2),
              ),
            ),
          ),
          localizationsDelegates: const [
            // Thêm const ở đây
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            // Thêm const ở đây
            Locale('en'), // English
            Locale('vi'), // Vietnamese
          ],
          locale: _currentLocale, // Sử dụng _currentLocale
          home: MainLayout(onLanguageChanged: _changeLanguage),
          routes: {
            '/myticket':
                (context) => MyTicketScreen(onLanguageChanged: _changeLanguage),
          },
        );
      },
    );
  }
}
