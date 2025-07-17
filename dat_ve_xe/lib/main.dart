import 'package:dat_ve_xe/views/delivery_screen/myDeliveries_screen.dart';
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
import 'service/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'views/notification/notification_screen.dart';
import 'service/notification_listener_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'service/push_notification_service.dart';

// Import background handler
import 'service/notification_service.dart'
    show firebaseMessagingBackgroundHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Đăng ký background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Khởi tạo notification service
  await NotificationService.initialize();

  // Khởi tạo notification listener service
  NotificationListenerService.initialize();

  // Khởi tạo push notification service (hiện local notification khi nhận FCM)
  await PushNotificationService.initialize();

  // Tạo notification channel cho Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'delivery_notifications', // Phải trùng với channelId bên web admin/server
    'Thông báo đơn hàng', // Tên hiển thị (tùy ý)
    description: 'Thông báo trạng thái đơn giao hàng', // Mô tả (tùy ý)
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
    // Gán navigatorKey cho NotificationService
    NotificationService.navigatorKey = _navigatorKey;
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
          navigatorKey: _navigatorKey,
          home: MainLayout(onLanguageChanged: _changeLanguage),
          routes: {
            '/myticket':
                (context) => MyTicketScreen(onLanguageChanged: _changeLanguage),
            '/myDeliveries':
                (context) =>
                    MyDeliveriesScreen(onLanguageChanged: _changeLanguage),
            '/notifications':
                (context) => NotificationScreen(onNotificationsUpdated: () {}),
          },
        );
      },
    );
  }
}
