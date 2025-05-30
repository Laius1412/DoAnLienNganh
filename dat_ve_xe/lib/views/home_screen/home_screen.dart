import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dat_ve_xe/views/trip/search_result_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _locations = ['Hà Nội', 'Nghệ An', 'Hồ Chí Minh', 'Đà Nẵng'];

  String? _selectedStart;
  String? _selectedDestination;
  DateTime? _selectedDate;

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
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: Text('Đặt vé xe')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedStart,
              hint: Text('Chọn điểm lên xe'),
              items: _locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedStart = value);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Điểm lên xe',
              ),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedDestination,
              hint: Text('Chọn điểm xuống xe'),
              items: _locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedDestination = value);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Điểm xuống xe',
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? 'Ngày đi: ${dateFormat.format(_selectedDate!)}'
                        : 'Chưa chọn ngày đi',
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: Text('Chọn ngày'),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
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
                    builder: (_) => SearchResultScreen(
                      startLocation: _selectedStart!,
                      destination: _selectedDestination!,
                      selectedDate: _selectedDate!,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.search),
              label: Text('Tìm xe'),
            ),
          ],
        ),
      ),
    );
  }
}
