import 'package:flutter/material.dart';

class MyBookings extends StatefulWidget {
  const MyBookings({super.key});

  @override
  State<MyBookings> createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings> {
  // Hardcoded data — will be replaced with API later
  List<Map<String, dynamic>> bookings = [
    {
      "slot": "Morning Session",
      "date": "Mon, Apr 07 2026",
      "time": "6:00 AM – 8:00 AM",
      "status": "completed",
    },
    {
      "slot": "Evening Session",
      "date": "Tue, Apr 08 2026",
      "time": "5:00 PM – 7:00 PM",
      "status": "booked",
    },
    {
      "slot": "Midday Session",
      "date": "Wed, Apr 09 2026",
      "time": "11:00 AM – 1:00 PM",
      "status": "booked",
    },
    {
      "slot": "Weekend Morning",
      "date": "Sat, Apr 12 2026",
      "time": "8:00 AM – 10:00 AM",
      "status": "cancelled",
    },
    {
      "slot": "Evening Session",
      "date": "Mon, Apr 14 2026",
      "time": "5:00 PM – 7:00 PM",
      "status": "booked",
    },
  ];

  // Currently selected filter tab
  String _selectedFilter = "All";
  final List<String> _filters = ["All", "Booked", "Completed", "Cancelled"];

  // Returns filtered list based on selected tab
  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedFilter == "All") return bookings;
    return bookings
        .where(
          (b) =>
              b["status"].toString().toLowerCase() ==
              _selectedFilter.toLowerCase(),
        )
        .toList();
  }

  // Cancel a booking
  void _cancelBooking(int actualIndex) {
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              setState(() {
                bookings[actualIndex]["status"] = "cancelled";
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Booking cancelled successfully"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              "Yes, Cancel",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Status color
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

  // Status icon
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
                child: filtered.isEmpty
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
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final booking = filtered[index];
                          final String status = booking["status"];

                          // Get actual index in main bookings list
                          // so cancel works correctly
                          final int actualIndex = bookings.indexOf(booking);

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
                              child: Row(
                                children: [
                                  // Status icon circle
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _statusColor(
                                        status,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _statusIcon(status),
                                      color: _statusColor(status),
                                      size: 26,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  // Booking details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          booking["slot"],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          booking["date"],
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          booking["time"],
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Status badge + cancel button
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
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

                                      // Show cancel only for booked
                                      if (status == "booked") ...[
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () =>
                                              _cancelBooking(actualIndex),
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
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

  // ── Summary Card Widget ──────────────────────────────────────
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
