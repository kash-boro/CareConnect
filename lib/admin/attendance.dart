import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data; replace with API call for real data
    List<Map<String, String>> attendanceData = [
      {"helper": "Rima", "date": "2024-11-10", "status": "Present"}
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Tracking"),
        backgroundColor: Colors.indigo[700], // Indigo AppBar color
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: attendanceData.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(attendanceData[index]["helper"]!),
              subtitle: Text("Date: ${attendanceData[index]["date"]!}"),
              trailing: Text(attendanceData[index]["status"]!,
                  style: TextStyle(
                    color: attendanceData[index]["status"] == "Present"
                        ? Colors.green
                        : Colors.red,
                  )),
            ),
          );
        },
      ),
    );
  }
}
