// lib/screens/select_customer_screen.dart

import 'package:flutter/material.dart';
import '../models/customer_measurement.dart';
import '../data/customer_database.dart';

class SelectCustomerScreen extends StatefulWidget {
  const SelectCustomerScreen({super.key});

  @override
  State<SelectCustomerScreen> createState() => _SelectCustomerScreenState();
}

class _SelectCustomerScreenState extends State<SelectCustomerScreen> {
  List<CustomerMeasurement> _allCustomers = [];
  List<CustomerMeasurement> _filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load data once
    _allCustomers = CustomerDatabase.customers;
    _filteredCustomers = _allCustomers;
  }

  void _runSearch(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        _filteredCustomers = _allCustomers;
      } else {
        _filteredCustomers = _allCustomers
            .where(
              (customer) =>
                  customer.name.toLowerCase().contains(keyword.toLowerCase()) ||
                  customer.phoneNumber.contains(keyword),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Select Customer',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _runSearch,
              autofocus: true, // Keyboard opens automatically
              decoration: InputDecoration(
                hintText: 'Search by Name or Phone...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- The List ---
          Expanded(
            child: ListView.builder(
              // Performance Optimization: builder only renders what is on screen
              itemCount: _filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = _filteredCustomers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      customer.name.isNotEmpty ? customer.name[0] : '?',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    customer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(customer.phoneNumber),
                  trailing: customer.areaName.isNotEmpty
                      ? Text(
                          customer.areaName,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        )
                      : null,
                  onTap: () {
                    // Return the selected customer to the previous screen
                    Navigator.pop(context, customer);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
