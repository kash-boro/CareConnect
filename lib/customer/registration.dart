import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app1/login_screen/customer_login.dart';
import '../components/button.dart';
import '../components/textfield.dart';
import '../customer/c_dashboard.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomerRegistration extends StatefulWidget {
  const CustomerRegistration({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CustomerRegistrationState createState() => _CustomerRegistrationState();
}

class _CustomerRegistrationState extends State<CustomerRegistration> {
  final TextEditingController email = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController addr = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  Future<void> insert() async {
    if (name.text.isEmpty || email.text.isEmpty || phone.text.isEmpty || dob.text.isEmpty || addr.text.isEmpty || password.text.isEmpty || confirmPassword.text.isEmpty) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'All fields are required!',
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    if (password.text != confirmPassword.text) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Passwords do not match!',
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    try {
      var url = Uri.parse("http://192.168.209.15/API/adddata.php");
      var response = await http.post(url, body: {
        "name": name.text,
        "mail": email.text,
        "dob": dob.text,
        "phone": phone.text,
        "addr": addr.text,
        "password": password.text,
      });

      var data = json.decode(response.body);

      if (data == "error") {
        Fluttertoast.showToast(
          backgroundColor: const Color.fromARGB(255, 248, 33, 33),
          textColor: Colors.white,
          msg: 'User already exists!',
          toastLength: Toast.LENGTH_SHORT,
        );
      } else if (data == "success") {
        Fluttertoast.showToast(
          backgroundColor: const Color.fromARGB(255, 53, 67, 255),
          textColor: Colors.white,
          msg: 'Registration Successful!',
          toastLength: Toast.LENGTH_SHORT,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerDashboard(email: ''),
          ),
        );
      } else {
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: 'Registration failed!',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Register New Account",
                    style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 55,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InputField(hint: "Full name", icon: Icons.person, controller: name),
                InputField(hint: "Email", icon: Icons.email, controller: email),
                InputField(hint: "Phone", icon: Icons.phone, controller: phone),
                InputField(hint: "Address", icon: Icons.home, controller: addr),
                InputField(
                  hint: "Date of Birth (YYYY-MM-DD)",
                  icon: Icons.calendar_month_rounded,
                  controller: dob,
                ),
                InputField(
                  hint: "Password",
                  icon: Icons.lock,
                  controller: password,
                  passwordInvisible: true,
                ),
                InputField(
                  hint: "Re-enter password",
                  icon: Icons.lock,
                  controller: confirmPassword,
                  passwordInvisible: true,
                ),
                const SizedBox(height: 10),
                Button(
                  label: "SIGN UP",
                  press: () {
                    insert();
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?", style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CustomerLogin()),
                        );
                      },
                      child: const Text("LOGIN"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
