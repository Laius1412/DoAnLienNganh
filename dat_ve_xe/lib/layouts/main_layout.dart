import 'package:flutter/material.dart';
import 'package:dat_ve_xe/themes/theme_manager.dart';
import 'package:dat_ve_xe/views/home_screen/home_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const Center(child: Text('Tra cứu')),
    const Center(child: Text('Gửi hàng')),
    const Center(child: Text('Tài khoản')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _navItem(
    IconData icon,
    String label,
    int index,
    bool isDark,
  ) {
    bool selected = _selectedIndex == index;

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
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Color.fromARGB(255, 253, 109, 37),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nút đổi theme bên trái
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                      ),
                      onPressed: () {
                        themeManager.toggleTheme();
                      },
                    ),
                  ),

                  const SizedBox(width: 8),
                  // Logo hoặc tên app
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: kToolbarHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.asset(
                          'assets/app_icon/bannerApp.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Icon thông báo
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                      onPressed: () {
                        // Mở trang thông báo
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(child: _pages[_selectedIndex]),

            // Bottom Navigation
            Container(
              color: Color.fromARGB(255, 253, 109, 37),
              child: BottomNavigationBar(
                backgroundColor: Color.fromARGB(255, 253, 109, 37),
                selectedItemColor: isDark ? Colors.white : Colors.black,
                unselectedItemColor: isDark ? Colors.black : Colors.white,
                showUnselectedLabels: true,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 14,
                unselectedFontSize: 14,
                items: [
                  _navItem(Icons.home, 'Trang chủ', 0, isDark),
                  _navItem(Icons.local_activity, 'Vé của tôi', 1, isDark),
                  _navItem(Icons.local_shipping, 'Gửi hàng', 2, isDark),
                  _navItem(Icons.person, 'Tài khoản', 3, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
