import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Check In và Check Out 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text("Check In"),
                    Text(
                      _checkInDay != null
                          ? "${_checkInDay!.day} ${_checkInDay!.month} ${_checkInDay!.year}"
                          : "Select Date",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text("Check Out"),
                    Text(
                      _checkOutDay != null
                          ? "${_checkOutDay!.day} ${_checkOutDay!.month} ${_checkOutDay!.year}"
                          : "Select Date",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            // Calendar Widget
            TableCalendar(
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
                rangeHighlightColor: Colors.blueAccent,
                rangeStartDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
              ),
              rangeStartDay: _checkInDay,
              rangeEndDay: _checkOutDay,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Xử lý nút apply
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text('Apply', style: TextStyle(
                color: Colors.white,
                fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
