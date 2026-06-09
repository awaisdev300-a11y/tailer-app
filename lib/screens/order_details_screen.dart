// lib/screens/order_details_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/task_model.dart'; // New Model
import '../models/customer_measurement.dart';
import '../data/customer_database.dart'; // Database Access

class OrderDetailsScreen extends StatelessWidget {
  final TaskModel task;

  const OrderDetailsScreen({super.key, required this.task});

  // Helper to find the customer from the ID in the task
  CustomerMeasurement _getCustomer() {
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

  Future<void> _notifyCustomer(BuildContext context) async {
    final customer = _getCustomer();
    final number = customer.phoneNumber;

    if (number.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No phone number found!')));
      return;
    }

    String cleanNumber = number.replaceAll('-', '').replaceAll(' ', '');
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '+92${cleanNumber.substring(1)}';
    }

    final message =
        "Asalam-o-Alaikum ${customer.name}, your suit is ready at M Khalil Tailors. Please collect it.";
    final Uri url = Uri.parse(
      "https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}",
    );

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color darkSlate = Theme.of(context).primaryColor;
    final customer = _getCustomer(); // Fetch real customer data

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Job Ticket'),
        backgroundColor: darkSlate,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- HEADER CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: darkSlate,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ORDER FOR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    customer.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  Text(
                    'Job: ${task.title}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _notifyCustomer(context),
                      icon: const Icon(Icons.chat),
                      label: const Text('Notify Customer (WhatsApp)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _buildSectionHeader('MEASUREMENTS'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMeasureItem(
                        'Kameez',
                        customer.kameezLambai,
                        darkSlate,
                      ),
                      _buildMeasureItem('Teera', customer.teera, darkSlate),
                      _buildMeasureItem('Bazu', customer.bazu, darkSlate),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMeasureItem('Gala', customer.gala, darkSlate),
                      _buildMeasureItem('Chaati', customer.chaati, darkSlate),
                      _buildMeasureItem(
                        'Cuff',
                        customer.cuff,
                        darkSlate,
                      ), // Cuff is here
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMeasureItem(
                        'Shalwar',
                        customer.shalwarLambai,
                        darkSlate,
                      ),
                      _buildMeasureItem('Pancha', customer.pancha, darkSlate),
                      _buildMeasureItem('', 0.0, Colors.transparent),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _buildSectionHeader('DESIGN & STITCHING'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildTag('Daman: ${customer.damanStyle}', darkSlate),
                  _buildTag(
                    customer.sleeveStyle == 'Cuff' ? 'Cuffs' : 'Sada Nastoni',
                    darkSlate,
                  ),
                  _buildTag(customer.collarType, darkSlate),
                  _buildTag('Front: ${customer.frontPocket}', darkSlate),
                  if (customer.twoSidePockets)
                    _buildTag('2 Side Pockets', darkSlate),
                  if (customer.specialButtons)
                    _buildTag('Fancy Buttons', darkSlate),
                  ...customer.tags.map(
                    (t) => _buildTag(t, Colors.red, isAccent: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMeasureItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value == 0.0 ? '-' : '$value"',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label, Color color, {bool isAccent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isAccent ? color.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAccent ? color.withOpacity(0.3) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isAccent ? color : Colors.black87,
          fontSize: 12,
        ),
      ),
    );
  }
}
