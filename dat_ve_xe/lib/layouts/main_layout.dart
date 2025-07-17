import 'package:dat_ve_xe/views/notification/notification_screen.dart';
import 'package:dat_ve_xe/views/personal_screen/personal_screen.dart';
import 'package:flutter/material.dart';
import 'package:dat_ve_xe/views/home_screen/home_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dat_ve_xe/views/myticket_screen/myticket_screen.dart';
import 'package:dat_ve_xe/views/delivery_screen/delivery_screen.dart';
import 'package:dat_ve_xe/widgets/floating_bubble.dart';
import 'package:dat_ve_xe/widgets/netwwork_status_banner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/notification_listener_service.dart';
import 'dart:async'; // Import for StreamSubscription

class MainLayout extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  final int selected; // Thêm dòng này

  const MainLayout({
    super.key,
    required this.onLanguageChanged,
    this.selected = 0, // Thêm dòng này
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;
  late final List<Widget> _pages;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _unreadCount = 0;
  User? _currentUser;
  int _deliveryUnread = 0;
  int _bookingUnread = 0;
  StreamSubscription? _unreadDeliverySub;
  StreamSubscription? _unreadBookingSub;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selected; // Sử dụng giá trị truyền vào
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FloatingBubblesManager.show(context);
    });
    _pages = [
      HomeScreen(),
      MyTicketScreen(onLanguageChanged: widget.onLanguageChanged),
      DeliveryScreen(onLanguageChanged: widget.onLanguageChanged),
      PersonalScreen(onLanguageChanged: widget.onLanguageChanged),
    ];

    // Lắng nghe realtime số lượng thông báo chưa đọc từ cả hai collection
    _listenUnreadNotifications();

    _auth.authStateChanges().listen((user) {
      if (user != null && user.uid != _currentUser?.uid) {
        _currentUser = user;
        _listenUnreadNotifications(); // Lắng nghe lại khi user đổi
      } else if (user == null) {
        setState(() {
          _currentUser = null;
          _unreadCount = 0;
        });
      }
    });
  }

  void _listenUnreadNotifications() {
    _unreadDeliverySub?.cancel();
    _unreadBookingSub?.cancel();
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _unreadCount = 0);
      return;
    }
    // Lắng nghe deliveryNotice
    _unreadDeliverySub = _firestore
        .collection('deliveryNotice')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      _deliveryUnread = snapshot.docs.length;
      setState(() {
        _unreadCount = _deliveryUnread + _bookingUnread;
      });
    });
    // Lắng nghe bookingNotice
    _unreadBookingSub = _firestore
        .collection('bookingNotice')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((bookingSnap) {
      _bookingUnread = bookingSnap.docs.length;
      setState(() {
        _unreadCount = _deliveryUnread + _bookingUnread;
      });
    });
  }

  Stream<int> get _unreadCountStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);
    final deliveryStream = _firestore
        .collection('deliveryNotice')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
    final bookingStream = _firestore
        .collection('bookingNotice')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
    return deliveryStream.asyncCombineLatestMain<int, int>(
      bookingStream,
      (delivery, booking) => delivery + booking,
    );
  }

  @override
  void dispose() {
    _unreadDeliverySub?.cancel();
    _unreadBookingSub?.cancel();
    super.dispose();
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
      child: Stack(
        children: [
          Scaffold(
            body: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: Color.fromARGB(255, 253, 109, 37),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Logo hoặc tên app (căn giữa)
                      SizedBox(
                        height: 70,
                        width: 200,
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
                        child: Stack(
                          children: [
                            StreamBuilder<int>(
                              stream: _unreadCountStream,
                              builder: (context, snapshot) {
                                final unread = snapshot.data ?? 0;
                                return Stack(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.notifications,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => NotificationScreen(
                                              onNotificationsUpdated: () {},
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    if (unread > 0)
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Text(
                                            '$unread',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
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
                        unselectedItemColor:
                            isDark ? Colors.black : Colors.white,
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
          // Lớp phủ banner trên cùng màn hình
          const Positioned(
            top: 300,
            left: 0,
            right: 0,
            child: NetworkStatusBanner(),
          ),
        ],
      ),
    );
  }
}

// Đổi tên extension để tránh xung đột
extension AsyncCombineLatestMainLayout<T> on Stream<T> {
  Stream<R> asyncCombineLatestMain<S, R>(Stream<S> other, R Function(T, S) combiner) {
    late T latestT;
    late S latestS;
    bool hasT = false;
    bool hasS = false;
    final controller = StreamController<R>();
    final subT = this.listen((t) {
      latestT = t;
      hasT = true;
      if (hasS) controller.add(combiner(latestT, latestS));
    });
    final subS = other.listen((s) {
      latestS = s;
      hasS = true;
      if (hasT) controller.add(combiner(latestT, latestS));
    });
    controller.onCancel = () {
      subT.cancel();
      subS.cancel();
    };
    return controller.stream;
  }
}
