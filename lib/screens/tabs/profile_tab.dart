// lib/screens/tabs/profile_tab.dart

import 'package:flutter/material.dart';
import '../../data/customer_database.dart';
import '../../data/task_database.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    final Color darkSlate = Theme.of(context).primaryColor;

    // Calculate Stats
    final int totalCustomers = CustomerDatabase.customers.length;
    final int activeOrders = TaskDatabase.tasks
        .where((t) => !t.isCompleted)
        .length;
    final int completedOrders = TaskDatabase.tasks
        .where((t) => t.isCompleted)
        .length;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. Shop Header ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Shop Logo / Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: darkSlate.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: darkSlate,
                      child: const Icon(
                        Icons.store_mall_directory,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Shop Name
                  Text(
                    'M Khalil Tailors',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: darkSlate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Islamabad, Pakistan', // Placeholder location
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- 2. Business Statistics ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildStatCard(
                    'Customers',
                    '$totalCustomers',
                    Icons.people,
                    Colors.blue,
                    context,
                  ),
                  const SizedBox(width: 15),
                  _buildStatCard(
                    'Completed',
                    '$completedOrders',
                    Icons.check_circle,
                    Colors.green,
                    context,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- 3. Settings Menu ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SHOP SETTINGS',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingsTile(
                          Icons.edit,
                          'Edit Shop Details',
                          'Change name & address',
                          context,
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          Icons.language,
                          'Language',
                          'English (Urdu Coming Soon)',
                          context,
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          Icons.backup,
                          'Backup Data',
                          'Save your customer list',
                          context,
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          Icons.info_outline,
                          'About App',
                          'Version 1.0.0',
                          context,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 15),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle,
    BuildContext context,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Feature coming soon!')));
      },
    );
  }
}
