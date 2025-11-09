import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadPolicyScreen extends StatelessWidget {
  const UploadPolicyScreen({super.key});

  void uploadPolicy() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // Process uploaded file
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Policies')),
      body: Center(
        child: ElevatedButton(
          onPressed: uploadPolicy,
          child: Text('Upload Policy Document'),
        ),
      ),
    );
  }
}
