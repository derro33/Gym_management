import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  // Hardcoded data — will be replaced with API later
  final List<Map<String, dynamic>> attendanceRecords = [
    {
      "slot": "Morning Session",
      "date": "Mon, Apr 07 2026",
      "check_in": "6:05 AM",
      "check_out": "7:55 AM",
      "duration": "1h 50m",
      "status": "present",
    },
    {
      "slot": "Evening Session",
      "date": "Tue, Apr 01 2026",
      "check_in": "5:10 PM",
      "check_out": "6:50 PM",
      "duration": "1h 40m",
      "status": "present",
    },
    {
      "slot": "Midday Session",
      "date": "Wed, Mar 27 2026",
      "check_in": "11:00 AM",
      "check_out": "12:45 PM",
      "duration": "1h 45m",
      "status": "present",
    },
    {
      "slot": "Morning Session",
      "date": "Mon, Mar 24 2026",
      "check_in": "--",
      "check_out": "--",
      "duration": "--",
      "status": "absent",
    },
    {
      "slot": "Weekend Morning",
      "date": "Sat, Mar 22 2026",
      "check_in": "8:02 AM",
      "check_out": "9:58 AM",
      "duration": "1h 56m",
      "status": "present",
    },
    {
      "slot": "Evening Session",
      "date": "Thu, Mar 20 2026",
      "check_in": "--",
      "check_out": "--",
      "duration": "--",
      "status": "absent",
    },
    {
      "slot": "Midday Session",
      "date": "Wed, Mar 18 2026",
      "check_in": "11:05 AM",
      "check_out": "12:55 PM",
      "duration": "1h 50m",
      "status": "present",
    },
  ];

  String _selectedFilter = "All";
  final List<String> _filters = ["All", "Present", "Absent"];

  List<Map<String, dynamic>> get _filteredRecords {
    if (_selectedFilter == "All") return attendanceRecords;
    return attendanceRecords
        .where(
          (r) =>
              r["status"].toString().toLowerCase() ==
              _selectedFilter.toLowerCase(),
        )
        .toList();
  }

  int get _totalSessions => attendanceRecords.length;
  int get _presentCount =>
      attendanceRecords.where((r) => r["status"] == "present").length;
  int get _absentCount =>
      attendanceRecords.where((r) => r["status"] == "absent").length;
  double get _attendanceRate =>
      _totalSessions == 0 ? 0 : (_presentCount / _totalSessions) * 100;

  Color _statusColor(String status) =>
      status == "present" ? Colors.green : Colors.red;

  IconData _statusIcon(String status) =>
      status == "present" ? Icons.check_circle : Icons.cancel;

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

              // ── Attendance Rate Card ───────────────────────
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
                child: Row(
                  children: [
                    // Circular attendance rate indicator
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

                    // Stats
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Attendance Rate",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              color: Colors.white,
                              size: 10,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Total Sessions: $_totalSessions",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              color: Colors.greenAccent,
                              size: 10,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Present: $_presentCount",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              color: Colors.redAccent,
                              size: 10,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Absent: $_absentCount",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
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

              // ── Attendance Records List ────────────────────
              Expanded(
                child: filtered.isEmpty
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
                              "No ${_selectedFilter == "All" ? "" : _selectedFilter} records found",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final record = filtered[index];
                          final String status = record["status"];

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
                                  // Slot name + status badge
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            _statusIcon(status),
                                            color: _statusColor(status),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            record["slot"],
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
                                          color: _statusColor(
                                            status,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          status[0].toUpperCase() +
                                              status.substring(1),
                                          style: TextStyle(
                                            color: _statusColor(status),
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
                                        record["date"],
                                      ),
                                      _infoColumn(
                                        Icons.login,
                                        "Check In",
                                        record["check_in"],
                                      ),
                                      _infoColumn(
                                        Icons.logout,
                                        "Check Out",
                                        record["check_out"],
                                      ),
                                      _infoColumn(
                                        Icons.timer,
                                        "Duration",
                                        record["duration"],
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
            ],
          ),
        ),
      ),
    );
  }

  // ── Info Column Widget ───────────────────────────────────────
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
