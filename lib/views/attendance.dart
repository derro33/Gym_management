import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/services/api_service.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<dynamic> attendanceRecords = [];
  bool _isLoading = true;
  String _selectedFilter = "All";

  // Removed "Absent" — your DB only tracks check-ins (present records)
  // Added "This Month" as a more useful filter
  final List<String> _filters = ["All", "This Month", "This Week"];

  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  void _loadAttendance() async {
    setState(() => _isLoading = true);

    final result = await ApiService.getAttendance(userController.userId);

    if (result['success']) {
      setState(() {
        attendanceRecords = List<dynamic>.from(result['records']);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      Get.snackbar(
        "Error",
        result['message'] ?? "Could not load attendance",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Filter records based on selected tab
  List<dynamic> get _filteredRecords {
    final now = DateTime.now();

    if (_selectedFilter == "This Month") {
      return attendanceRecords.where((r) {
        try {
          final date = DateTime.parse(r["date"]);
          return date.month == now.month && date.year == now.year;
        } catch (_) {
          return false;
        }
      }).toList();
    }

    if (_selectedFilter == "This Week") {
      // Get start of this week (Monday)
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final start = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );
      return attendanceRecords.where((r) {
        try {
          final date = DateTime.parse(r["date"]);
          return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
              date.isBefore(now.add(const Duration(days: 1)));
        } catch (_) {
          return false;
        }
      }).toList();
    }

    return attendanceRecords;
  }

  int get _totalSessions => attendanceRecords.length;
  int get _thisMonthCount {
    final now = DateTime.now();
    return attendanceRecords.where((r) {
      try {
        final date = DateTime.parse(r["date"]);
        return date.month == now.month && date.year == now.year;
      } catch (_) {
        return false;
      }
    }).length;
  }

  double get _attendanceRate {
    // Calculate based on how many days this month have passed
    final now = DateTime.now();
    final daysThisMonth = now.day;
    // Count working days approximately (5 per week)
    final workingDays = (daysThisMonth * 5 / 7).round();
    if (workingDays == 0) return 0;
    return (_thisMonthCount / workingDays * 100).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRecords;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────
              const Text(
                "Attendance",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Track your gym attendance history",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 16),

              // ── Stats Card ─────────────────────────────────
              Container(
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
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Row(
                        children: [
                          // Circular progress
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CircularProgressIndicator(
                                  value: _attendanceRate / 100,
                                  backgroundColor: Colors.white24,
                                  color: Colors.white,
                                  strokeWidth: 8,
                                ),
                                Center(
                                  child: Text(
                                    "${_attendanceRate.toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 20),

                          // Stats breakdown
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "This Month's Rate",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _statRow(
                                Icons.circle,
                                Colors.white,
                                "Total Sessions: $_totalSessions",
                              ),
                              const SizedBox(height: 4),
                              _statRow(
                                Icons.circle,
                                Colors.greenAccent,
                                "This Month: $_thisMonthCount",
                              ),
                              const SizedBox(height: 4),
                              _statRow(
                                Icons.circle,
                                Colors.amberAccent,
                                "This Week: ${_filteredRecords.length == attendanceRecords.length ? _getThisWeekCount() : _filteredRecords.length}",
                              ),
                            ],
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              // ── Filter Tabs ────────────────────────────────
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final bool isSelected = _selectedFilter == filter;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blueAccent : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ── Records List ───────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fact_check,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _selectedFilter == "All"
                                  ? "No attendance records yet"
                                  : "No records for $_selectedFilter",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Book and check in to a session to see records here",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadAttendance(),
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final record = filtered[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
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
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Slot name + Present badge
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              record["slot_name"] ?? "Session",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Text(
                                            "Present",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),
                                    const Divider(height: 1),
                                    const SizedBox(height: 10),

                                    // Date, check in, check out, duration
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _infoColumn(
                                          Icons.calendar_today,
                                          "Date",
                                          record["date"] ?? "-",
                                        ),
                                        _infoColumn(
                                          Icons.login,
                                          "Check In",
                                          record["check_in"] ?? "-",
                                        ),
                                        _infoColumn(
                                          Icons.logout,
                                          "Check Out",
                                          record["check_out"] ?? "Pending",
                                        ),
                                        _infoColumn(
                                          Icons.timer,
                                          "Duration",
                                          record["duration"] ?? "-",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper: This week count ──────────────────────────────────
  int _getThisWeekCount() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    return attendanceRecords.where((r) {
      try {
        final date = DateTime.parse(r["date"]);
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(now.add(const Duration(days: 1)));
      } catch (_) {
        return false;
      }
    }).length;
  }

  // ── Stat row inside card ─────────────────────────────────────
  Widget _statRow(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 10),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }

  // ── Info column inside record card ───────────────────────────
  Widget _infoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.blueAccent),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
