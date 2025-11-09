import 'dart:convert';
import 'dart:developer'; // logging
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HelperScreen extends StatelessWidget {
  const HelperScreen({super.key});

  Future<List> fetchHelpers() async {
    const url = "http://192.168.209.15/API/h.php";
    try {
      final response = await http.get(Uri.parse(url));
      log('HTTP GET: $url - Status: ${response.statusCode}', name: 'API_CALL');

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
        title: const Text("Helper Management"),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List>(
        future: fetchHelpers(),
        builder: (ctx, ss) {
          if (ss.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ss.hasError) {
            return Center(child: Text("An error occurred: ${ss.error}"));
          }

          if (ss.hasData && ss.data!.isEmpty) {
            return const Center(child: Text("No Helpers Found"));
          }

          if (ss.hasData) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: ss.data!.length,
                    itemBuilder: (ctx, i) {
                      final name = ss.data![i]['H_name'] ?? 'Unknown Name';
                      final phone = ss.data![i]['H_phone'] ?? 'Unknown Phone';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Text('Phone: $phone', style: const TextStyle(fontSize: 16)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text("Unexpected error"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HelperRegistrationScreen()),
          );
        },
        backgroundColor: Colors.indigo, // Indigo button color
        child: const Icon(Icons.add, color: Colors.white,), // Plus icon
      ),
    );
  }
}

class HelperRegistrationScreen extends StatefulWidget {
  const HelperRegistrationScreen({super.key});

  @override
  _HelperRegistrationScreenState createState() => _HelperRegistrationScreenState();
}

class _HelperRegistrationScreenState extends State<HelperRegistrationScreen> {
  final phoneController = TextEditingController();
  final ratingController = TextEditingController();
  final availabilityController = TextEditingController();
  final aadharController = TextEditingController();
  final panController = TextEditingController();
  final nameController = TextEditingController();
  final skillsController = TextEditingController();
  final genderController = TextEditingController();
  final addressController = TextEditingController();
  final dobController = TextEditingController();
  final sidController = TextEditingController();

  Future<void> registerHelper() async {
    const url = "http://192.168.209.15/API/register_helper.php"; // Update with your actual endpoint
    try {
      final response = await http.post(Uri.parse(url), body: {
        'H_phone': phoneController.text,
        'Rating': ratingController.text,
        'Availability': availabilityController.text,
        'Aadhar': aadharController.text,
        'PAN': panController.text,
        'H_name': nameController.text,
        'Skills': skillsController.text,
        'Gender': genderController.text,
        'H_addr': addressController.text,
        'H_DOB': dobController.text,
        'S_ID': sidController.text,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Helper registered successfully!')),
          );
          Navigator.pop(context);
        } else {
          throw Exception(data['message'] ?? 'Failed to register helper.');
        }
      } else {
        throw Exception('Failed to connect to the server. Status: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Helper"),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
            TextField(controller: ratingController, decoration: const InputDecoration(labelText: "Rating")),
            TextField(controller: availabilityController, decoration: const InputDecoration(labelText: "Availability")),
            TextField(controller: aadharController, decoration: const InputDecoration(labelText: "Aadhar")),
            TextField(controller: panController, decoration: const InputDecoration(labelText: "PAN")),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: skillsController, decoration: const InputDecoration(labelText: "Skills")),
            TextField(controller: genderController, decoration: const InputDecoration(labelText: "Gender")),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: "Address")),
            TextField(controller: dobController, decoration: const InputDecoration(labelText: "Date of Birth (YYYY-MM-DD)")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: registerHelper,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.indigo),
              ),
              child: const Text("Register Helper"),
            ),
          ],
        ),
      ),
    );
  }
}
