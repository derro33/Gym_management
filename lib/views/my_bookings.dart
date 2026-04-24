import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/services/api_service.dart';

class MyBookings extends StatefulWidget {
  const MyBookings({super.key});

  @override
  State<MyBookings> createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings> {
  List<dynamic> bookings = [];
  bool _isLoading = true;
  String _selectedFilter = "All";
  final List<String> _filters = ["All", "Booked", "Completed", "Cancelled"];

  // Track which booking is currently being checked in
  int? _checkingInBookingId;

  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() async {
    setState(() => _isLoading = true);

    final result = await ApiService.getBookings(userController.userId);

    if (result['success']) {
      setState(() {
        bookings = result['bookings'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      Get.snackbar(
        "Error",
        result['message'],
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ── Check In ─────────────────────────────────────────────────
  void _handleCheckIn(int bookingId) async {
    setState(() => _checkingInBookingId = bookingId);

    final result = await ApiService.checkIn(
      userId: userController.userId,
      bookingId: bookingId,
    );

    setState(() => _checkingInBookingId = null);

    if (result['success']) {
      // Reload so the button disappears and status updates
      _loadBookings();
      Get.snackbar(
        "Checked In!",
        "Your attendance has been recorded successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } else {
      Get.snackbar(
        "Check In Failed",
        result['message'],
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ── Cancel Booking ───────────────────────────────────────────
  void _cancelBooking(int bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Cancel Booking",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to cancel this booking?"),
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
                  child: const Text("No", style: TextStyle(color: Colors.grey)),
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
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await ApiService.cancelBooking(
                      bookingId: bookingId,
                      userId: userController.userId,
                    );
                    if (result['success']) {
                      _loadBookings();
                      Get.snackbar(
                        "Cancelled",
                        "Booking cancelled successfully",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    } else {
                      Get.snackbar(
                        "Error",
                        result['message'],
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: const Text(
                    "Yes, Cancel",
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

  List<dynamic> get _filteredBookings {
    if (_selectedFilter == "All") return bookings;
    return bookings
        .where(
          (b) =>
              b["status"].toString().toLowerCase() ==
              _selectedFilter.toLowerCase(),
        )
        .toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case "booked":
        return Colors.blue;
      case "completed":
        return Colors.green;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "booked":
        return Icons.calendar_month;
      case "completed":
        return Icons.check_circle;
      case "cancelled":
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBookings;

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
                "My Bookings",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Track and manage your gym sessions",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 16),

              // ── Summary Row ────────────────────────────────
              Row(
                children: [
                  _summaryCard(
                    "Total",
                    bookings.length.toString(),
                    Colors.blueAccent,
                    Icons.list_alt,
                  ),
                  const SizedBox(width: 10),
                  _summaryCard(
                    "Booked",
                    bookings
                        .where((b) => b["status"] == "booked")
                        .length
                        .toString(),
                    Colors.blue,
                    Icons.calendar_month,
                  ),
                  const SizedBox(width: 10),
                  _summaryCard(
                    "Done",
                    bookings
                        .where((b) => b["status"] == "completed")
                        .length
                        .toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                  const SizedBox(width: 10),
                  _summaryCard(
                    "Cancelled",
                    bookings
                        .where((b) => b["status"] == "cancelled")
                        .length
                        .toString(),
                    Colors.red,
                    Icons.cancel,
                  ),
                ],
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

              // ── Bookings List ──────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "No ${_selectedFilter == "All" ? "" : _selectedFilter} bookings found",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadBookings(),
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final booking = filtered[index];
                            final String status = booking["status"];
                            final int bookingId = int.parse(
                              booking["id"].toString(),
                            );
                            // null means not checked in yet
                            final bool isCheckedIn =
                                booking["attendance_id"] != null;
                            final bool isCheckingIn =
                                _checkingInBookingId == bookingId;

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
                                    // Top row: icon + details + status
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: _statusColor(
                                              status,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            _statusIcon(status),
                                            color: _statusColor(status),
                                            size: 26,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                booking["slot_name"],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                booking["booking_date"],
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                "${booking["start_time"]} – ${booking["end_time"]}",
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Status badge
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

                                    // Bottom row: Check In + Cancel buttons
                                    // Only show for booked status
                                    if (status == "booked") ...[
                                      const SizedBox(height: 12),
                                      const Divider(height: 1),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          // Check In button
                                          Expanded(
                                            child: SizedBox(
                                              height: 38,
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isCheckedIn
                                                      ? Colors.green.shade50
                                                      : Colors.green,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                onPressed:
                                                    isCheckedIn || isCheckingIn
                                                    ? null
                                                    : () => _handleCheckIn(
                                                        bookingId,
                                                      ),
                                                icon: isCheckingIn
                                                    ? const SizedBox(
                                                        height: 16,
                                                        width: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                              strokeWidth: 2,
                                                            ),
                                                      )
                                                    : Icon(
                                                        isCheckedIn
                                                            ? Icons.check_circle
                                                            : Icons.login,
                                                        color: isCheckedIn
                                                            ? Colors.green
                                                            : Colors.white,
                                                        size: 16,
                                                      ),
                                                label: Text(
                                                  isCheckedIn
                                                      ? "Checked In"
                                                      : isCheckingIn
                                                      ? "Checking in..."
                                                      : "Check In",
                                                  style: TextStyle(
                                                    color: isCheckedIn
                                                        ? Colors.green
                                                        : Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          // Cancel button
                                          Expanded(
                                            child: SizedBox(
                                              height: 38,
                                              child: OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(
                                                    color: Colors.red.shade300,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: isCheckedIn
                                                    ? null
                                                    : () => _cancelBooking(
                                                        bookingId,
                                                      ),
                                                icon: Icon(
                                                  Icons.cancel,
                                                  color: isCheckedIn
                                                      ? Colors.grey
                                                      : Colors.red.shade400,
                                                  size: 16,
                                                ),
                                                label: Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                    color: isCheckedIn
                                                        ? Colors.grey
                                                        : Colors.red.shade400,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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

  Widget _summaryCard(String label, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
