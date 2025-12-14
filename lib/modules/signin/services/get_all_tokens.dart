// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<List<Map<String, dynamic>>> getAllUserTokens() async {
//   final db = FirebaseFirestore.instance;

//   List<Map<String, dynamic>> allTokens = [];

//   // ندخل على الكولكشن اللي فيه الـ batches
//   final batchesSnapshot =
//       await db
//           .collection('user_notifications')
//           .doc('tokens')
//           .collection('tokens')
//           .get();

//   for (final batchDoc in batchesSnapshot.docs) {
//     // نجيب الليستة من كل batch
//     final data = batchDoc.data();
//     final List<dynamic> usersList = data['users'] ?? [];

//     for (var u in usersList) {
//       if (u is Map<String, dynamic>) {
//         allTokens.add(u);
//       }
//     }
//   }

//   return allTokens;
// }

// Future<List<String>> getAllTokensOnly() async {
//   final users = await getAllUserTokens();
//   return users.map((u) => u['token'] as String).toList();
// }
