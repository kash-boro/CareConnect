import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; 

class Details extends StatefulWidget {
  final List list;
  final int index;
  final String email;

  const Details({super.key, required this.list, required this.index, required this.email});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> pickDateAndTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    setState(() {
      selectedDate = pickedDate;
      selectedTime = pickedTime;
    });
  }

  String formatTime(TimeOfDay timeOfDay) {
  final hour = timeOfDay.hour.toString().padLeft(2, '0'); // Ensures two digits
  final minute = timeOfDay.minute.toString().padLeft(2, '0'); // Ensures two digits
  return "$hour:$minute"; // Returns time in HH:mm format
}

  Future<void> submit() async {
  if (selectedDate == null || selectedTime == null) {
    Fluttertoast.showToast(
      msg: "Please select a date and time before submitting.",
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    return;
  }

  final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!); // Format date as yyyy-MM-dd
  final formattedTime = formatTime(selectedTime!); // Use custom formatTime function

  // Combine them to match the format: yyyy-MM-dd HH:mm
  final dateTime = "$formattedDate $formattedTime"; // Combine date and time in desired format

  // Print the formatted date-time to the console for debugging
  print("Formatted date-time: $dateTime");

  final helperName = widget.list[widget.index]['H_name'] ?? 'Unknown Name';
  final serviceType = widget.list[widget.index]['Skills'] ?? 'Unknown Service';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Booking"),
      content: Text(
        "Are you sure you want to book $helperName for $serviceType on $dateTime?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await sendRequest(dateTime, helperName, serviceType);
          },
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

  Future<void> sendRequest(String dateTime, String helperName, String serviceType) async {
    var url = "http://192.168.209.15/API/request.php";

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "C_mail": widget.email,
          "date_time": dateTime,
          "H_name": helperName,
          "H_skills": serviceType,
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['status'] == "success") {
          Fluttertoast.showToast(
            backgroundColor: Colors.green,
            textColor: Colors.white,
            msg: 'Request submitted successfully!',
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Error"),
              content: Text(data['message'] ?? "Failed to submit your booking request."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception("Server returned ${response.statusCode}");
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("An unexpected error occurred: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.list[widget.index]['H_name'] ?? 'Unknown Name';
    final phone = widget.list[widget.index]['H_phone'] ?? 'Unknown Mobile';
    final availability = widget.list[widget.index]['Availability'] ?? 'Not Available';
    final gender = widget.list[widget.index]['Gender'] ?? 'Unknown';
    final rating = widget.list[widget.index]['Rating'] ?? 'N/A';
    final skills = widget.list[widget.index]['Skills'] ?? 'Not Specified';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueGrey[100],
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailRow(label: "Phone", value: phone),
                    DetailRow(label: "Availability", value: availability),
                    DetailRow(label: "Gender", value: gender),
                    DetailRow(label: "Rating", value: rating),
                    DetailRow(label: "Skills", value: skills),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            MaterialButton(
              color: Colors.blue,
              onPressed: () async {
                await pickDateAndTime();
                if (selectedDate != null && selectedTime != null) {
                  submit();
                }
              },
              child: const Text(
                "Submit Booking Request",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
