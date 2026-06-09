// lib/screens/customer_details_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/customer_measurement.dart';
import '../data/customer_database.dart';
import 'add_customer_screen.dart'; // Ensure this file exists

class CustomerDetailsScreen extends StatefulWidget {
  final CustomerMeasurement customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  void _refresh() {
    setState(() {});
  }

  Future<void> _launchWhatsApp() async {
    final number = widget.customer.phoneNumber;
    if (number.isEmpty) return;

    String cleanNumber = number.replaceAll('-', '').replaceAll(' ', '');
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '+92${cleanNumber.substring(1)}';
    }

    final Uri url = Uri.parse("https://wa.me/$cleanNumber");
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp. Check number format.'),
          ),
        );
      }
    }
  }

  void _addTransaction(bool isDebt) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isDebt ? 'Add Amount (Udhaar)' : 'Receive Cash (Wasooli)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Amount (Rs)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0.0;
              if (amount > 0) {
                setState(() {
                  if (isDebt) {
                    widget.customer.balance += amount;
                  } else {
                    widget.customer.balance -= amount;
                  }
                });
                CustomerDatabase.updateCustomer(
                  widget.customer,
                  widget.customer,
                );
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDebt ? Colors.red : Colors.green,
            ),
            child: Text(isDebt ? 'Add Debt' : 'Receive'),
          ),
        ],
      ),
    );
  }

  void _deleteCustomer(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer?'),
        content: Text(
          'Are you sure you want to remove ${widget.customer.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              CustomerDatabase.deleteCustomer(widget.customer);
              Navigator.pop(ctx);
              Navigator.pop(context);
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
    final customer = widget.customer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _deleteCustomer(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: darkSlate,
                    child: Text(
                      customer.name.isNotEmpty ? customer.name[0] : '?',
                      style: const TextStyle(
                        fontSize: 35,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    customer.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkSlate,
                    ),
                  ),

                  const SizedBox(height: 5),
                  // Phone
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        customer.phoneNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _launchWhatsApp,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Area Name
                  if (customer.areaName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: darkSlate.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on, size: 14, color: darkSlate),
                            const SizedBox(width: 4),
                            Text(
                              customer.areaName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: darkSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: customer.balance > 0
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Current Balance',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  Text(
                    'Rs ${customer.balance.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: customer.balance > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _addTransaction(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            elevation: 0,
                          ),
                          child: const Text('Add Debt'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _addTransaction(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade50,
                            foregroundColor: Colors.green,
                            elevation: 0,
                          ),
                          child: const Text('Receive'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _buildCard(
              title: 'Kameez Measurements',
              themeColor: darkSlate,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailItem(
                        'Kameez Lambai',
                        customer.kameezLambai,
                        darkSlate,
                      ),
                      _buildDetailItem('Teera', customer.teera, darkSlate),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailItem('Bazu', customer.bazu, darkSlate),
                      _buildDetailItem('Cuff', customer.cuff, darkSlate),
                      _buildDetailItem('Gala', customer.gala, darkSlate),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDetailItem('Chaati', customer.chaati, darkSlate),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildCard(
              title: 'Shalwar',
              themeColor: darkSlate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem(
                    'Shalwar Lambai',
                    customer.shalwarLambai,
                    darkSlate,
                  ),
                  _buildDetailItem('Pancha', customer.pancha, darkSlate),
                  _buildDetailItem('', 0.0, Colors.transparent),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildCard(
              title: 'Styles & Design',
              themeColor: darkSlate,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildTag('Daman: ${customer.damanStyle}', Colors.blue),
                  _buildTag(
                    customer.sleeveStyle == 'Cuff' ? 'Cuffs' : 'Sada Nastoni',
                    Colors.purple,
                  ),
                  if (customer.twoSidePockets)
                    _buildTag('2 Side Pockets', darkSlate),
                  _buildTag(customer.collarType, darkSlate),
                  _buildTag('Front: ${customer.frontPocket}', darkSlate),
                  if (customer.specialButtons)
                    _buildTag('Fancy Buttons', Colors.orange, isAccent: true),
                  ...customer.tags.map(
                    (tag) => _buildTag(tag, Colors.red, isAccent: true),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final updatedData = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddCustomerScreen(customerToEdit: customer),
                    ),
                  );
                  if (updatedData != null &&
                      updatedData is CustomerMeasurement) {
                    CustomerDatabase.updateCustomer(customer, updatedData);
                    _refresh();
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Details'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Color themeColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          const Divider(height: 25),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, double value, Color themeColor) {
    if (label.isEmpty) return const Expanded(child: SizedBox());
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value == 0.0 ? '-' : '$value"',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: themeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color, {bool isAccent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
