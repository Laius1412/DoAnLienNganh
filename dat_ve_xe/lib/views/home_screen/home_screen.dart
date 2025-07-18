import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dat_ve_xe/views/trip/search_result_screen.dart';
import '../../widgets/news_carousel.dart';
import '../../widgets/price_carousel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _locations = [
    'Hà Nội',
    'Nghệ An',
    'Ninh Bình',
    'Thanh Hóa',
  ];

  String? _selectedStart = 'Hà Nội';
  String? _selectedDestination = 'Nghệ An';
  DateTime? _selectedDate = DateTime.now();

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showLocationPicker(bool isStart) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.white;
    final headerColor = Color.fromARGB(255, 253, 109, 37);
    final textColor = isDark ? Colors.white : Colors.black;
    final selectedColor = Color.fromARGB(255, 253, 109, 37);
    final borderColor = isDark ? Colors.grey[700] : Colors.grey[300];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isStart ? 'Chọn điểm đi' : 'Chọn điểm đến',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _locations.length,
                itemBuilder: (context, index) {
                  final location = _locations[index];
                  final isSelected = isStart 
                      ? location == _selectedStart 
                      : location == _selectedDestination;
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: borderColor!),
                      ),
                      color: isSelected ? selectedColor.withOpacity(isDark ? 0.15 : 0.08) : Colors.transparent,
                    ),
                    child: ListTile(
                      title: Text(
                        location,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? selectedColor : textColor,
                        ),
                      ),
                      trailing: isSelected 
                          ? Icon(Icons.check, color: selectedColor)
                          : null,
                      onTap: () {
                        setState(() {
                          if (isStart) {
                            _selectedStart = location;
                          } else {
                            _selectedDestination = location;
                          }
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('EEEE, dd/MM/yyyy', Localizations.localeOf(context).languageCode);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final headerColor = Color.fromARGB(255, 253, 109, 37);
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final subTextColor = isDark ? Colors.white70 : Colors.black87;
    final accentColor = Color.fromARGB(255, 253, 109, 37);
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 345,
              child: Stack(
                children: [
                  // Header (thanh màu cam/dark)
                  Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: headerColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                  ),
                  // Card tìm kiếm chuyến đi, nổi lên header
                  Positioned(
                    left: 20,
                    right: 20,
                    top: 30,
                    child: Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Hộp chọn điểm đi & đến
                            Container(
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () => _showLocationPicker(true),
                                    child: Row(
                                      children: [
                                        Icon(Icons.radio_button_checked, color: Colors.white),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _selectedStart ?? l10n.tapToSelect,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.arrow_drop_down, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                  Divider(color: Colors.white),
                                  InkWell(
                                    onTap: () => _showLocationPicker(false),
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on, color: Colors.white),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _selectedDestination ?? l10n.tapToSelect,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.arrow_drop_down, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            // Hộp chọn ngày
                            Container(
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.white),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _selectedDate != null
                                          ? '${l10n.selectDate}: ${dateFormat.format(_selectedDate!)}'
                                          : l10n.tapToSelect,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _pickDate,
                                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                                    child: Text(l10n.selectDate, style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            // Nút tìm chuyến đi
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  if (_selectedStart == _selectedDestination) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(l10n.startEndMustNotBeSame)),
                                    );
                                    return;
                                  }
                                  if (_selectedStart == null ||
                                      _selectedDestination == null ||
                                      _selectedDate == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(l10n.enterAllFields)),
                                    );
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SearchResultScreen(
                                        startLocation: _selectedStart!,
                                        destination: _selectedDestination!,
                                        selectedDate: _selectedDate!,
                                        searchByStopsStart: true,
                                        searchByStopsEnd: true,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(l10n.search, style: TextStyle(fontSize: 18)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // PHẦN TIN TỨC
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.news,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: subTextColor),
                ),
              ),
            ),
            NewsCarousel(),
            // PHẦN GIÁ VÉ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.price,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: subTextColor),
                ),
              ),
            ),
            PriceCarousel(),
          ],
        ),
      ),
    );
  }
}
