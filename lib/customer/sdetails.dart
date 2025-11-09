import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class ServiceDetails extends StatefulWidget {
  final List list;
  final int index;

  const ServiceDetails({super.key, required this.list, required this.index});

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  Future<void> submit() async {
    var url =
        "http://192.168.209.15/API/request.php"; // Update to match your server's IP or domain
    String customerEmail = "aaa";

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "C_mail": customerEmail,
        },
      );

      // Debug response
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data == "success") {
          Fluttertoast.showToast(
            backgroundColor: const Color.fromARGB(255, 248, 33, 33),
            textColor: Colors.white,
            msg: 'Request submitted successfully',
            toastLength: Toast.LENGTH_SHORT,
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Error"),
              content: Text(
                  "Failed to submit your booking request. Response: $data"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception("Failed to connect to the server.");
      }
    } catch (e) {
      print("Error: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("An unexpected error occurred: $e"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.list[widget.index]['S_name'] ?? 'Unknown Name';
    final phone = widget.list[widget.index]['type'] ?? 'Unknown Type';
    final availability = widget.list[widget.index]['Cost'] ?? 'Not Available';
    final gender = widget.list[widget.index]['Descr'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
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
                    DetailRow(label: "Service Name", value: phone),
                    DetailRow(label: "Cost", value: availability),
                    DetailRow(label: "Description", value: gender),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            MaterialButton(
              color: const Color.fromARGB(255, 109, 125, 224),
              onPressed: submit,
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