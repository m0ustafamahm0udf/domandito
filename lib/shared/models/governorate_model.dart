// import 'package:cloud_firestore/cloud_firestore.dart';

// class GovernorateModel {
//   final String id;
//   final String name;
//   final Timestamp createdAt;


//   GovernorateModel({
//     required this.id,
//     required this.name,
//     required this.createdAt,

//   });

//   factory GovernorateModel.fromJson(Map<String, dynamic> json, String id) {
//     return GovernorateModel(
//       id: id,
//       name: json['name'],
//       createdAt: json['created_at'] ?? Timestamp.now(),
 
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'name': name, 'created_at': createdAt};
// }
