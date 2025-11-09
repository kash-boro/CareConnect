import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';

class BookingHistory extends StatefulWidget {
  final String email;

  const BookingHistory({super.key, required this.email});

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  List<dynamic> bookings = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> fetchBookingHistory() async {
    final url = "http://192.168.209.15/API/bhistory.php";
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'email': widget.email},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        log('Booking History Data: $data');

        if (data['status'] == 'success') {
          setState(() {
            bookings = data['bookings'];
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
          errorMessage =
              'Error: Server responded with status code ${response.statusCode}.';
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching booking history: $e');
      setState(() {
        errorMessage = 'Failed to fetch booking history: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBookingHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
        backgroundColor: Colors.indigo[700],
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
              : bookings.isEmpty
                  ? const Center(
                      child: Text(
                        'No bookings found.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                booking['S_Name'] ?? 'Unknown Service',
                                style: TextStyle(color: Colors.indigo[700]),
                              ),
                              subtitle: Text(
                                'Helper: ${booking['Helper_Name'] ?? 'N/A'}\n'
                                'Date: ${booking['Req_date'] ?? 'N/A'}\n'
                                'Status: ${booking['Req_stat'] ?? 'N/A'}',
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BookingDetailScreen(
                                      details: booking,
                                      userEmail: widget.email,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}


class BookingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> details;
  final String userEmail;

  const BookingDetailScreen(
      {super.key, required this.details, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    final TextEditingController ratingController = TextEditingController();
    final TextEditingController feedbackController = TextEditingController();

    Future<void> submitFeedback() async {
      const url = "http://192.168.209.15/API/submit_feedback.php";

      try {
        final response = await http.post(
          Uri.parse(url),
          body: {
            'email': userEmail,
            'req_id': details['Req_ID'].toString(),
            'rating': ratingController.text,
            'description': feedbackController.text,
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            Navigator.pop(context); // Close the screen after submission
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(data['message'] ?? 'Error submitting feedback')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Server Error: ${response.statusCode}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: Colors.indigo[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Details:',
              style: TextStyle(fontSize: 22, color: Colors.indigo[700]),
            ),
            const SizedBox(height: 20),
            Text(
              'Service: ${details['S_Name']}\n'
              'Helper: ${details['Helper_Name']}\n'
              'Date: ${details['Req_date']}\n'
              'Status: ${details['Req_stat']}',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ratingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Rating (1-5)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Feedback Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitFeedback,
              child: Text('Submit Feedback'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
