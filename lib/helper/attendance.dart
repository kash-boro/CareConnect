import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key, required String helperPhone});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime selectedDate = DateTime.now();
  Map<DateTime, Map<String, dynamic>> attendanceRecords = {
    DateTime(2023, 10, 1): {
      'status': 'Present',
      'time': '09:00 AM - 05:00 PM',
      'hours': '8 hours',
      'location': 'ABCD',
      'inTime': TimeOfDay(hour: 9, minute: 0),
      'outTime': TimeOfDay(hour: 17, minute: 0),
    },
    DateTime(2023, 10, 2): {
      'status': 'Absent',
      'time': 'N/A',
      'hours': '0 hours',
      'location': 'N/A',
      'inTime': null,
      'outTime': null,
    },
  };

  Future<void> _showAttendanceDetails(BuildContext context) async {
    Map<String, dynamic> dayData = attendanceRecords[selectedDate] ??
        {"status": null, "time": null, "hours": null, "location": null};

    String? attendanceStatus = dayData["status"];
    TimeOfDay? inTime = dayData["inTime"];
    TimeOfDay? outTime = dayData["outTime"];

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Attendance Details - ${selectedDate.toLocal().toString().split(' ')[0]}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("Status: "),
                  Text(
                    attendanceStatus ?? "Not Set",
                    style: TextStyle(
                      color: attendanceStatus == 'Present'
                          ? Colors.green
                          : (attendanceStatus == 'Absent'
                              ? Colors.red
                              : Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("In Time: "),
                  Text(inTime != null ? inTime!.format(context) : "Not Set"),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Out Time: "),
                  Text(outTime != null ? outTime!.format(context) : "Not Set"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Show a complete table with attendance records
  void _viewCompleteAttendance(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Complete Attendance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('In Time')),
                      DataColumn(label: Text('Out Time')),
                    ],
                    rows: attendanceRecords.entries
                        .map(
                          (entry) => DataRow(cells: [
                            DataCell(Text(
                                entry.key.toLocal().toString().split(' ')[0])),
                            DataCell(Text(entry.value['status'] ?? 'N/A')),
                            DataCell(Text(entry.value['inTime'] != null
                                ? entry.value['inTime'].format(context)
                                : 'Not Set')),
                            DataCell(Text(entry.value['outTime'] != null
                                ? entry.value['outTime'].format(context)
                                : 'Not Set')),
                          ]),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.indigo[700],
        titleTextStyle:
            const TextStyle(color: Color.fromARGB(500, 255, 254, 254)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Calendar Widget
            TableCalendar(
              focusedDay: selectedDate,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.indigo,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              selectedDayPredicate: (day) => selectedDate.day == day.day,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = selectedDay;
                });
                _showAttendanceDetails(context);
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  if (attendanceRecords.containsKey(day)) {
                    final status = attendanceRecords[day]?["status"];
                    return Container(
                      decoration: BoxDecoration(
                        color: status == "Present"
                            ? Colors.green
                            : (status == "Absent" ? Colors.red : null),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        day.day.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            // View Attendance Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _viewCompleteAttendance(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.indigo[700], // Use backgroundColor here
                ),
                child: const Text(
                  'View Attendance',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}