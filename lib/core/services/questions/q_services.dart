// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:domandito/core/utils/shared_prefrences.dart';


// class QuestionLikesService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   /// عدد اليوزرز في كل batch
//   final int batchSize;

//   QuestionLikesService({this.batchSize = 100});

//   /// Toggle like for a question
//   Future<void> toggleLike(String questionId) async {
//     final userId = MySharedPreferences.userId;
//     final likesRef = _firestore
//         .collection('questions')
//         .doc(questionId)
//         .collection('likesBatches');

//     // جلب كل الباتشات
//     final batchSnap = await likesRef.get();

//     bool liked = false;

//     for (var doc in batchSnap.docs) {
//       List<dynamic> userIds = doc.data()['userIds'] ?? [];
//       if (userIds.contains(userId)) {
//         // المستخدم موجود → شيل اللايك
//         userIds.remove(userId);
//         await doc.reference.update({'userIds': userIds});
//         liked = true;
//         break;
//       }
//     }

//     if (!liked) {
//       // إضافة اللايك
//       if (batchSnap.docs.isEmpty) {
//         // مفيش batch → إنشاء batch جديد
//         await likesRef.add({
//           'userIds': [userId],
//         });
//       } else {
//         // حاول تضيف في آخر batch
//         final lastBatch = batchSnap.docs.last;
//         List<dynamic> userIds = lastBatch.data()['userIds'] ?? [];
//         if (userIds.length < batchSize) {
//           userIds.add(userId);
//           await lastBatch.reference.update({'userIds': userIds});
//         } else {
//           // Batch ممتلئ → إنشاء batch جديد
//           await likesRef.add({'userIds': [userId]});
//         }
//       }
//     }

//     // تحديث likesCount في doc السؤال نفسه
//     int totalLikes = 0;
//     final updatedSnap = await likesRef.get();
//     for (var doc in updatedSnap.docs) {
//       List<dynamic> ids = doc.data()['userIds'] ?? [];
//       totalLikes += ids.length;
//     }

//     await _firestore
//         .collection('questions')
//         .doc(questionId)
//         .update({'likesCount': totalLikes});
//   }

//   /// جلب اللايكات للسؤال
//   Future<Map<String, dynamic>> getLikesForQuestion(String questionId) async {
//     final userId = MySharedPreferences.userId;
//     final likesRef = _firestore
//         .collection('questions')
//         .doc(questionId)
//         .collection('likesBatches');

//     final batchSnap = await likesRef.get();

//     int likesCount = 0;
//     bool isLiked = false;

//     for (var doc in batchSnap.docs) {
//       List<dynamic> userIds = doc.data()['userIds'] ?? [];
//       likesCount += userIds.length;
//       if (userIds.contains(userId)) {
//         isLiked = true;
//       }
//     }

//     return {
//       'likesCount': likesCount,
//       'isLiked': isLiked,
//     };
//   }
// }
