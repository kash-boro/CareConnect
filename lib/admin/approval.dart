import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class Approval extends StatefulWidget {
  const Approval({super.key});

  @override
  State<Approval> createState() => _ApprovalState();
}

class _ApprovalState extends State<Approval> {
  List<dynamic> requests = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> getdata() async {
    var url = "http://192.168.209.15/API/request2.php";
    try {
      final response = await http.get(Uri.parse(url));
      log('Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          var data = json.decode(response.body);

          log('Decoded JSON: $data');

          if (data['status'] == 'success') {
            setState(() {
              requests = data['requests'];
              isLoading = false;
              errorMessage = null;
            });
          } else {
            setState(() {
              errorMessage = 'Error: ${data['message'] ?? "Unknown error"}';
              isLoading = false;
            });
          }
        } else {
          setState(() {
            errorMessage = 'Error: API returned an empty response.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage =
              'Error: Server responded with status code ${response.statusCode}.';
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      log('Error fetching data: $e',
          name: 'API_ERROR', error: e, stackTrace: stackTrace);
      setState(() {
        errorMessage = 'Failed to fetch data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    var url = "http://192.168.209.15/API/request3.php";
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'Req_ID': requestId,
          'Req_stat': status,
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          log('Request $requestId updated to $status');
          setState(() {
            requests.removeWhere((request) => request['Req_ID'] == requestId);
          });
        } else {
          log('Failed to update request: ${data['message']}');
        }
      } else {
        log('Error: Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      log('Error updating request status: $e');
    }
  }

  void handleAction(String action, String requestId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm $action'),
        content: Text('Are you sure you want to $action this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              updateRequestStatus(requestId, action.toLowerCase());
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Approve/Reject Requests"),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : requests.isEmpty
                  ? const Center(
                      child: Text(
                        'No requests available.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (ctx, i) {
                        final request = requests[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: const Icon(Icons.person),
                            title: Text(
                              request['C_Name'] ?? 'Unknown Customer',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request['Req_type'] ?? 'Request Type Unknown',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      request['Helper_Name'] ??
                                          'No Helper Assigned',
                                      style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                          fontSize: 14),
                                    ),
                                    Text(
                                      request['Req_date'] ?? 'N/A',
                                      style: const TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () => handleAction(
                                      'Accepted', request['Req_ID'].toString()),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () => handleAction(
                                      'Declined', request['Req_ID'].toString()),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
