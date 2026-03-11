import 'package:flutter_application_1/views/homescreen.dart';
import 'package:flutter_application_1/views/login.dart';
import 'package:flutter_application_1/views/signup.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

var routes=[
  GetPage(name: "/",page:()=>LoginScreen()),
  GetPage(name: "/signup",page:()=>SignupScreen()),
  GetPage(name: "/homescreen",page:()=>HomeScreen()),
];