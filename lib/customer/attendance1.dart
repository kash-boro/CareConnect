import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Attendance1 extends StatefulWidget {
  final String email;

  const Attendance1({
    super.key,
    required this.email,
  });

  @override
  _Attendance1State createState() => _Attendance1State();
}

class _Attendance1State extends State<Attendance1> {
  DateTime selectedDate = DateTime.now();
  Map<DateTime, Map<String, dynamic>> attendanceData = {};

  Future<void> fetchAttendance() async {
  final url = "http://192.168.209.15//attendance.php";
  final response = await http.post(Uri.parse(url), body: {
    'C_mail': widget.email, 
  });

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data is List) {
      setState(() {
        attendanceData = {
          for (var entry in data)
            DateTime.parse(entry['Date']): {
              "status": entry['Status'],
              "inTime": entry['in_time'] != null
                  ? TimeOfDay.fromDateTime(DateTime.parse(entry['in_time']))
                  : null,
              "outTime": entry['out_time'] != null
                  ? TimeOfDay.fromDateTime(DateTime.parse(entry['out_time']))
                  : null,
            }
        };
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${data['message']}')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching attendance: ${response.statusCode}')),
    );
  }
}

  Future<void> updateAttendance(DateTime selectedDate, TimeOfDay? inTime, TimeOfDay? outTime, String? status) async {
  final url = "http://192.168.209.15/attendance.php";
  
  String inTimeString = inTime != null
      ? inTime.format(context) 
      : '';
  String outTimeString = outTime != null
      ? outTime.format(context)  
      : '';
  
  final response = await http.post(Uri.parse(url), body: {
    'C_mail': widget.email,
    'Date': selectedDate.toIso8601String().split('T')[0], 
    'in_time': inTimeString,
    'out_time': outTimeString,
    'status': status ?? 'Absent',
  });

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    if (responseData['status'] == 'success') {
      print('Attendance updated successfully!');
    } else {
      print('Error: ${responseData['message']}');
    }
  } else {
    print('Failed to update attendance');
  }
}

  Future<void> _showAttendanceDetails(BuildContext context) async {
    Map<String, dynamic> dayData = attendanceData[selectedDate] ?? 
        {"status": null, "inTime": null, "outTime": null};

    String? attendanceStatus = dayData["status"];
    TimeOfDay? inTime = dayData["inTime"];
    TimeOfDay? outTime = dayData["outTime"];

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> _pickInTime() async {
              final selectedTime = await showTimePicker(
                context: context,
                initialTime: inTime ?? TimeOfDay.now(),
              );
              if (selectedTime != null) {
                setModalState(() => inTime = selectedTime);
              }
            }

            Future<void> _pickOutTime() async {
              final selectedTime = await showTimePicker(
                context: context,
                initialTime: outTime ?? TimeOfDay.now(),
              );
              if (selectedTime != null) {
                setModalState(() => outTime = selectedTime);
              }
            }

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
                      const Text("In Time: "),
                      Text(inTime != null ? inTime!.format(context) : "Not Set"),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _pickInTime,
                        child: const Text("Set In Time"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text("Out Time: "),
                      Text(outTime != null ? outTime!.format(context) : "Not Set"),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _pickOutTime,
                        child: const Text("Set Out Time"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text("Status: "),
                      DropdownButton<String>(
                        value: attendanceStatus,
                        items: ["Present", "Absent"]
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (newStatus) {
                          setModalState(() => attendanceStatus = newStatus);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        attendanceData[selectedDate] = {
                          "status": attendanceStatus,
                          "inTime": inTime,
                          "outTime": outTime,
                        };
                      });
                      updateAttendance(selectedDate, inTime, outTime, attendanceStatus);
                      Navigator.pop(context);
                    },
                    child: const Text("Submit"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance Calendar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          focusedDay: selectedDate,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
          ),
          calendarStyle: const CalendarStyle(
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
          selectedDayPredicate: (day) => isSameDay(selectedDate, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() => selectedDate = selectedDay);
            _showAttendanceDetails(context);
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              if (attendanceData.containsKey(day)) {
                final status = attendanceData[day]?["status"];
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
      ),
    );
  }
}
