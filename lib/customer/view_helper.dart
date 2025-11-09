import 'dart:convert';
import 'dart:developer'; //logging
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../customer/details.dart';

class ViewHelper extends StatefulWidget {
  final String email;
  const ViewHelper({super.key, required this.email});

  @override
  State<ViewHelper> createState() => _ViewHelperState();
}

class _ViewHelperState extends State<ViewHelper> {
  Future<List> getdata() async {
    const url = "http://192.168.209.15/API/h.php";
    try {
      final response = await http.get(Uri.parse(url));
      log('HTTP GET: $url - Status: ${response.statusCode}', name: 'API_CALL');
      log('Raw Response: ${response.body}', name: 'API_RESPONSE');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data;
        } else {
          throw Exception('Unexpected data format: ${response.body}');
        }
      } else {
        throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      log('Error fetching data: $e', name: 'API_ERROR', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text("Helpers"),
      backgroundColor: Colors.indigo[700], 
      foregroundColor: Colors.white,
),
      body: FutureBuilder<List>(
        future: getdata(),
        builder: (ctx, ss) {
          if (ss.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ss.hasError) {
            return Center(
              child: Text("An error occurred: ${ss.error}"),
            );
          }

          if (ss.hasData && ss.data!.isEmpty) {
            return const Center(child: Text("No Helpers Found"));
          }

          if (ss.hasData) {
            return Items(
              list: ss.data!,
              email: widget.email);
          }

          return const Center(child: Text("Unexpected error"));
        },
      ),
    );
  }
}

class Items extends StatelessWidget {
  final List list;
  final String email;
  const Items({super.key, required this.list, required this.email});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final name = list[i]['H_name'] ?? 'Unknown Name';
        final mobile = list[i]['H_phone'] ?? 'Unknown Mobile';
        final skills = list[i]['Skills'] ?? 'No skills listed';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 4,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            leading: const Icon(Icons.person),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mobile, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Text(skills, style: const TextStyle(color: Colors.black54)),
              ],
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Details(list: list, index: i, email: email),
              ),
            ),
          ),
        );
      },
    );
  }
}
