import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1/gym_api/api";

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Could not connect to server"};
    }
  }

  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/signup.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": fullName,
          "email": email,
          "phone": phone,
          "password": password,
          "role": "member",
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Could not connect to server"};
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/reset_password.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "new_password": newPassword}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Could not connect to server"};
    }
  }

  static Future<Map<String, dynamic>> getProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/profile.php?user_id=$userId"),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Could not connect to server"};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String fullName,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/user/update_profile.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "full_name": fullName,
          "phone": phone,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Could not connect to server"};
    }
  }

  static Future<Map<String, dynamic>> getBookingSummary(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/bookings/summary.php?user_id=$userId"),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Could not connect to server"};
    }
  }

  static Future<Map<String, dynamic>> getSlots() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/slots/get_all.php"));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Could not connect to server"};
    }
  }

  static Future<Map<String, dynamic>> bookSlot({
    required int userId,
    required int slotId,
    required String bookingDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/slots/book.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "slot_id": slotId,
          "booking_date": bookingDate,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Could not connect to server"};
    }
  }

  static Future<Map<String, dynamic>> getBookings(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/bookings/get_all.php?user_id=$userId"),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Could not connect to server"};
    }
  }

  static Future<Map<String, dynamic>> cancelBooking({
    required int bookingId,
    required int userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/bookings/cancel.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"booking_id": bookingId, "user_id": userId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Could not connect to server"};
    }
  }

  static Future<Map<String, dynamic>> getAttendance(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/attendance/get_all.php?user_id=$userId"),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Could not connect to server"};
    }
  }

  static Future<Map<String, dynamic>> checkIn({
    required int userId,
    required int bookingId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/attendance/checkin.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "booking_id": bookingId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Could not connect to server"};
    }
  }

  static Future<Map<String, dynamic>> checkOut({
    required int userId,
    required int bookingId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/attendance/checkout.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "booking_id": bookingId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Could not connect to server"};
    }
  }
}
