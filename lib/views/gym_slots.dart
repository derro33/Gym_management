import 'package:flutter/material.dart';

class GymSlots extends StatefulWidget {
  const GymSlots({super.key});

  @override
  State<GymSlots> createState() => _GymSlotsState();
}

class _GymSlotsState extends State<GymSlots> {
  // Hardcoded data — will be replaced with API later
  final List<Map<String, dynamic>> slots = [
    {
      "name": "Morning Session",
      "start_time": "6:00 AM",
      "end_time": "8:00 AM",
      "days": "Mon, Tue, Wed, Thu, Fri",
      "capacity": 15,
      "booked": 3,
    },
    {
      "name": "Midday Session",
      "start_time": "11:00 AM",
      "end_time": "1:00 PM",
      "days": "Mon, Wed, Fri",
      "capacity": 10,
      "booked": 7,
    },
    {
      "name": "Evening Session",
      "start_time": "5:00 PM",
      "end_time": "7:00 PM",
      "days": "Mon, Tue, Wed, Thu, Fri",
      "capacity": 20,
      "booked": 10,
    },
    {
      "name": "Weekend Morning",
      "start_time": "8:00 AM",
      "end_time": "10:00 AM",
      "days": "Sat, Sun",
      "capacity": 12,
      "booked": 12, // full
    },
    {
      "name": "Weekend Evening",
      "start_time": "4:00 PM",
      "end_time": "6:00 PM",
      "days": "Sat, Sun",
      "capacity": 10,
      "booked": 2,
    },
  ];

  // Tracks which slot is being booked (for loading state)
  int? _bookingIndex;

  void _handleBooking(int index) async {
    final slot = slots[index];
    final int available = slot["capacity"] - slot["booked"];

    if (available <= 0) return; // shouldn't reach here but safety check

    setState(() => _bookingIndex = index);

    // Simulate API call — replace with real booking logic later
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      slots[index]["booked"] += 1;
      _bookingIndex = null;
    });

    _showSuccessDialog(slot["name"]);
  }

  void _showSuccessDialog(String slotName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
        title: const Text(
          "Booking Confirmed!",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "You have successfully booked the\n\"$slotName\".",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Okay", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // Returns color based on how full the slot is
  Color _capacityColor(int capacity, int booked) {
    final double percentage = booked / capacity;
    if (percentage >= 1.0) return Colors.red;
    if (percentage >= 0.7) return Colors.orange;
    return Colors.green;
  }

  // Returns capacity label text
  String _capacityLabel(int capacity, int booked) {
    final int available = capacity - booked;
    if (available <= 0) return "Full";
    return "$available/$capacity slots left";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────
              const Text(
                "Gym Slots",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Browse and book an available session",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // ── Slot Cards ───────────────────────────────────
              Expanded(
                child: ListView.builder(
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final int capacity = slot["capacity"];
                    final int booked = slot["booked"];
                    final int available = capacity - booked;
                    final bool isFull = available <= 0;
                    final bool isBooking = _bookingIndex == index;
                    final Color capacityColor = _capacityColor(
                      capacity,
                      booked,
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                            // Slot name + capacity badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  slot["name"],
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: capacityColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _capacityLabel(capacity, booked),
                                    style: TextStyle(
                                      color: capacityColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Time
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "${slot["start_time"]} – ${slot["end_time"]}",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Days
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  slot["days"],
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Capacity progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: booked / capacity,
                                backgroundColor: Colors.grey.shade200,
                                color: capacityColor,
                                minHeight: 8,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Book button
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFull
                                      ? Colors.grey.shade300
                                      : Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: isFull || isBooking
                                    ? null
                                    : () => _handleBooking(index),
                                child: isBooking
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        isFull ? "Slot Full" : "Book Slot",
                                        style: TextStyle(
                                          color: isFull
                                              ? Colors.grey
                                              : Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                              ),
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
}
