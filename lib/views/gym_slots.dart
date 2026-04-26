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

  // Each slot gets a gradient based on its index
  final List<List<Color>> _gradients = [
    [Color(0xFF1565C0), Color(0xFF42A5F5)], // blue
    [Color(0xFF6A1B9A), Color(0xFFAB47BC)], // purple
    [Color(0xFF00695C), Color(0xFF26A69A)], // teal
    [Color(0xFFE65100), Color(0xFFFFA726)], // orange
    [Color(0xFF283593), Color(0xFF5C6BC0)], // indigo
  ];

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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 56),
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
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                _loadSlots();
              },
              child: const Text("Okay",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Color _capacityColor(int capacity, int booked) {
    if (capacity == 0) return Colors.green;
    final double pct = booked / capacity;
    if (pct >= 1.0) return Colors.red;
    if (pct >= 0.7) return Colors.orange;
    return Colors.greenAccent;
  }

  String _capacityLabel(int capacity, int booked) {
    final int available = capacity - booked;
    if (available <= 0) return "Full";
    return "$available left";
  }

  // Get gradient for each card based on index
  List<Color> _getGradient(int index) {
    return _gradients[index % _gradients.length];
  }

  // Split available days into a list for chips
  List<String> _parseDays(String days) {
    return days.split(',').map((d) => d.trim()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Gym Slots",
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Browse and book an available session",
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // ── Slots count chip ─────────────────────────────
            if (!_isLoading && slots.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${slots.length} sessions available",
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

            // ── Slots list ───────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : slots.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fitness_center,
                                  size: 60,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                "No slots available",
                                style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async => _loadSlots(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                16, 0, 16, 16),
                            itemCount: slots.length,
                            itemBuilder: (context, index) {
                              final slot = slots[index];
                              final int capacity = int.tryParse(
                                      slot['max_capacity'].toString()) ??
                                  0;
                              final int booked = int.tryParse(
                                      slot['booked_count'].toString()) ??
                                  0;
                              final bool isBooking =
                                  _bookingIndex == index;
                              final bool isFull = booked >= capacity;
                              final Color capacityColor =
                                  _capacityColor(capacity, booked);
                              final List<Color> gradient =
                                  _getGradient(index);
                              final List<String> days =
                                  _parseDays(
                                      slot['available_days'] ?? '');

                              return Container(
                                margin:
                                    const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: gradient[0]
                                          .withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [

                                    // ── Gradient header ───────
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: gradient,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Slot icon
                                          Container(
                                            padding:
                                                const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12),
                                            ),
                                            child: const Icon(
                                              Icons.fitness_center,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          // Slot name + time
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(
                                                  slot['slot_name'],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.access_time,
                                                      color: Colors
                                                          .white70,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(
                                                        width: 4),
                                                    Text(
                                                      "${slot['start_time']} – ${slot['end_time']}",
                                                      style:
                                                          const TextStyle(
                                                        color:
                                                            Colors.white70,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Capacity badge
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isFull
                                                      ? Icons.block
                                                      : Icons.people,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isFull
                                                      ? "Full"
                                                      : _capacityLabel(
                                                          capacity,
                                                          booked),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // ── Card body ─────────────
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [

                                          // Capacity progress bar
                                          Row(
                                            children: [
                                              Icon(Icons.people_outline,
                                                  size: 14,
                                                  color:
                                                      Colors.grey.shade500),
                                              const SizedBox(width: 6),
                                              Text(
                                                "$booked/$capacity booked",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      Colors.grey.shade500,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                isFull
                                                    ? "Slot Full"
                                                    : "${capacity - booked} spots remaining",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: capacityColor,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 8),

                                          // Progress bar
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child:
                                                LinearProgressIndicator(
                                              value: capacity > 0
                                                  ? (booked / capacity)
                                                      .clamp(0.0, 1.0)
                                                  : 0,
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              color: capacityColor,
                                              minHeight: 8,
                                            ),
                                          ),

                                          const SizedBox(height: 14),

                                          // Available days + Book button
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [

                                              // Days section
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .calendar_month,
                                                          size: 14,
                                                          color: gradient[0],
                                                        ),
                                                        const SizedBox(
                                                            width: 6),
                                                        Text(
                                                          "Available days",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey
                                                                .shade500,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                        height: 6),
                                                    // Day chips
                                                    Wrap(
                                                      spacing: 4,
                                                      runSpacing: 4,
                                                      children:
                                                          days.map((day) {
                                                        return Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 8,
                                                            vertical: 3,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: gradient[0]
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Text(
                                                            day,
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color:
                                                                  gradient[0],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              const SizedBox(width: 12),

                                              // Book button — small,
                                              // on the right
                                              GestureDetector(
                                                onTap: isBooking || isFull
                                                    ? null
                                                    : () =>
                                                        _handleBooking(
                                                            index),
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 18,
                                                    vertical: 12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient: isFull
                                                        ? null
                                                        : LinearGradient(
                                                            colors: isBooking
                                                                ? [
                                                                    gradient[0]
                                                                        .withOpacity(
                                                                            0.5),
                                                                    gradient[1]
                                                                        .withOpacity(
                                                                            0.5),
                                                                  ]
                                                                : gradient,
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                    color: isFull
                                                        ? Colors.grey.shade200
                                                        : null,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                    boxShadow: isFull
                                                        ? []
                                                        : [
                                                            BoxShadow(
                                                              color: gradient[
                                                                      0]
                                                                  .withOpacity(
                                                                      0.3),
                                                              blurRadius: 8,
                                                              offset:
                                                                  const Offset(
                                                                      0, 4),
                                                            ),
                                                          ],
                                                  ),
                                                  child: isBooking
                                                      ? const SizedBox(
                                                          height: 18,
                                                          width: 18,
                                                          child:
                                                              CircularProgressIndicator(
                                                            color:
                                                                Colors.white,
                                                            strokeWidth: 2,
                                                          ),
                                                        )
                                                      : Text(
                                                          isFull
                                                              ? "Full"
                                                              : "Book",
                                                          style: TextStyle(
                                                            color: isFull
                                                                ? Colors.grey
                                                                    .shade500
                                                                : Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}