// lib/screens/tabs/dashboard_tab.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/task_model.dart';
import '../../data/customer_database.dart';
import '../../data/task_database.dart';
import '../../models/customer_measurement.dart';
import '../create_task_screen.dart';
import '../add_customer_screen.dart';
import '../order_details_screen.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // --- GET CUSTOMER LOGIC ---
  CustomerMeasurement _getCustomer(TaskModel task) {
    try {
      return CustomerDatabase.customers.firstWhere(
        (c) => c.id == task.customerId,
      );
    } catch (e) {
      return CustomerMeasurement(
        name: "Unknown Customer",
        phoneNumber: "",
        isStitchingCustomer: true,
      );
    }
  }

  // --- WHATSAPP LOGIC ---
  Future<void> _launchWhatsApp(TaskModel task) async {
    final customer = _getCustomer(task);
    final number = customer.phoneNumber;

    if (number.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No phone number found')));
      return;
    }

    String cleanNumber = number.replaceAll('-', '').replaceAll(' ', '');
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '+92${cleanNumber.substring(1)}';
    }

    final message =
        "Asalam-o-Alaikum ${customer.name}, your suit (${task.title}) is READY at M Khalil Tailors. Please collect it.";
    final Uri url = Uri.parse(
      "https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}",
    );

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  // --- MARK DONE LOGIC ---
  void _attemptMarkDone(TaskModel task) {
    final Color darkSlate = Theme.of(context).primaryColor;
    final customer = _getCustomer(task);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: darkSlate.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: darkSlate, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                "Order Completed?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Notify ${customer.name} that their suit is ready?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _finalizeTask(task);
                    _launchWhatsApp(task);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.chat),
                  label: const Text("Yes, Notify Customer"),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _finalizeTask(task);
                  },
                  child: Text(
                    "No, Just Save Order",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finalizeTask(TaskModel task) async {
    task.isCompleted = true;
    await TaskDatabase.updateTask(task, task);
  }

  // --- HEADER WIDGET ---
  Widget _buildHeader(Color darkSlate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        color: darkSlate,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WELCOME BACK',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Digital Darzi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color darkSlate = Theme.of(context).primaryColor;
    final user = FirebaseAuth.instance.currentUser;

    // Connect to the Cloud Stream directly
    final Stream<QuerySnapshot> taskStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid ?? 'guest_data')
        .collection('tasks')
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      // Wrap Body in StreamBuilder for Real-Time Updates
      body: StreamBuilder<QuerySnapshot>(
        stream: taskStream,
        builder: (context, snapshot) {
          List<TaskModel> allTasks = [];
          if (snapshot.hasData) {
            allTasks = snapshot.data!.docs.map((doc) {
              return TaskModel.fromJson(
                doc.data() as Map<String, dynamic>,
                docId: doc.id,
              );
            }).toList();
          }

          // Filter & Sort
          List<TaskModel> visibleTasks = allTasks.where((task) {
            if (task.isCompleted) return false;
            if (_searchQuery.isNotEmpty) {
              return task.title.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
            }
            return true;
          }).toList();

          visibleTasks.sort((a, b) => a.date.compareTo(b.date));

          return Column(
            children: [
              _buildHeader(darkSlate),

              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // --- ADD NEW CUSTOMER BUTTON (FIXED) ---
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  // 1. Open Screen and WAIT for result
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AddCustomerScreen(),
                                    ),
                                  );

                                  // 2. If result is not null, it means we saved successfully!
                                  if (result != null && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Customer Added Successfully!',
                                        ),
                                        backgroundColor: darkSlate,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: darkSlate,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(Icons.person_add),
                                label: const Text(
                                  'Add New Customer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // --- ACTIVE ORDERS COUNT ---
                            Row(
                              children: [
                                Text(
                                  'ACTIVE ORDERS',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: darkSlate,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${visibleTasks.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            // --- SEARCH BAR ---
                            TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search active jobs...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: darkSlate,
                                ),
                                filled: true,
                                fillColor: darkSlate.withOpacity(0.06),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- TASK LIST ---
                    visibleTasks.isEmpty
                        ? SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.assignment_turned_in_outlined,
                                    size: 60,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    "No pending work",
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: _buildTaskCard(
                                  visibleTasks[index],
                                  darkSlate,
                                ),
                              ),
                              childCount: visibleTasks.length,
                            ),
                          ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      // --- NEW JOB BUTTON (FIXED TEXT COLOR) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (CustomerDatabase.customers.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add a Customer first!')),
            );
            return;
          }
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
          );

          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Job Added Successfully!'),
                backgroundColor: darkSlate,
              ),
            );
          }
        },
        backgroundColor: darkSlate,
        icon: const Icon(Icons.add, color: Colors.white),
        // THIS IS THE TEXT FIX: Explicit Style
        label: const Text(
          "New Job",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task, Color themeColor) {
    String dateString = "${task.date.day}/${task.date.month}";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(task: task),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.0,
                  child: Checkbox(
                    value: task.isCompleted,
                    activeColor: themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    onChanged: (bool? value) {
                      if (value == true) _attemptMarkDone(task);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    dateString,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
