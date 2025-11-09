import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<dynamic> helperList = [];
  List<dynamic> filteredList = [];
  bool isLoading = true;

  // Fetch data from the server
  Future<void> fetchHelpers() async {
    final url = "http://192.168.209.15/API/search.php"; // Replace with your API URL
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          helperList = data;
          filteredList = data; // Initialize the filtered list with all data
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load helpers: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching helpers: $e");
    }
  }

  // Filter helpers based on search query
  void filterHelpers(String query) {
    final filtered = helperList.where((helper) {
      final name = helper["H_name"]?.toLowerCase() ?? "";
      final input = query.toLowerCase();
      return name.contains(input);
    }).toList();
    setState(() {
      filteredList = filtered;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchHelpers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Helpers',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterHelpers, // Call filter function on text change
              decoration: InputDecoration(
                hintText: 'Search by name',
                prefixIcon: Icon(Icons.search, color: Colors.indigo[900]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.indigo[700]!),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? const Center(
                        child: Text(
                          "No helpers found",
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final helper = filteredList[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    helper["H_name"] ?? "Unknown",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Gender: ${helper["Gender"] ?? "N/A"}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Address: ${helper["Address"] ?? "N/A"}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
