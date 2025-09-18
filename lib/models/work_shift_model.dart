import 'package:cloud_firestore/cloud_firestore.dart';

class WorkShiftModel {
  final String id;
  final int status;
  final String user;
  final Timestamp? checkIn;
  final Timestamp? checkOut;
  final List<Timestamp> breakTimes;
  final List<Timestamp> resumeTimes;
  final DateTime date;

  // Constructor with default values
  WorkShiftModel({
    this.id = "",
    this.status = 0,
    this.user = "",
    this.checkIn,
    this.checkOut,
    this.breakTimes = const [],
    this.resumeTimes = const [],
    DateTime? date,
  }) : date = date ?? DateTime.now();

  // Factory method to create a WorkShiftModel from JSON
  factory WorkShiftModel.fromJson(Map<String, dynamic> json) => WorkShiftModel(
        id: json['id'] != null ? json['id'].toString() : "",
        status:
            json['status'] != null ? int.parse(json['status'].toString()) : 0,
        user: json['user'] != null ? json['user'].toString() : "",
        checkIn:
            json['check_in'] != null ? json['check_in'] as Timestamp : null,
        checkOut:
            json['check_out'] != null ? json['check_out'] as Timestamp : null,
        breakTimes:
            json['break'] != null ? List<Timestamp>.from(json['break']) : [],
        resumeTimes:
            json['resume'] != null ? List<Timestamp>.from(json['resume']) : [],
        date: json['date'] != null
            ? DateTime.parse(json['date'])
            : DateTime.now(),
      );

  // Factory method to create a WorkShiftModel from Firestore snapshot
  factory WorkShiftModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return WorkShiftModel(
      id: data['id'] != null ? data['id'].toString() : "",
      status: data['status'] != null ? int.parse(data['status'].toString()) : 0,
      user: data['user'] != null ? data['user'].toString() : "",
      checkIn: data['check_in'] != null ? data['check_in'] as Timestamp : null,
      checkOut:
          data['check_out'] != null ? data['check_out'] as Timestamp : null,
      breakTimes:
          data['break'] != null ? List<Timestamp>.from(data['break']) : [],
      resumeTimes:
          data['resume'] != null ? List<Timestamp>.from(data['resume']) : [],
      date:
          data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
    );
  }

  // Copy method to create a modified instance
  WorkShiftModel copyWith({
    String? id,
    int? status,
    String? user,
    Timestamp? checkIn,
    Timestamp? checkOut,
    List<Timestamp>? breakTimes,
    List<Timestamp>? resumeTimes,
    DateTime? date,
  }) {
    return WorkShiftModel(
      id: id ?? this.id,
      status: status ?? this.status,
      user: user ?? this.user,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      breakTimes: breakTimes ?? this.breakTimes,
      resumeTimes: resumeTimes ?? this.resumeTimes,
      date: date ?? this.date,
    );
  }

  // Convert WorkShiftModel to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'user': user,
        'check_in': checkIn,
        'check_out': checkOut,
        'break': breakTimes,
        'resume': resumeTimes,
        'date': date.toIso8601String(),
      };

  static Map<String, dynamic> getDifferentFields(WorkShiftModel obj1, WorkShiftModel obj2) {
    final differences = <String, dynamic>{};

    if (obj1.id != obj2.id) differences['id'] = obj2.id;
    if (obj1.status != obj2.status) differences['status'] = obj2.status;
    if (obj1.user != obj2.user) differences['user'] = obj2.user;
    if (obj1.checkIn != obj2.checkIn) differences['check_in'] = obj2.checkIn;
    if (obj1.checkOut != obj2.checkOut) differences['check_out'] = obj2.checkOut;
    if (!listEquals(obj1.breakTimes, obj2.breakTimes)) differences['break'] = obj2.breakTimes;
    if (!listEquals(obj1.resumeTimes, obj2.resumeTimes)) differences['resume'] = obj2.resumeTimes;
    if (obj1.date != obj2.date) differences['date'] = obj2.date;

    return differences;
  }

  static bool listEquals(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
