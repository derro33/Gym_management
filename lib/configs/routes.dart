import 'package:flutter_application_1/views/homescreen.dart';
import 'package:flutter_application_1/views/login.dart';
import 'package:flutter_application_1/views/reset_password.dart';
import 'package:flutter_application_1/views/signup.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

var routes = [
  GetPage(name: "/", page: () => const LoginScreen()),
  GetPage(name: "/signup", page: () => const SignupScreen()),
  GetPage(name: "/homescreen", page: () => const HomeScreen()),
  GetPage(name: "/reset-password", page: () => const ResetPasswordScreen()),
];
