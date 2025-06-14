import 'package:dat_ve_xe/views/notification/notification_screen.dart';
import 'package:dat_ve_xe/views/personal_screen/personal_screen.dart';
import 'package:flutter/material.dart';
import 'package:dat_ve_xe/views/home_screen/home_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dat_ve_xe/views/myticket_screen/myticket_screen.dart';
import 'package:dat_ve_xe/views/delivery_screen/delivery_screen.dart';
import 'package:dat_ve_xe/widgets/floating_bubble.dart';

class MainLayout extends StatefulWidget {
  final Function(Locale) onLanguageChanged;

  const MainLayout({super.key, required this.onLanguageChanged});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FloatingBubblesManager.show(context);
    });
    _pages = [
      HomeScreen(),
      MyTicketScreen(onLanguageChanged: widget.onLanguageChanged),
      DeliveryScreen(onLanguageChanged: widget.onLanguageChanged),
      PersonalScreen(onLanguageChanged: widget.onLanguageChanged),
    ];
  }

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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Nút đổi theme bên trái

                  // Logo hoặc tên app (căn giữa)
                  SizedBox(
                    height:
                        70, // Đảm bảo banner có kích thước giống với thanh AppBar
                    width: 200, // Đặt chiều rộng mong muốn
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        'assets/app_icon/bannerApp.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Icon thông báo bên phải
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ),
                        ); // Mở trang thông báo
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
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 10,
                top: 4,
              ),
              color: Colors.transparent,
              child: PhysicalModel(
                color: Color.fromARGB(255, 253, 109, 37),
                elevation: 8,
                borderRadius: BorderRadius.circular(15),
                shadowColor: Colors.black.withOpacity(0.3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
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
                      _navItem(
                        Icons.home,
                        AppLocalizations.of(context)!.home,
                        0,
                        isDark,
                      ),
                      _navItem(
                        Icons.local_activity,
                        AppLocalizations.of(context)!.myTickets,
                        1,
                        isDark,
                      ),
                      _navItem(
                        Icons.local_shipping,
                        AppLocalizations.of(context)!.delivery,
                        2,
                        isDark,
                      ),
                      _navItem(
                        Icons.person,
                        AppLocalizations.of(context)!.account,
                        3,
                        isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
