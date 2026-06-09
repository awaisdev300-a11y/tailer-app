// lib/screens/tabs/measurements_tab.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/customer_measurement.dart';
import '../../data/customer_database.dart';
import '../add_customer_screen.dart';
import '../customer_details_screen.dart';

class MeasurementsTab extends StatefulWidget {
  const MeasurementsTab({super.key});

  @override
  State<MeasurementsTab> createState() => _MeasurementsTabState();
}

class _MeasurementsTabState extends State<MeasurementsTab> {
  String _searchQuery = "";

  // --- ACTIONS ---
  void _editCustomer(CustomerMeasurement customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomerScreen(customerToEdit: customer),
      ),
    );
  }

  void _confirmDelete(CustomerMeasurement customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer?'),
        content: Text('Delete ${customer.name}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await CustomerDatabase.deleteCustomer(customer);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(String number) async {
    final Uri url = Uri.parse("tel:$number");
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _launchWhatsApp(String number) async {
    String cleanNumber = number.replaceAll('-', '').replaceAll(' ', '');
    if (cleanNumber.startsWith('0'))
      cleanNumber = '+92${cleanNumber.substring(1)}';
    final Uri url = Uri.parse("https://wa.me/$cleanNumber");
    if (await canLaunchUrl(url))
      await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final Color darkSlate = Theme.of(context).primaryColor;
    final user = FirebaseAuth.instance.currentUser;

    // --- LIVE CLOUD STREAM ---
    final Stream<QuerySnapshot> customerStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid ?? 'guest_data')
        .collection('customers')
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // --- HEADER ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              color: darkSlate,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CUSTOMER DATABASE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search Name, Phone, or Area...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // --- LIST BODY ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: customerStream,
              builder: (context, snapshot) {
                // 1. Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Process Data
                List<CustomerMeasurement> allCustomers = [];
                if (snapshot.hasData) {
                  allCustomers = snapshot.data!.docs.map((doc) {
                    return CustomerMeasurement.fromJson(
                      doc.data() as Map<String, dynamic>,
                      docId: doc.id,
                    );
                  }).toList();
                }

                // 3. Filter Data
                final filteredList = allCustomers.where((c) {
                  // Only show Stitching Customers in this tab
                  if (!c.isStitchingCustomer) return false;

                  final q = _searchQuery.toLowerCase();
                  return c.name.toLowerCase().contains(q) ||
                      c.phoneNumber.contains(q) ||
                      c.areaName.toLowerCase().contains(q);
                }).toList();

                // --- 4. SORT LOGIC (NEWEST FIRST) ---
                // We compare B to A (Descending Order)
                filteredList.sort((a, b) {
                  DateTime dateA = a.createdAt ?? DateTime(2000);
                  DateTime dateB = b.createdAt ?? DateTime(2000);
                  return dateB.compareTo(dateA);
                });

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 60,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No customers found",
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final customer = filteredList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: darkSlate.withOpacity(0.1),
                          child: Text(
                            customer.name.isNotEmpty
                                ? customer.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: darkSlate,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (customer.phoneNumber.isNotEmpty)
                              Text(
                                customer.phoneNumber,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            if (customer.areaName.isNotEmpty)
                              Text(
                                customer.areaName,
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (customer.phoneNumber.isNotEmpty) ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.phone,
                                  color: Colors.green,
                                ),
                                onPressed: () =>
                                    _launchPhone(customer.phoneNumber),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.chat,
                                  color: Colors.blue,
                                ), // WhatsApp
                                onPressed: () =>
                                    _launchWhatsApp(customer.phoneNumber),
                              ),
                            ],
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CustomerDetailsScreen(customer: customer),
                            ),
                          );
                        },
                        onLongPress: () => _editCustomer(customer),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // --- ADD BUTTON ---
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
          );
        },
        backgroundColor: darkSlate,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
