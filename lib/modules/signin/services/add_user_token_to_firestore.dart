// // import 'package:cloud_firestore/cloud_firestore.dart';

// // Future<void> saveUserNotificationToken({
// //   required String userId,
// //   required String name,
// //   required String token,
// // }) async {
// //   final collectionRef = FirebaseFirestore.instance
// //       .collection('user_notifications')
// //       .doc('tokens')
// //       .collection('tokens');

// //   final userMap = {'id': userId, 'name': name, 'token': token};

// //   await FirebaseFirestore.instance.runTransaction((transaction) async {
// //     final snapshots = await collectionRef.get();

// //     DocumentReference? targetDoc;
// //     List<dynamic> tokensList = [];

// //     if (snapshots.docs.isEmpty) {
// //       targetDoc = collectionRef.doc('batch_1');
// //       tokensList = [];
// //     } else {
// //       snapshots.docs.sort((a, b) => a.id.compareTo(b.id));
// //       final lastDocSnap = snapshots.docs.last;
// //       final lastDocRef = lastDocSnap.reference;

// //       final lastDocData = await transaction.get(lastDocRef);
// //       tokensList = (lastDocData.data())?['tokens'] ?? [];

// //       if (tokensList.length >= 250) {
// //         final newBatchIndex = snapshots.docs.length + 1;
// //         targetDoc = collectionRef.doc('batch_$newBatchIndex');
// //         tokensList = [];
// //       } else {
// //         targetDoc = lastDocRef;
// //       }
// //     }

// //     // نبحث لو المستخدم موجود
// //     final index = tokensList.indexWhere((u) => u['id'] == userId);

// //     if (index == -1) {
// //       tokensList.add(userMap);
// //     } else {
// //       tokensList[index] = userMap;
// //     }

// //     transaction.set(targetDoc, {'tokens': tokensList});
// //   });
// // }


// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<void> saveUserNotificationToken({
//   required String userId,
//   required String name,
//   required String token,
// }) async {
//   final collectionRef = FirebaseFirestore.instance
//       .collection('user_notifications')
//       .doc('tokens')
//       .collection('tokens');

//   final userMap = {'id': userId, 'name': name, 'token': token};

//   await FirebaseFirestore.instance.runTransaction((transaction) async {
//     // نجيب آخر batch بس بدل كل الكولكشن
//     final snapshots = await collectionRef
//         .orderBy(FieldPath.documentId, descending: true)
//         .limit(1)
//         .get();

//     DocumentReference targetDoc;
//     List<dynamic> tokensList = [];

//     if (snapshots.docs.isEmpty) {
//       // مفيش batches → نبدأ من batch_1
//       targetDoc = collectionRef.doc('batch_1');
//       tokensList = [];
//     } else {
//       final lastDocSnap = snapshots.docs.first;
//       final lastDocRef = lastDocSnap.reference;

//       final lastDocData = await transaction.get(lastDocRef);
//       tokensList = (lastDocData.data()?['tokens'] as List?) ?? [];

//       if (tokensList.length >= 250) {
//         // آخر batch مليان → نفتح batch جديد
//         final newBatchIndex =
//             int.parse(lastDocRef.id.split('_').last) + 1; // نستخرج الرقم ونزود 1
//         targetDoc = collectionRef.doc('batch_$newBatchIndex');
//         tokensList = [];
//       } else {
//         // لسه فيه مكان → نكمل عليه
//         targetDoc = lastDocRef;
//       }
//     }

//     // نشوف لو المستخدم موجود ونحدثه
//     final index = tokensList.indexWhere((u) => u['id'] == userId);

//     if (index == -1) {
//       tokensList.add(userMap);
//     } else {
//       tokensList[index] = userMap;
//     }

//     transaction.set(targetDoc, {'tokens': tokensList});
//   });
// }
