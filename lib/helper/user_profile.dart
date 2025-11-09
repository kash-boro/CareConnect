import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserProfile extends StatefulWidget {
  final String email;

  const UserProfile({super.key, required this.email});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, dynamic>? profile;
  List<String> skills = [];
  bool isAvailable = false;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  // Fetch profile data from the server using the provided email
  fetchProfileData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.209.15/API/h.php?email=${widget.email}'),
      );

      print(
          "Fetching profile for email: ${widget.email}"); // Debugging print statement

      if (response.statusCode == 200) {
        // Decode the response
        List<dynamic> data = json.decode(response.body);
        print("Response Data: $data"); // Debugging print statement

        if (data.isNotEmpty) {
          setState(() {
            profile = data[0]; // Get the first profile data

            // Safely handle potential type mismatches by converting to String if necessary
            skills = (profile?['Skills'] ?? '')
                .split(','); // Convert comma-separated skills to a list
            isAvailable = (profile?['Availability'] ==
                'Available'); // Ensure boolean logic for availability

            // Ensure other fields are treated as strings (use .toString() if needed)
            profile?['H_name'] = profile?['H_name'].toString();
            profile?['H_DOB'] = profile?['H_DOB'].toString();
            profile?['H_phone'] = profile?['H_phone'].toString();
            profile?['H_addr'] = profile?['H_addr'].toString();
            profile?['Gender'] = profile?['Gender'].toString();
          });
        } else {
          print("No data found for the provided email.");
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // Toggle the availability and update both locally and on the server
  void _toggleAvailability() {
    setState(() {
      isAvailable = !isAvailable;
      profile?['Availability'] = isAvailable ? "Available" : "Not Available";
    });

    updateAvailabilityOnServer();
  }

  // Send the updated availability to the server
  void updateAvailabilityOnServer() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.209.15/API/h3.php'),
        body: {
          'email': widget.email,
          'availability': isAvailable ? 'Available' : 'Not Available',
        },
      );

      if (response.statusCode == 200) {
        print("Availability updated successfully");
      } else {
        print("Error updating availability: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating availability: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile?['H_name'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProfileCard(Icons.cake, 'Date of Birth',
                        profile?['H_DOB'] ?? 'N/A'),
                    _buildProfileCard(Icons.phone, 'Phone Number',
                        profile?['H_phone'] ?? 'N/A'),
                    _buildProfileCard(
                        Icons.home, 'Address', profile?['H_addr'] ?? 'N/A'),
                    _buildProfileCard(
                        Icons.person, 'Gender', profile?['Gender'] ?? 'N/A'),
                    
                    _buildSectionTitle('Skills & Services'),
                    Wrap(
                      spacing: 8,
                      children: skills.map((skill) {
                        return Chip(
                          label: Text(skill),
                          backgroundColor: Colors.indigo[50],
                          labelStyle: const TextStyle(color: Colors.indigo),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper method to build the profile information cards
  Widget _buildProfileCard(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  // Helper method to display section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }
}