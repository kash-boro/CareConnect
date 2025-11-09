import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../components/button.dart';
import '../components/textfield.dart';
import '../customer/registration.dart';
import '../customer/c_dashboard.dart';
import '../helper/helper_dashboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../admin/dashboard.dart';

class CustomerLogin extends StatelessWidget {
  CustomerLogin({super.key});
  final mail = TextEditingController();
  final password = TextEditingController();

  Future<void> login(BuildContext context) async {
    if (mail.text == "admin" && password.text == "1234") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminDashboard(),
        ),
      );
      return;
    }

    var url = "http://192.168.209.15/api/login.php";
    var response = await http.post(Uri.parse(url), body: {
      "email": mail.text,
      "password": password.text,
    });
    var data = json.decode(response.body);

    if (data == "customer") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerDashboard(email: mail.text),
        ),
      );
    } else if (data == "helper") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboard(email: mail.text),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: "The user and password combination doesn't exist",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
    }
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
                Text("LOGIN", style: GoogleFonts.lato(
                  fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[700]
                )),
                Image.asset("../assets/login2.jpg"),
                InputField(hint: "Email or Phone", icon: Icons.account_circle, controller: mail),
                InputField(hint: "Password or AADHAR", icon: Icons.lock, controller: password, passwordInvisible: true),
                Button(label: "LOGIN", press: () {
                  login(context);
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?", style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerRegistration()));
                      },
                      child: const Text("SIGN UP"),
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
