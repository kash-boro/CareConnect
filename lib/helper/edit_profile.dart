import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const EditProfile({super.key, required this.initialData});

  @override
  // ignore: library_private_types_in_public_api
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController nameController;
  late TextEditingController bioController;
  late TextEditingController dobController;
  late TextEditingController phoneNumberController;
  late TextEditingController addressController;
  late TextEditingController genderController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialData['name']);
    bioController = TextEditingController(text: widget.initialData['bio']);
    dobController = TextEditingController(text: widget.initialData['dob']);
    phoneNumberController =
        TextEditingController(text: widget.initialData['phoneNumber']);
    addressController =
        TextEditingController(text: widget.initialData['address']);
    genderController =
        TextEditingController(text: widget.initialData['gender']);
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    dobController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.indigo[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
            TextField(
              controller: dobController,
              decoration: const InputDecoration(labelText: 'Date of Birth'),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: genderController,
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'bio': bioController.text,
                  'dob': dobController.text,
                  'phoneNumber': phoneNumberController.text,
                  'address': addressController.text,
                  'gender': genderController.text,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[700],
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
