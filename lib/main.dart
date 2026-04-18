import 'package:flutter/material.dart';
import 'package:flutter_application_1/configs/routes.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/views/login.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  // Required when using async in main
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage — must happen before runApp
  // This sets up the local storage so UserController can read/write to it
  await GetStorage.init();

  // Register UserController globally so every screen can access it via Get.find()
  Get.put(UserController());

  runApp(
    GetMaterialApp(
      initialRoute: "/",
      getPages: routes,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    ),
  );
}
