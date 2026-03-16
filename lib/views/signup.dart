import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class  SignupScreen extends StatefulWidget {
  const  SignupScreen({super.key});

  @override
  State< SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State< SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset("assets/login.png", height: 200, width: 200),

              Text(
                "Signup",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),

              SizedBox(height: 30),

              Row(
                children: [
                  Text(
                    "Full Name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),

              SizedBox(height: 10),

              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: "Enter your full name",
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              SizedBox(height: 20),

              Row(
                children: [
                  Text(
                    "Email or Phone",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),

              SizedBox(height: 10),

              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: "Enter email or phone",
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              SizedBox(height: 20),

              Row(
                children: [
                  Text(
                    "Password",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),

              SizedBox(height: 10),

              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: "Enter password",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: Icon(Icons.visibility_off),
                ),
              ),

              SizedBox(height: 20),

              Row(
                children: [
                  Text(
                    "Confirm Password",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),

              SizedBox(height: 10),

              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: "Confirm password",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: Icon(Icons.visibility_off),
                ),
              ),

              SizedBox(height: 30),

              Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 238, 142, 8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Signup",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),

              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Text("Login", style: TextStyle(color: Colors.amber)),
                  ),
                
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}