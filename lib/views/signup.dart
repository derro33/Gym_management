import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Full name is required";
    }
    if (value.trim().length < 3) {
      return "Name must be at least 3 characters";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return "Enter a valid email address";
    }
    return null;
  }

  String? _validatePhone(String? value) {
    // Phone is optional — only validate if something is typed
    if (value != null && value.isNotEmpty && value.length < 7) {
      return "Enter a valid phone number";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Confirm your password";
    }
    if (value != _passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final result = await ApiService.signup(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
        );

        setState(() => _isLoading = false);

        if (result['success']) {
          Get.snackbar(
            "Account Created!",
            result['message'] ?? "Signup successful",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );

          await Future.delayed(const Duration(seconds: 2));
          Get.offAllNamed("/");
        } else {
          Get.snackbar(
            "Signup Failed",
            result['message'] ?? "Something went wrong",
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
          "Could not connect to server",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Sign up to get started",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // ── Full Name ─────────────────────────────────
                TextFormField(
                  controller: _fullNameController,
                  validator: _validateFullName,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Email ─────────────────────────────────────
                TextFormField(
                  controller: _emailController,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Phone (optional) ──────────────────────────
                TextFormField(
                  controller: _phoneController,
                  validator: _validatePhone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    hintText: "Optional",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Password ──────────────────────────────────
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

                // ── Confirm Password ──────────────────────────
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  validator: _validateConfirmPassword,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ── Sign Up Button ────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 238, 142, 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleSignup,
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
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Already have account ──────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => Get.offAllNamed("/"),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
