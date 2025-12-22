// import 'package:cloud_firestore/cloud_firestore.dart';

// class CityModel {
//   final String id;
//   final String name;
//   final Timestamp createdAt;
//   final String governorateId;

//   CityModel({
//     required this.id,
//     required this.name,
//     required this.createdAt,
//     required this.governorateId,
//   });

//   factory CityModel.fromJson(Map<String, dynamic> json, String id) {
//     return CityModel(
//       id: id,
//       name: json['name'],
//       createdAt: json['created_at'] ?? Timestamp.now(),
//       governorateId: json['governorateId'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'name': name,
//     'created_at': createdAt,
//     'governorateId': governorateId,
//   };
// }
