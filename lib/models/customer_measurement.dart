// lib/models/customer_measurement.dart

class CustomerMeasurement {
  String? id;
  String name;
  String phoneNumber;
  String areaName;
  bool isStitchingCustomer;

  // Measurements (Keeping ALL your fields)
  double kameezLambai;
  double teera;
  double bazu;
  double gala;
  double chaati;
  double cuff;
  double shalwarLambai;
  double pancha;

  // Styles
  String damanStyle;
  String sleeveStyle;
  bool twoSidePockets;
  String frontPocket;
  String collarType;
  bool specialButtons;

  List<String> tags;
  double balance;
  DateTime? createdAt; // Added for sorting

  CustomerMeasurement({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.areaName = '',
    this.isStitchingCustomer = true,

    this.kameezLambai = 0.0,
    this.teera = 0.0,
    this.bazu = 0.0,
    this.gala = 0.0,
    this.chaati = 0.0,
    this.cuff = 0.0,
    this.shalwarLambai = 0.0,
    this.pancha = 0.0,

    this.damanStyle = 'Chawras',
    this.sleeveStyle = 'Cuff',
    this.twoSidePockets = true,
    this.frontPocket = 'Simple',
    this.collarType = 'Collar',
    this.specialButtons = false,

    this.tags = const [],
    this.balance = 0.0,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'areaName': areaName,
      'isStitchingCustomer': isStitchingCustomer,

      // Measurements
      'kameezLambai': kameezLambai,
      'teera': teera,
      'bazu': bazu,
      'gala': gala,
      'chaati': chaati,
      'cuff': cuff,
      'shalwarLambai': shalwarLambai,
      'pancha': pancha,

      // Styles
      'damanStyle': damanStyle,
      'sleeveStyle': sleeveStyle,
      'twoSidePockets': twoSidePockets,
      'frontPocket': frontPocket,
      'collarType': collarType,
      'specialButtons': specialButtons,

      'tags': tags,
      'balance': balance,
      'createdAt':
          createdAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory CustomerMeasurement.fromJson(
    Map<String, dynamic> json, {
    String? docId,
  }) {
    return CustomerMeasurement(
      id: docId ?? json['id'], // Use Cloud ID if available
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      areaName: json['areaName'] ?? '',
      isStitchingCustomer: json['isStitchingCustomer'] ?? true,

      kameezLambai: (json['kameezLambai'] ?? 0.0).toDouble(),
      teera: (json['teera'] ?? 0.0).toDouble(),
      bazu: (json['bazu'] ?? 0.0).toDouble(),
      gala: (json['gala'] ?? 0.0).toDouble(),
      chaati: (json['chaati'] ?? 0.0).toDouble(),
      cuff: (json['cuff'] ?? 0.0).toDouble(),
      shalwarLambai: (json['shalwarLambai'] ?? 0.0).toDouble(),
      pancha: (json['pancha'] ?? 0.0).toDouble(),

      damanStyle: json['damanStyle'] ?? 'Chawras',
      sleeveStyle: json['sleeveStyle'] ?? 'Cuff',
      twoSidePockets: json['twoSidePockets'] ?? true,
      frontPocket: json['frontPocket'] ?? 'Simple',
      collarType: json['collarType'] ?? 'Collar',
      specialButtons: json['specialButtons'] ?? false,

      tags: List<String>.from(json['tags'] ?? []),
      balance: (json['balance'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
    );
  }
}
