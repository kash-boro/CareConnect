import 'package:flutter/material.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data; in a real app, fetch data from an API
    List<Map<String, String>> reviews = [
      {"user": "User1", "review": "Great service!"},
      {"user": "User2", "review": "Could be better."},
      {"user": "User3", "review": "Very satisfied!"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("User Reviews")),
      body: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(reviews[index]["user"]!),
              subtitle: Text(reviews[index]["review"]!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      // Approve action
                      // Integrate with API to approve the review
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      // Reject action
                      // Integrate with API to reject the review
                    },
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
