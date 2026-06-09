// lib/screens/tabs/khata_tab.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/customer_database.dart';
import '../../models/customer_measurement.dart';

class KhataTab extends StatefulWidget {
  const KhataTab({super.key});

  @override
  State<KhataTab> createState() => _KhataTabState();
}

class _KhataTabState extends State<KhataTab> {
  String _searchQuery = "";

  // --- 1. NEW BUYER DIALOG (INSTANT CLOSE) ---
  void _showAddBuyerDialog() {
    final nameController = TextEditingController();
    final areaController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('New Buyer (Khata Only)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: areaController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Area / Place',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone (Optional)',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                // 1. Prepare Data
                final newCustomer = CustomerMeasurement(
                  name: nameController.text,
                  areaName: areaController.text,
                  phoneNumber: phoneController.text,
                  isStitchingCustomer: false, // Mark as Khata Buyer
                );

                // 2. CLOSE DIALOG INSTANTLY
                Navigator.pop(ctx);

                // 3. Save in Background
                CustomerDatabase.addCustomer(newCustomer);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Buyer Added. Tap to add debt.'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Buyer'),
          ),
        ],
      ),
    );
  }

  // --- 2. TRANSACTIONS (INSTANT CLOSE) ---
  void _quickTransaction(CustomerMeasurement customer) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                customer.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Current Balance: ${customer.balance.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: customer.balance > 0 ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Amount (Rs)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              // SELL BUTTON
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(controller.text) ?? 0.0;
                    if (amount > 0) {
                      // 1. Update Object Locally
                      customer.balance += amount;

                      // 2. CLOSE DIALOG INSTANTLY
                      Navigator.pop(ctx);

                      // 3. Sync in Background
                      CustomerDatabase.updateCustomer(customer, customer);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to Khata')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                  ),
                  child: const Text(
                    'Sell Cloth',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // RECEIVE BUTTON
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(controller.text) ?? 0.0;
                    if (amount > 0) {
                      // 1. Update Object Locally
                      customer.balance -= amount;

                      // 2. CLOSE DIALOG INSTANTLY
                      Navigator.pop(ctx);

                      // 3. Sync in Background
                      CustomerDatabase.updateCustomer(customer, customer);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment Received')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade50,
                    foregroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Receive Cash',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. DELETE CONFIRM ---
  void _confirmDelete(CustomerMeasurement customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Buyer?'),
        content: Text('Delete ${customer.name}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close Instantly
              CustomerDatabase.deleteCustomer(customer);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color darkSlate = Theme.of(context).primaryColor;
    final user = FirebaseAuth.instance.currentUser;

    // LIVE STREAM from Cloud
    final Stream<QuerySnapshot> customerStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid ?? 'guest_data')
        .collection('customers')
        .snapshots();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: customerStream,
        builder: (context, snapshot) {
          // 1. Process Data
          List<CustomerMeasurement> allCustomers = [];
          if (snapshot.hasData) {
            allCustomers = snapshot.data!.docs.map((doc) {
              return CustomerMeasurement.fromJson(
                doc.data() as Map<String, dynamic>,
                docId: doc.id,
              );
            }).toList();
          }

          // 2. Filter for Khata (Direct Buyer OR Stitching Customer with Debt)
          final filteredList = allCustomers.where((c) {
            final matchesSearch =
                c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                c.phoneNumber.contains(_searchQuery) ||
                c.areaName.toLowerCase().contains(_searchQuery.toLowerCase());
            if (!matchesSearch) return false;

            bool isDirectBuyer = !c.isStitchingCustomer;
            bool hasBalance = c.balance != 0;
            return isDirectBuyer || hasBalance;
          }).toList();

          filteredList.sort((a, b) => b.balance.compareTo(a.balance));

          // 3. Calc Total Market Debt
          double totalDebt = 0;
          for (var c in allCustomers) {
            if (c.balance > 0) totalDebt += c.balance;
          }

          return Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                decoration: BoxDecoration(
                  color: darkSlate,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL MARKET KHATA',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Rs ${totalDebt.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search for customer...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // LIST
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "No active khata found",
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return _buildKhataCard(filteredList[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBuyerDialog,
        backgroundColor: darkSlate,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('New Buyer', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildKhataCard(CustomerMeasurement customer) {
    final bool isInDebt = customer.balance > 0;
    final bool isAdvanced = customer.balance < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _quickTransaction(customer),
        onLongPress: () => _confirmDelete(customer),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade100,
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0] : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (customer.areaName.isNotEmpty)
                      Text(
                        customer.areaName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs ${customer.balance.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isInDebt
                          ? Colors.red
                          : (isAdvanced ? Colors.green : Colors.grey),
                    ),
                  ),
                  Text(
                    isInDebt ? 'Pending' : (isAdvanced ? 'Advance' : 'Clear'),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
