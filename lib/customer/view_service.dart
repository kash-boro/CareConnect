import 'dart:convert';
import 'dart:developer'; //logging
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewService extends StatefulWidget {
  const ViewService({super.key});

  @override
  State<ViewService> createState() => _ViewServiceState();
}

class _ViewServiceState extends State<ViewService> {

  Future<List> getdata() async {
    const url = "http://192.168.209.15/API/s.php";
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
        title: const Text("Services Available", style: TextStyle(fontSize: 20),),
        backgroundColor: Colors.indigo[700], // Set the AppBar color to Indigo 700
        titleTextStyle: const TextStyle(color: Colors.white), // Set text color to white
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
            return const Center(child: Text("No Service Found"));
          }

          if (ss.hasData) {
            return Items(list: ss.data!);
          }

          return const Center(child: Text("Unexpected error"));
        },
      ),
    );
  }
}

class Items extends StatelessWidget {
  final List list;
  const Items({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final name = list[i]['S_Name'] ?? 'Unknown Name';
        final type = list[i]['S_type'] ?? 'Unknown type';
        final cost = list[i]['Cost'] ?? 'Unknown cost';
        final des = list[i]['Descr'] ?? 'Unknown description';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 4,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('\Rs $cost', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Text(des),
              ],
            ),
          ),
        );
      },
    );
  }
}
