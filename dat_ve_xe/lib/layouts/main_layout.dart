import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  final List<Widget> _pages = [
    const Center(child: Text('Trang chủ')),
    const Center(child: Text('Tra cứu')),
    const Center(child: Text('Gửi hàng')),
    const Center(child: Text('Tài khoản')),
  ];

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _navItem(IconData icon, String label, int index) {
    bool selected = _selectedIndex == index;
    bool isDark = _isDarkMode;

    Color selectedBg = isDark ? Colors.black : Colors.white;
    Color selectedFg = isDark ? Colors.white : Colors.black;
    Color unselectedFg = isDark ? Colors.black : Colors.white;

    return BottomNavigationBarItem(
      icon: Container(
        decoration:
            selected
                ? BoxDecoration(
                  color: selectedBg,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                )
                : null,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Icon(icon, color: selected ? selectedFg : unselectedFg),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = _isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white)),
      ),
      home: Scaffold(
        body: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.orange,
              child: Row(
                children: [
                  // Nút đổi theme bên trái
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                    onPressed: _toggleTheme,
                  ),
                  const SizedBox(width: 8),
                  // Logo hoặc tên app
                  Text(
                    'LOGO APP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                  const Spacer(),
                  // Icon thông báo
                  IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                    onPressed: () {
                      // Mở trang thông báo
                    },
                  ),
                ],
              ),
            ),

            // Body
            Expanded(child: _pages[_selectedIndex]),

            // Bottom Navigation
            Container(
              color: Colors.orange,
              child: BottomNavigationBar(
                backgroundColor: Colors.orange,
                selectedItemColor: isDark ? Colors.white : Colors.black,
                unselectedItemColor: isDark ? Colors.black : Colors.white,
                showUnselectedLabels: true,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 14,
                unselectedFontSize: 14,
                items: [
                  _navItem(Icons.home, 'Trang chủ', 0),
                  _navItem(Icons.search, 'Tra cứu', 1),
                  _navItem(Icons.local_shipping, 'Gửi hàng', 2),
                  _navItem(Icons.person, 'Tài khoản', 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
