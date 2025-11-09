import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadDocumentsScreen extends StatelessWidget {
  const UploadDocumentsScreen({super.key});

  void _uploadDocument(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String filePath = result.files.single.path!;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded: $filePath')),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Documents'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _uploadDocument(context),
          child: const Text('Choose Document'),
        ),
      ),
    );
  }
}
