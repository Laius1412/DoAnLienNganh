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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 253, 109, 37),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  
                  return ListTile(
                    title: Text(
                      location,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Color.fromARGB(255, 253, 109, 37) : Colors.black,
                      ),
                    ),
                    trailing: isSelected 
                        ? const Icon(Icons.check, color: Color.fromARGB(255, 253, 109, 37))
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
    final dateFormat = DateFormat('EEEE, dd/MM/yyyy', 'vi');

    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chào bạn',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25, // to hơn
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'Đã có vé về quê chưa',
                style: TextStyle(
                  color: const Color.fromARGB(255, 39, 38, 38),
                  fontSize: 16, // nhỏ hơn
                ),
              ),
            ],
          ),
          iconTheme: IconThemeData(color: Color.fromARGB(255, 253, 109, 37)),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hộp chọn điểm đi & đến
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 253, 109, 37), width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => _showLocationPicker(true),
                    child: Row(
                      children: [
                        Icon(Icons.radio_button_checked, color: Color.fromARGB(255, 253, 109, 37)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedStart ?? 'Chọn điểm đi',
                            style: TextStyle(
                              color: Color.fromARGB(255, 253, 109, 37),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Color.fromARGB(255, 253, 109, 37)),
                      ],
                    ),
                  ),
                  Divider(color: Color.fromARGB(255, 253, 109, 37)),
                  InkWell(
                    onTap: () => _showLocationPicker(false),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Color.fromARGB(255, 253, 109, 37)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedDestination ?? 'Chọn điểm đến',
                            style: TextStyle(
                              color: Color.fromARGB(255, 253, 109, 37),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Color.fromARGB(255, 253, 109, 37)),
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
                border: Border.all(color: Color.fromARGB(255, 253, 109, 37), width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Color.fromARGB(255, 253, 109, 37)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? 'Ngày đi: ${dateFormat.format(_selectedDate!)}'
                          : 'Chưa chọn ngày đi',
                      style: TextStyle(color: Color.fromARGB(255, 253, 109, 37)),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text('Chọn ngày', style: TextStyle(color: Color.fromARGB(255, 253, 109, 37))),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Nút tìm chuyến đi
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 253, 109, 37),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                if (_selectedStart == _selectedDestination) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Điểm đi và đến không được trùng nhau')),
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
              child: Text('Tìm chuyến đi', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
