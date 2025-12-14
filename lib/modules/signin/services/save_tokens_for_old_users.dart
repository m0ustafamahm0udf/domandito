// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<void> syncAllUsersToNotificationTokens() async {
//   final firestore = FirebaseFirestore.instance;

//   final usersSnapshot = await firestore.collection('users').get();

//   if (usersSnapshot.docs.isEmpty) {
//     // print("No users found to sync.");
//     return;
//   }

//   final collectionRef = firestore
//       .collection('user_notifications')
//       .doc('tokens')
//       .collection('tokens');

//   await firestore.runTransaction((transaction) async {
//     // هجيب كل الدوكيومنتات الموجودة في tokens
//     final tokensSnapshots = await collectionRef.get();
//     tokensSnapshots.docs.sort((a, b) => a.id.compareTo(b.id));

//     // هخزن الداتا الحالية في ماب (id -> docIndex)
//     final Map<String, int> existingUsersMap = {};
//     final List<List<Map<String, dynamic>>> batches = [];

//     for (int i = 0; i < tokensSnapshots.docs.length; i++) {
//       final data = tokensSnapshots.docs[i].data();
//       final tokensList =
//           (data['tokens'] as List?)?.cast<Map<String, dynamic>>() ?? [];
//       batches.add(tokensList);

//       for (int j = 0; j < tokensList.length; j++) {
//         final user = tokensList[j];
//         existingUsersMap[user['id']] = i; // بيربط userId بال batch index
//       }
//     }

//     // لو مفيش ولا batch موجود نبدأ بـ batch_1
//     if (batches.isEmpty) {
//       batches.add([]);
//     }

//     for (final userDoc in usersSnapshot.docs) {
//       final userData = userDoc.data();
//       final userId = userDoc.id;
//       final userName = userData['name'] ?? 'Unknown';
//       final userToken =
//           userData['token'] ?? ''; // تأكد عندك في users فين التوكن

//       final userMap = {'id': userId, 'name': userName, 'token': userToken};

//       if (existingUsersMap.containsKey(userId)) {
//         // موجود بالفعل → نعمل update في نفس الـ batch
//         final batchIndex = existingUsersMap[userId]!;
//         final index = batches[batchIndex].indexWhere((u) => u['id'] == userId);
//         if (index != -1) {
//           batches[batchIndex][index] = userMap;
//         }
//       } else {
//         // جديد → نضيفه في آخر batch لو فيها مكان
//         if (batches.last.length >= 2000) {
//           batches.add([]);
//         }
//         batches.last.add(userMap);
//       }
//     }

//     // بعد ما خلصنا نكتب الـ batches كلها
//     for (int i = 0; i < batches.length; i++) {
//       final targetDoc = collectionRef.doc('batch_${i + 1}');
//       transaction.set(targetDoc, {'tokens': batches[i]});
//     }
//   });

//   // print("✅ All users synced successfully to notification tokens.");
// }
