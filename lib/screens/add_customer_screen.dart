// lib/screens/add_customer_screen.dart

import 'package:flutter/material.dart';
import '../models/customer_measurement.dart';
import '../data/customer_database.dart';

class AddCustomerScreen extends StatefulWidget {
  final CustomerMeasurement? customerToEdit;

  const AddCustomerScreen({super.key, this.customerToEdit});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  // We don't need _isLoading anymore because we close instantly!

  // Info
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _areaController;

  // Kameez
  late TextEditingController _kameezLambaiController;
  late TextEditingController _teeraController;
  late TextEditingController _bazuController;
  late TextEditingController _galaController;
  late TextEditingController _chaatiController;
  late TextEditingController _cuffController;

  // Shalwar
  late TextEditingController _shalwarLambaiController;
  late TextEditingController _panchaController;

  // Styles
  String _damanStyle = 'Chawras';
  String _sleeveStyle = 'Cuff';
  bool _twoSidePockets = true;
  String _frontPocket = 'Simple';
  String _collarType = 'Collar';
  bool _specialButtons = false;

  final _tagController = TextEditingController();
  List<String> _tags = [];
  double _currentBalance = 0.0;

  @override
  void initState() {
    super.initState();
    final c = widget.customerToEdit;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phoneNumber ?? '');
    _areaController = TextEditingController(text: c?.areaName ?? '');

    _kameezLambaiController = TextEditingController(
      text: c != null && c.kameezLambai > 0 ? c.kameezLambai.toString() : '',
    );
    _teeraController = TextEditingController(
      text: c != null && c.teera > 0 ? c.teera.toString() : '',
    );
    _bazuController = TextEditingController(
      text: c != null && c.bazu > 0 ? c.bazu.toString() : '',
    );
    _galaController = TextEditingController(
      text: c != null && c.gala > 0 ? c.gala.toString() : '',
    );
    _chaatiController = TextEditingController(
      text: c != null && c.chaati > 0 ? c.chaati.toString() : '',
    );
    _cuffController = TextEditingController(
      text: c != null && c.cuff > 0 ? c.cuff.toString() : '',
    );

    _shalwarLambaiController = TextEditingController(
      text: c != null && c.shalwarLambai > 0 ? c.shalwarLambai.toString() : '',
    );
    _panchaController = TextEditingController(
      text: c != null && c.pancha > 0 ? c.pancha.toString() : '',
    );

