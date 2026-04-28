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
  int? _checkingInBookingId;
  int? _checkingOutBookingId;
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

  void _handleCheckIn(int bookingId) async {
    setState(() => _checkingInBookingId = bookingId);
    final result = await ApiService.checkIn(
      userId: userController.userId,
      bookingId: bookingId,
    );
    setState(() => _checkingInBookingId = null);
    if (result['success']) {
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

  void _handleCheckOut(int bookingId, String slotName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.logout, color: Colors.orange, size: 44),
        title: const Text(
          "Complete Session?",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you done with your \"$slotName\" session?\n\nThis will mark the session as completed.",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          _dialogButtons(
            onNo: () => Navigator.pop(context),
            onYes: () async {
              Navigator.pop(context);
              await _confirmCheckOut(bookingId);
            },
            noLabel: "Not Yet",
            yesLabel: "Yes, Done!",
            yesColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCheckOut(int bookingId) async {
    setState(() => _checkingOutBookingId = bookingId);
    final result = await ApiService.checkOut(
      userId: userController.userId,
      bookingId: bookingId,
    );
    setState(() => _checkingOutBookingId = null);
    if (result['success']) {
      _loadBookings();
      Get.snackbar(
        "Session Completed!",
        "Great work! Your session has been recorded.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.fitness_center, color: Colors.white),
      );
    } else {
      Get.snackbar(
        "Checkout Failed",
        result['message'],
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

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
          _dialogButtons(
            onNo: () => Navigator.pop(context),
            onYes: () async {
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
            noLabel: "No",
            yesLabel: "Yes, Cancel",
            yesColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _dialogButtons({
    required VoidCallback onNo,
    required VoidCallback onYes,
    required String noLabel,
    required String yesLabel,
    required Color yesColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onNo,
            child: Text(noLabel, style: const TextStyle(color: Colors.grey)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: yesColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onYes,
            child: Text(yesLabel, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
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

  Widget _buildFilterTabs() {
    return SizedBox(
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
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
    );
  }

  Widget _actionButton({
    required String label,
    required IconData? icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
    required bool outlined,
    bool fullWidth = false,
  }) {
    final child = isLoading
        ? SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              color: outlined ? color : Colors.white,
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: outlined ? color : Colors.white, size: 16),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: outlined ? color : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 38,
      child: outlined
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color.withOpacity(0.6)),
                shape: shape,
              ),
              onPressed: isLoading ? null : onPressed,
              child: child,
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: shape,
                elevation: 0,
              ),
              onPressed: isLoading ? null : onPressed,
              child: child,
            ),
    );
  }

  Widget _buildBookingCard(Map booking) {
    final String status = booking["status"];
    final int bookingId = int.parse(booking["id"].toString());
    final String slotName = booking["slot_name"] ?? "Session";
    final bool isCheckedIn = booking["attendance_id"] != null;
    final bool isCheckedOut = booking["checked_out_at"] != null;
    final bool isCheckingIn = _checkingInBookingId == bookingId;
    final bool isCheckingOut = _checkingOutBookingId == bookingId;

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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slotName,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (status == "booked") ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              if (!isCheckedIn)
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        label: isCheckingIn ? "Checking in..." : "Check In",
                        icon: isCheckingIn ? null : Icons.login,
                        color: Colors.green,
                        isLoading: isCheckingIn,
                        onPressed: () => _handleCheckIn(bookingId),
                        outlined: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionButton(
                        label: "Cancel",
                        icon: Icons.cancel,
                        color: Colors.red,
                        isLoading: false,
                        onPressed: () => _cancelBooking(bookingId),
                        outlined: true,
                      ),
                    ),
                  ],
                )
              else if (!isCheckedOut)
                _actionButton(
                  label: isCheckingOut ? "Checking out..." : "Check Out",
                  icon: isCheckingOut ? null : Icons.logout,
                  color: Colors.orange,
                  isLoading: isCheckingOut,
                  onPressed: () => _handleCheckOut(bookingId, slotName),
                  outlined: false,
                  fullWidth: true,
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "Session completed — awaiting status update",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
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
              const Text(
                "My Bookings",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Track and manage your gym sessions",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
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
              _buildFilterTabs(),
              const SizedBox(height: 16),
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
                          itemBuilder: (context, index) =>
                              _buildBookingCard(filtered[index]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
