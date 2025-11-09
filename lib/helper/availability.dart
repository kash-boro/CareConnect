import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  Map<String, bool> availability = {
    'Sunday': false,
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
  };

  Map<String, TimeOfDay> startTime = {};
  Map<String, TimeOfDay> endTime = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Load the user's preferences when the screen initializes
  }

  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    for (String day in availability.keys) {
      // Ensure the availability is initially false if not set
      bool isAvailable = prefs.getBool('${day}_available') ?? false;
      int startHour = prefs.getInt('${day}_start_hour') ?? 9;
      int startMinute = prefs.getInt('${day}_start_minute') ?? 0;
      int endHour = prefs.getInt('${day}_end_hour') ?? 17;
      int endMinute = prefs.getInt('${day}_end_minute') ?? 0;

      setState(() {
        availability[day] = isAvailable;
        startTime[day] = TimeOfDay(hour: startHour, minute: startMinute);
        endTime[day] = TimeOfDay(hour: endHour, minute: endMinute);
      });
    }
  }

  // Save preferences to SharedPreferences and API
  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    for (String day in availability.keys) {
      await prefs.setBool('${day}_available', availability[day]!);
      if (availability[day]!) {
        await prefs.setInt('${day}_start_hour', startTime[day]!.hour);
        await prefs.setInt('${day}_start_minute', startTime[day]!.minute);
        await prefs.setInt('${day}_end_hour', endTime[day]!.hour);
        await prefs.setInt('${day}_end_minute', endTime[day]!.minute);
      }
    }

    // Update the backend using the API URL
    await _updateAvailabilityToAPI();
  }

  // Method to update availability in the backend (API URL)
  Future<void> _updateAvailabilityToAPI() async {
    String apiUrl = 'https://192.168.209.15/API/h.php';
    String helperId = 'H_phone'; // Replace with the actual helper's ID

    for (String day in availability.keys) {
      if (availability[day]!) {
        // If the helper is available on this day, send start and end times to the API
        try {
          final response = await http.post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'H_phone': helperId,
              'day': day,
              'available': availability[day],
              'start_time': '${startTime[day]!.hour}:${startTime[day]!.minute}',
              'end_time': '${endTime[day]!.hour}:${endTime[day]!.minute}',
            }),
          );

          if (response.statusCode == 200) {
            print("Successfully updated availability for $day");
          } else {
            throw Exception("Failed to update availability for $day");
          }
        } catch (e) {
          print("Error updating availability for $day: $e");
        }
      } else {
        // If not available, remove the availability from the backend
        try {
          final response = await http.post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'helperId': helperId,
              'day': day,
              'available': false,
              'start_time': null,
              'end_time': null,
            }),
          );

          if (response.statusCode == 200) {
            print("Successfully removed availability for $day");
          } else {
            throw Exception("Failed to remove availability for $day");
          }
        } catch (e) {
          print("Error removing availability for $day: $e");
        }
      }
    }
  }

  // Method to handle availability toggle
  void _toggleAvailability(String day, bool value) {
    setState(() {
      availability[day] = value;
    });

    // Save the preference when toggled
    _savePreferences();
  }

  // Method to select time (start or end time)
  Future<void> _selectTime(
      BuildContext context, String day, bool isStartTime) async {
    TimeOfDay initialTime = isStartTime ? startTime[day]! : endTime[day]!;
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          startTime[day] = pickedTime;
        } else {
          endTime[day] = pickedTime;
        }
      });
      _savePreferences(); // Save preferences after updating the time
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Availability'),
        backgroundColor: Colors.indigo[700],
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(500, 255, 254, 254),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: availability.keys.map((day) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(day),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('Available'),
                      value: availability[day]!,
                      onChanged: (bool value) {
                        _toggleAvailability(day, value); // Handle toggle
                      },
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                    ),
                    if (availability[day]!) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('From: ${startTime[day]!.format(context)}'),
                          ElevatedButton(
                            onPressed: () => _selectTime(context, day, true),
                            child: const Text('Set Start Time'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('To: ${endTime[day]!.format(context)}'),
                          ElevatedButton(
                            onPressed: () => _selectTime(context, day, false),
                            child: const Text('Set End Time'),
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}