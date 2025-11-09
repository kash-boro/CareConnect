import 'package:flutter/material.dart';
import '../admin/approval.dart';
import '../admin/policy.dart';
import '../admin/review.dart';
import '../admin/helper.dart';
import '../admin/attendance.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          const CustomAppBar(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 16, // Spacing between buttons
              runSpacing: 16, // Vertical spacing for wrapping
              children: [
                DashboardButton(
                  label: 'Manage Helpers',
                  imagePath: '../assets/manage.png',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HelperScreen()),
                    );
                  },
                ),
                DashboardButton(
                  label: 'Manage Service Requests',
                  imagePath: '../assets/service.png',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Approval()),
                    );
                  },
                ),
                DashboardButton(
                  label: 'Policies',
                  imagePath: '../assets/profile.png',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UploadPolicyScreen()),
                    );
                  },
                ),
                DashboardButton(
                  label: 'Manage Customers',
                  imagePath: '../assets/customer.png',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReviewsScreen()),
                    );
                  },
                ),
                DashboardButton(
                  label: 'Attendance History',
                  imagePath: '../assets/attendance.png',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AttendanceScreen()),
                    );
                  },
                ),
                // Add more buttons as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 129, 142, 215),
            Colors.indigo[700]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Admin Panel',
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.indigo[50],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome to Admin Panel',
            style: GoogleFonts.openSans(
              fontSize: 16,
              color: Colors.indigo[100],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final String imagePath;

  const DashboardButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150, // Adjust the button width
      child: Column(
        children: [
          GestureDetector(
            onTap: onPressed,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display the image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                // Display the label
                Text(
                  label,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
