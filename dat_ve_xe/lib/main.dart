import 'package:flutter/material.dart';
import 'layouts/main_layout.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Color defaultBorderColor = Colors.orange;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Layout',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.orange,
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black)),
        inputDecorationTheme: InputDecorationTheme(
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
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white)),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange, width: 2),
          ),
        ),
      ),
      home: const MainLayout(), // <-- Gọi layout chung tại đây
    );
  }
}
