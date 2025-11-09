import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.indigo[700],
        titleTextStyle: TextStyle(color: Color.fromARGB(500, 255, 254, 254)),
      ),
      body: const Center(
        child: Text("You have no new notifications."),
      ),
    );
  }
}
