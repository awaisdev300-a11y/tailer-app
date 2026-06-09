// lib/data/customer_database.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/customer_measurement.dart';

class CustomerDatabase {
  static List<CustomerMeasurement> customers = [];

  // Get the correct folder for the Logged In User
  static CollectionReference get _collection {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid ?? 'guest_data') // Separate data per user
        .collection('customers');
  }

  // --- 1. LISTEN TO CLOUD (Real Sync) ---
  static Future<void> loadData() async {
    // This creates a "Live Connection"
    _collection.snapshots().listen((snapshot) {
      customers = snapshot.docs.map((doc) {
        // We pass the Doc ID so we can edit/delete later
        return CustomerMeasurement.fromJson(
          doc.data() as Map<String, dynamic>,
          docId: doc.id,
        );
      }).toList();

      // Sort: Newest Customers First
      customers.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );

      print("Synced ${customers.length} customers from Cloud");
    });
  }

  // --- 2. ADD CUSTOMER ---
  static Future<void> addCustomer(CustomerMeasurement customer) async {
    // Firestore handles Offline automatically!
    await _collection.add(customer.toJson());
  }

  // --- 3. UPDATE CUSTOMER ---
  static Future<void> updateCustomer(
    CustomerMeasurement oldC,
    CustomerMeasurement newC,
  ) async {
    if (oldC.id == null) return;
    await _collection.doc(oldC.id).update(newC.toJson());
  }

  // --- 4. DELETE CUSTOMER ---
  static Future<void> deleteCustomer(CustomerMeasurement customer) async {
    if (customer.id == null) return;
    await _collection.doc(customer.id).delete();
  }
}
