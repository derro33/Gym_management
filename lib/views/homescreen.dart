import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/views/attendance.dart';
import 'package:flutter_application_1/views/gym_slots.dart';
import 'package:flutter_application_1/views/my_bookings.dart';
import 'package:flutter_application_1/views/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const DashboardPage(),
    const GymSlots(),
    const MyBookings(),
    const AttendancePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.blueAccent,
        animationDuration: const Duration(milliseconds: 300),
        index: currentIndex,
        items: const <Widget>[
          Icon(Icons.dashboard, size: 30, color: Colors.white),
          Icon(Icons.fitness_center, size: 30, color: Colors.white),
          Icon(Icons.calendar_month, size: 30, color: Colors.white),
          Icon(Icons.fact_check, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final userController = Get.find<UserController>();

  List<dynamic> availableSlots = [];
  Map<String, dynamic>? upcomingBooking;
  bool _isLoading = true;

  final List<String> quickTips = [
    "💧 Stay hydrated — drink water before and after your session",
    "📅 Book your slot at least a day in advance",
    "👟 Wear proper gym shoes to avoid injuries",
    "🕐 Arrive 5 minutes early to warm up",
    "🚫 Maximum 1 booking per slot per day",
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() async {
    setState(() => _isLoading = true);

    final slotsResult = await ApiService.getSlots();
    final bookingsResult = await ApiService.getBookings(userController.userId);

    if (slotsResult['success']) {
      availableSlots = List<dynamic>.from(slotsResult['slots']);
    }

    if (bookingsResult['success']) {
      final allBookings = List<dynamic>.from(bookingsResult['bookings']);
      final booked = allBookings.where((b) => b['status'] == 'booked').toList();
      upcomingBooking = booked.isNotEmpty
          ? Map<String, dynamic>.from(booked.first)
          : null;
    }

    setState(() => _isLoading = false);
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "?";
    return name
        .trim()
        .split(" ")
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  Widget _buildGreeting(String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back 👋",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            Text(
              userName.isNotEmpty ? userName : "Member",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blueAccent,
          child: Text(
            _getInitials(userName),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Row(
              children: [
                const Icon(Icons.fitness_center, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Bookings",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      upcomingBooking != null
                          ? "Active Session Booked"
                          : "No upcoming sessions",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildUpcomingBooking() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (upcomingBooking == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueAccent.shade100),
        ),
        child: const Center(
          child: Text(
            "No upcoming bookings.\nGo to Gym Slots to book a session!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade50,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: Colors.blueAccent,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                upcomingBooking!["slot_name"] ?? "-",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                upcomingBooking!["booking_date"] ?? "-",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              Text(
                "${upcomingBooking!["start_time"] ?? ""} – ${upcomingBooking!["end_time"] ?? ""}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Confirmed",
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(Map slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slot["slot_name"] ?? "-",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Text(
                "${slot["start_time"]} – ${slot["end_time"]}",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Text(
            slot["available_days"] ?? "",
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: quickTips
            .map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  tip,
                  style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String userName = userController.fullName;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(userName),
                const SizedBox(height: 20),
                _buildStatsCard(),
                const SizedBox(height: 20),
                const Text(
                  "Upcoming Booking",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildUpcomingBooking(),
                const SizedBox(height: 20),
                const Text(
                  "Available Slots",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (availableSlots.isEmpty)
                  const Center(
                    child: Text(
                      "No slots available",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  Column(
                    children: availableSlots
                        .map((slot) => _buildSlotCard(slot))
                        .toList(),
                  ),
                const SizedBox(height: 20),
                const Text(
                  "Quick Tips",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildQuickTips(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
