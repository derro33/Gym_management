import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final userController = Get.find<UserController>();

  Map<String, dynamic> profileData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    setState(() => _isLoading = true);

    final result = await ApiService.getProfile(userController.userId);

    if (result['success']) {
      setState(() {
        profileData = Map<String, dynamic>.from(result['user']);
        _isLoading = false;
      });
    } else {
      // If API fails, fall back to session data so screen is not blank
      setState(() {
        profileData = {
          'full_name': userController.fullName,
          'email': userController.email,
          'phone': '',
          'role': userController.role,
          'total_sessions': 0,
          'sessions_attended': 0,
          'membership_type': 'Basic',
          'trainer_name': 'Not assigned',
          'start_date': '-',
          'end_date': '-',
        };
        _isLoading = false;
      });
      Get.snackbar(
        "Notice",
        "Could not load full profile. Showing basic info.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.logout, color: Colors.red, size: 40),
        title: const Text(
          "Logout",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to logout?",
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    userController.clearUser();
                    Get.offAllNamed("/");
                  },
                  child: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _membershipColor(String type) {
    switch (type.toLowerCase()) {
      case "premium":
        return Colors.amber.shade700;
      case "standard":
        return Colors.blueAccent;
      case "admin":
        return Colors.purple;
      case "trainer":
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String fullName =
        profileData['full_name']?.toString() ?? userController.fullName;
    final String email =
        profileData['email']?.toString() ?? userController.email;
    final String phone = profileData['phone']?.toString() ?? '';
    final String membership =
        profileData['membership_type']?.toString() ?? 'Basic';
    final String trainer =
        profileData['trainer_name']?.toString() ?? 'Not assigned';
    final String startDate = profileData['start_date']?.toString() ?? '-';
    final String endDate = profileData['end_date']?.toString() ?? '-';
    final int totalSessions =
        int.tryParse(profileData['total_sessions']?.toString() ?? '0') ?? 0;
    final int attended =
        int.tryParse(profileData['sessions_attended']?.toString() ?? '0') ?? 0;
    final double attendanceRate = totalSessions == 0
        ? 0
        : (attended / totalSessions) * 100;

    // initials for avatar
    final String initials = fullName.trim().isNotEmpty
        ? fullName
              .trim()
              .split(" ")
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : "?";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────
                const Text(
                  "My Profile",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Manage your account details",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // ── Profile Card ─────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _membershipColor(membership),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "$membership Member",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Stats Row ─────────────────────────────────
                Row(
                  children: [
                    _statCard(
                      "Total Sessions",
                      totalSessions.toString(),
                      Icons.fitness_center,
                      Colors.blueAccent,
                    ),
                    const SizedBox(width: 10),
                    _statCard(
                      "Attended",
                      attended.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    const SizedBox(width: 10),
                    _statCard(
                      "Rate",
                      "${attendanceRate.toStringAsFixed(0)}%",
                      Icons.bar_chart,
                      Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Account Info ──────────────────────────────
                const Text(
                  "Account Info",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _infoTile(Icons.person, "Full Name", fullName),
                      _divider(),
                      _infoTile(Icons.email, "Email", email),
                      _divider(),
                      _infoTile(
                        Icons.phone,
                        "Phone",
                        phone.isNotEmpty ? phone : "Not provided",
                      ),
                      _divider(),
                      _infoTile(Icons.fitness_center, "Trainer", trainer),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Membership Info ───────────────────────────
                const Text(
                  "Membership Info",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _infoTile(Icons.star, "Membership Type", membership),
                      _divider(),
                      _infoTile(
                        Icons.calendar_today,
                        "Member Since",
                        startDate,
                      ),
                      _divider(),
                      _infoTile(Icons.event, "End Date", endDate),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Logout Button ─────────────────────────────
                GestureDetector(
                  onTap: _handleLogout,
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.red.shade400),
                        const SizedBox(width: 8),
                        Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, indent: 52, color: Colors.grey.shade200);

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
