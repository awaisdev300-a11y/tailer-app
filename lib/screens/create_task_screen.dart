// lib/screens/create_task_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer_measurement.dart';
import '../models/task_model.dart';
import '../data/customer_database.dart';
import '../data/task_database.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  CustomerMeasurement? _selectedCustomer;

  @override
  Widget build(BuildContext context) {
    final Color darkSlate = Theme.of(context).primaryColor;

    // --- FILTER LOGIC: ONLY STITCHING CUSTOMERS ---
    final customers = CustomerDatabase.customers.where((c) {
      // 1. Hide Khata Buyers
      if (!c.isStitchingCustomer) return false;

      // 2. Search Logic
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.phoneNumber.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("New Job"),
        backgroundColor: darkSlate,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Customer",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // --- CUSTOMER SELECTOR BOX ---
            InkWell(
              onTap: _openCustomerSearch,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCustomer == null
                          ? "Tap to search customer..."
                          : _selectedCustomer!.name,
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedCustomer == null
                            ? Colors.grey.shade600
                            : Colors.black87,
                        fontWeight: _selectedCustomer == null
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.search, color: Colors.grey),
                  ],
                ),
              ),
            ),
            if (_selectedCustomer != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4),
                child: Text(
                  "Phone: ${_selectedCustomer!.phoneNumber}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),

            const SizedBox(height: 30),

            const Text(
              "Delivery Date",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // --- DATE PICKER ---
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // --- CREATE ORDER BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkSlate,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Create Order Ticket",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper variable for the horizontal list (not used in main UI anymore, but kept for logic)
  String _searchQuery = "";

  void _openCustomerSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _SearchCustomerSheet(
          onSelect: (customer) {
            setState(() => _selectedCustomer = customer);
          },
        );
      },
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // --- SAVE LOGIC ---
  void _saveTask() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a customer first!")),
      );
      return;
    }

    final String autoTitle = "Suit for ${_selectedCustomer!.name}";

    final newTask = TaskModel(
      title: autoTitle,
      date: _selectedDate,
      customerId: _selectedCustomer!.id!,
      isCompleted: false,
    );

    // 1. Close Screen Instantly
    if (mounted) {
      Navigator.pop(context, true);
    }

    // 2. Save to Cloud
    await TaskDatabase.addTask(newTask);
  }
}

// --- SEARCH SHEET ---
class _SearchCustomerSheet extends StatefulWidget {
  final Function(CustomerMeasurement) onSelect;
  const _SearchCustomerSheet({required this.onSelect});

  @override
  State<_SearchCustomerSheet> createState() => _SearchCustomerSheetState();
}

class _SearchCustomerSheetState extends State<_SearchCustomerSheet> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    // FILTER: Get ONLY Stitching Customers
    final stitchingCustomers = CustomerDatabase.customers
        .where((c) => c.isStitchingCustomer == true)
        .toList();

    final filtered = _query.isEmpty
        ? stitchingCustomers
        : stitchingCustomers
              .where(
                (c) =>
                    c.name.toLowerCase().contains(_query.toLowerCase()) ||
                    c.phoneNumber.contains(_query),
              )
              .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            "Search Customer",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          TextField(
            autofocus: true,
            onChanged: (val) => setState(() => _query = val),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Type name or phone...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("No stitching customer found."))
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final c = filtered[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        title: Text(
                          c.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(c.phoneNumber),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          widget.onSelect(c);
                          Navigator.pop(context);
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
