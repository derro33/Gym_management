import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/services/api_service.dart';

class GymSlots extends StatefulWidget {
  const GymSlots({super.key});

  @override
  State<GymSlots> createState() => _GymSlotsState();
}

class _GymSlotsState extends State<GymSlots> {
  List<dynamic> slots = [];
  bool _isLoading = true;
  int? _bookingIndex;

  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  void _loadSlots() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getSlots();
    if (result['success']) {
      setState(() {
        slots = result['slots'];
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

  void _handleBooking(int index) async {
    setState(() => _bookingIndex = index);

    final slot = slots[index];
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final bookingDate =
        "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";

    final result = await ApiService.bookSlot(
      userId: userController.userId,
      slotId: int.parse(slot['id'].toString()),
      bookingDate: bookingDate,
    );

    setState(() => _bookingIndex = null);

    if (result['success']) {
      _showSuccessDialog(slot['slot_name']);
    } else {
      Get.snackbar(
        "Booking Failed",
        result['message'],
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
          "You have successfully booked\n\"$slotName\".",
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
              onPressed: () {
                Navigator.pop(context);
                // Reload slots to update capacity bar
                _loadSlots();
              },
              child: const Text("Okay", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Color _capacityColor(int capacity, int booked) {
    if (capacity == 0) return Colors.green;
    final double percentage = booked / capacity;
    if (percentage >= 1.0) return Colors.red;
    if (percentage >= 0.7) return Colors.orange;
    return Colors.green;
  }

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
              const Text(
                "Gym Slots",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Browse and book an available session",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : slots.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "No slots available",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadSlots(),
                        child: ListView.builder(
                          itemCount: slots.length,
                          itemBuilder: (context, index) {
                            final slot = slots[index];
                            final int capacity =
                                int.tryParse(slot['max_capacity'].toString()) ??
                                0;
                            // Use real booked_count from API
                            final int booked =
                                int.tryParse(slot['booked_count'].toString()) ??
                                0;
                            final bool isBooking = _bookingIndex == index;
                            final bool isFull = booked >= capacity;
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          slot['slot_name'],
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
                                            color: capacityColor.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                                          "${slot['start_time']} – ${slot['end_time']}",
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
                                          slot['available_days'],
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Real capacity progress bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: capacity > 0
                                            ? (booked / capacity).clamp(
                                                0.0,
                                                1.0,
                                              )
                                            : 0,
                                        backgroundColor: Colors.grey.shade200,
                                        color: capacityColor,
                                        minHeight: 8,
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    // Book button — disabled if full
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isFull
                                              ? Colors.grey.shade300
                                              : Colors.blueAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed: isBooking || isFull
                                            ? null
                                            : () => _handleBooking(index),
                                        child: isBooking
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                              )
                                            : Text(
                                                isFull
                                                    ? "Slot Full"
                                                    : "Book Slot",
                                                style: TextStyle(
                                                  color: isFull
                                                      ? Colors.grey.shade600
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