    if (c != null) {
      _damanStyle = c.damanStyle;
      _sleeveStyle = c.sleeveStyle;
      _twoSidePockets = c.twoSidePockets;
      _frontPocket = c.frontPocket;
      _collarType = c.collarType;
      _specialButtons = c.specialButtons;
      _tags = List.from(c.tags);
      _currentBalance = c.balance;
    } else {
      _nameController = TextEditingController();
      _phoneController = TextEditingController();
      _areaController = TextEditingController();
      _kameezLambaiController = TextEditingController();
      _teeraController = TextEditingController();
      _bazuController = TextEditingController();
      _galaController = TextEditingController();
      _chaatiController = TextEditingController();
      _cuffController = TextEditingController();
      _shalwarLambaiController = TextEditingController();
      _panchaController = TextEditingController();
    }
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  // --- FAST SAVE LOGIC (INSTANT CLOSE) ---
  void _saveCustomer() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter customer name')),
      );
      return;
    }

    // 1. Prepare Data
    final updatedCustomer = CustomerMeasurement(
      id: widget.customerToEdit?.id,
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      areaName: _areaController.text,
      isStitchingCustomer: true,

      kameezLambai: double.tryParse(_kameezLambaiController.text) ?? 0.0,
      teera: double.tryParse(_teeraController.text) ?? 0.0,
      bazu: double.tryParse(_bazuController.text) ?? 0.0,
      gala: double.tryParse(_galaController.text) ?? 0.0,
      chaati: double.tryParse(_chaatiController.text) ?? 0.0,
      cuff: double.tryParse(_cuffController.text) ?? 0.0,

      shalwarLambai: double.tryParse(_shalwarLambaiController.text) ?? 0.0,
      pancha: double.tryParse(_panchaController.text) ?? 0.0,

      damanStyle: _damanStyle,
      sleeveStyle: _sleeveStyle,
      twoSidePockets: _twoSidePockets,
      frontPocket: _frontPocket,
      collarType: _collarType,
      specialButtons: _specialButtons,

      tags: _tags,
      balance: _currentBalance,
    );

    // 2. CLOSE SCREEN IMMEDIATELY (Don't wait)
    Navigator.pop(context, updatedCustomer);

    // 3. Save in Background
    if (widget.customerToEdit != null) {
      CustomerDatabase.updateCustomer(widget.customerToEdit!, updatedCustomer);
    } else {
      CustomerDatabase.addCustomer(updatedCustomer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customerToEdit != null;
    final Color darkSlate = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add New Customer'),
        backgroundColor: darkSlate,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveCustomer,
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Customer Info', darkSlate),
            _buildBoxTextField(_nameController, 'Name', Icons.person),
            const SizedBox(height: 12),
            _buildBoxTextField(
              _phoneController,
              'Phone',
              Icons.phone,
              isNumber: true,
            ),
            const SizedBox(height: 12),
            _buildBoxTextField(
              _areaController,
              'Area / Location',
              Icons.location_on,
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Kameez & Bazu', darkSlate),
            Row(
              children: [
                Expanded(
                  child: _buildBoxTextField(
                    _kameezLambaiController,
                    'Kameez Length',
                    null,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBoxTextField(
                    _teeraController,
                    'Teera',
                    null,
                    isNumber: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildBoxTextField(
                    _bazuController,
                    'Bazu (Arm)',
                    null,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBoxTextField(
                    _cuffController,
                    'Cuff Size',
                    null,
                    isNumber: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildBoxTextField(
                    _galaController,
                    'Gala (Neck)',
                    null,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBoxTextField(
                    _chaatiController,
                    'Chaati (Chest)',
                    null,
                    isNumber: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Shalwar', darkSlate),
            Row(
              children: [
                Expanded(
                  child: _buildBoxTextField(
                    _shalwarLambaiController,
                    'Shalwar Lambai',
                    null,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBoxTextField(
                    _panchaController,
                    'Pancha',
                    null,
                    isNumber: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Design & Styles', darkSlate),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daman Style',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSelectButton(
                          'Chawras',
                          _damanStyle == 'Chawras',
                          () => setState(() => _damanStyle = 'Chawras'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSelectButton(
                          'Gool',
                          _damanStyle == 'Gool',
                          () => setState(() => _damanStyle = 'Gool'),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 20),

                  const Text(
                    'Bazu Style',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSelectButton(
                          'Cuff',
                          _sleeveStyle == 'Cuff',
                          () => setState(() => _sleeveStyle = 'Cuff'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSelectButton(
                          'Sada Nastoni',
                          _sleeveStyle == 'Sada',
                          () => setState(() => _sleeveStyle = 'Sada'),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 20),

                  const Text(
                    'Collar Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSelectButton(
                          'Collar',
                          _collarType == 'Collar',
                          () => setState(() => _collarType = 'Collar'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSelectButton(
                          'Ban',
                          _collarType == 'Ban',
                          () => setState(() => _collarType = 'Ban'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSelectButton(
                          'Half Ban',
                          _collarType == 'Half Ban',
                          () => setState(() => _collarType = 'Half Ban'),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 20),

                  const Text(
                    '2 Side Pockets',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSelectButton(
                          'Yes',
                          _twoSidePockets == true,
                          () => setState(() => _twoSidePockets = true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSelectButton(
                          'No',
                          _twoSidePockets == false,
                          () => setState(() => _twoSidePockets = false),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 20),

                  const Text(
                    'Fancy / Ring Buttons',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSelectButton(
                          'Yes',
                          _specialButtons == true,
                          () => setState(() => _specialButtons = true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSelectButton(
                          'No',
                          _specialButtons == false,
                          () => setState(() => _specialButtons = false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Extra Tags', darkSlate),
            Row(
              children: [
                Expanded(
                  child: _buildBoxTextField(
                    _tagController,
                    'e.g. Fancy button...',
                    null,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTag,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkSlate,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: darkSlate.withOpacity(0.1),
                      labelStyle: TextStyle(color: darkSlate),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => setState(() => _tags.remove(tag)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildSelectButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: color,
        ),
      ),
    );
  }

  Widget _buildBoxTextField(
    TextEditingController controller,
    String label,
    IconData? icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
