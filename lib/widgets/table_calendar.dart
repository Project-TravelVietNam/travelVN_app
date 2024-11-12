import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:travelvn/widgets/home_bottom_bar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _checkInDay;
  DateTime? _checkOutDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn ngày đi du lịch nào'),
        backgroundColor: const Color.fromARGB(255, 239, 245, 255),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateColumn("Check In", _checkInDay),
                _buildDateColumn("Check Out", _checkOutDay),
              ],
            ),
            SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    if (_checkInDay == null || (_checkInDay != null && _checkOutDay != null)) {
                      _checkInDay = selectedDay;
                      _checkOutDay = null;
                    } else if (_checkOutDay == null && selectedDay.isAfter(_checkInDay!)) {
                      _checkOutDay = selectedDay;
                    }
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  rangeHighlightColor: Colors.blueAccent.withOpacity(0.2),
                  rangeStartDecoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  rangeEndDecoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.red),
                  todayTextStyle: TextStyle(color: Colors.white),
                ),
                rangeStartDay: _checkInDay,
                rangeEndDay: _checkOutDay,
              ),
            ),
            SizedBox(height: 16),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý Apply ở đây nha
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, 
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), 
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Apply',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomBar(currentIndex: 2),
    );
  }

  Widget _buildDateColumn(String title, DateTime? selectedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
            ),
            child: Text(
              selectedDate != null
                  ? "${selectedDate.day} ${selectedDate.month} ${selectedDate.year}"
                  : "Select Date",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
