import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: Text(
            "Login Screen",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w200,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Login Screen",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 30),
            Image.asset("assets/login.png", height: 150),
            Text("Enter Username"),
            TextField(),
            SizedBox(height: 30),
            Text("Enter passord"),
            TextField(),
            SizedBox(height: 30),
            MaterialButton(
              onPressed: () {},
              color: Colors.amberAccent,
              child: Text("Login"),
            ),
          ],
        ),
      ),
    ),
  );
}
