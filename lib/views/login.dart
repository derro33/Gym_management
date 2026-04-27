import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Username is required";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!emailRegex.hasMatch(value) && !phoneRegex.hasMatch(value)) {
      return "Enter a valid email or phone number";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        final userController = Get.find<UserController>();
        userController.saveUser(result['user']);
        Get.offAllNamed("/homescreen");
      } else {
        Get.snackbar(
          "Login Failed",
          result['message'] ?? "Invalid credentials",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        "Error",
        "Could not connect to server. Check your connection.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: Container(
        height: 50,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isLoading
              ? Colors.orange.shade200
              : const Color.fromARGB(255, 238, 142, 8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                "Login",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
      ),
    );
  }

  Widget _buildBottomLinks() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Text("Don't have an account?"),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () => Get.toNamed("/signup"),
            child: const Text("Signup", style: TextStyle(color: Colors.amber)),
          ),
          const Spacer(),
          const Text("Forgot password?"),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () => Get.toNamed("/reset-password"),
            child: const Text(
              "Reset password",
              style: TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset("assets/image.png", height: 200, width: 200),
                const Text(
                  "Login Screen",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Enter Username",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _usernameController,
                  validator: _validateUsername,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    hintText: "Use email or phone number",
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Enter password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  validator: _validatePassword,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    hintText: "Pin or Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLoginButton(),
                _buildBottomLinks(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
