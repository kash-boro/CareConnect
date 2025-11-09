import 'package:flutter/material.dart';

class LeaveApplicationScreen extends StatefulWidget {
  const LeaveApplicationScreen({super.key});

  @override
  _LeaveApplicationScreenState createState() => _LeaveApplicationScreenState();
}

class _LeaveApplicationScreenState extends State<LeaveApplicationScreen> {
  final TextEditingController reasonController = TextEditingController();

  void _submitLeaveApplication() {
    final reason = reasonController.text;
    if (reason.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Leave Application Submitted: $reason')),
      );
      reasonController.clear();
    }
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Leave'),
        backgroundColor: Colors.indigo[700],
        titleTextStyle: TextStyle(color: Color.fromARGB(500, 255, 254, 254)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason for Leave'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitLeaveApplication,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.indigo[700],
              ),
              child: const Text('Submit Leave Application', style:TextStyle(color: Color.fromARGB(500, 255, 254, 254))),
              
            ),
          ],
        ),
      ),
    );
  }
}
