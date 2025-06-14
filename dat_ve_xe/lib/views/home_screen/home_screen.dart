import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dat_ve_xe/views/trip/search_result_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _locations = [
    'Hà Nội',
    'Nghệ An',
    'Hồ Chí Minh',
    'Đà Nẵng',
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd/MM/yyyy', 'vi');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Đặt vé xe', style: TextStyle(color: Colors.orange)),
        iconTheme: IconThemeData(color: Colors.orange),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hộp chọn điểm đi & đến
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.radio_button_checked, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedStart,
                          isExpanded: true,
                          iconEnabledColor: Colors.orange,
                          dropdownColor: Colors.white,
                          style: TextStyle(color: Colors.orange, fontSize: 16),
                          items:
                              _locations
                                  .map(
                                    (loc) => DropdownMenuItem(
                                      value: loc,
                                      child: Text(loc),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStart = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.orange),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedDestination,
                          isExpanded: true,
                          iconEnabledColor: Colors.orange,
                          dropdownColor: Colors.white,
                          style: TextStyle(color: Colors.orange, fontSize: 16),
                          items:
                              _locations
                                  .map(
                                    (loc) => DropdownMenuItem(
                                      value: loc,
                                      child: Text(loc),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDestination = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Hộp chọn ngày
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? 'Ngày đi: ${dateFormat.format(_selectedDate!)}'
                          : 'Chưa chọn ngày đi',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text(
                      'Chọn ngày',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Nút tìm chuyến đi
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                if (_selectedStart == _selectedDestination) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Điểm đi và đến không được trùng nhau'),
                    ),
                  );
                  return;
                }
                if (_selectedStart == null ||
                    _selectedDestination == null ||
                    _selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng chọn đủ thông tin')),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => SearchResultScreen(
                          startLocation: _selectedStart!,
                          destination: _selectedDestination!,
                          selectedDate: _selectedDate!,
                        ),
                  ),
                );
              },
              child: Text('Tìm chuyến đi', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
