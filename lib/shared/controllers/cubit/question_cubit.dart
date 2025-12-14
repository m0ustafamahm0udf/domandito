// import 'dart:developer';
// import 'package:bloc/bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:domandito/core/constants/app_constants.dart';
// import 'package:domandito/core/utils/shared_prefrences.dart';
// import 'package:domandito/core/utils/utils.dart';
// import 'package:domandito/shared/models/like_model.dart';
// import 'package:domandito/shared/services/like_service.dart';
// import 'package:flutter/material.dart';
// import 'question_state.dart';

// class QuestionCubit extends Cubit<QuestionState> {
//   QuestionCubit(QuestionState initialState) : super(initialState) {
//     _init();
//   }

//   void _init() {
//     checkIfLiked();
//     loadUserVerification();
//   }

//   Future<void> checkIfLiked() async {
//     if (!MySharedPreferences.isLoggedIn) return;

//     final liked = await LikeService.isLiked(
//       questionId: state.question.id,
//       userId: MySharedPreferences.userId,
//     );
//     emit(state.copyWith(isLiked: liked));
//   }

//   Future<void> toggleLike({required BuildContext context}) async {
//     if (!MySharedPreferences.isLoggedIn) {
//       AppConstance().showInfoToast(
//         context,
//         msg: 'يرجى تسجيل الدخول',
//         isLogin: true,
//       );
//       return;
//     }

//     if (!await hasInternetConnection()) {
//       AppConstance().showInfoToast(context, msg: 'لا يوجد اتصال بالانترنت');
//       return;
//     }

//     if (state.isProcessing) return;

//     emit(state.copyWith(isProcessing: true));

//     final result = await LikeService.toggleLike(
//       context: context,
//       questionId: state.question.id,
//       user: LikeUser(
//         id: MySharedPreferences.userId,
//         name: MySharedPreferences.userName,
//         userName: MySharedPreferences.userUserName,
//         image: MySharedPreferences.image,
//       ),
//     );

//     emit(
//       state.copyWith(
//         isLiked: result,
//         likesCount: state.likesCount + (result ? 1 : -1),
//         question: state.question..likesCount += (result ? 1 : -1),
//         isProcessing: false,
//       ),
//     );
//   }

//   Future<void> loadUserVerification() async {
//     // لو الداتا متحملة قبل كده متعملش request جديد
//     if (state.isVerifiedLoaded) return;

//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(state.question.sender.id)
//           .get();

//       final isVerified = doc.data()?['isVerified'] ?? false;
// log('isVerified: $isVerified');
//       // نحدد ان الداتا اتحملت
//       emit(state.copyWith(isVerified: isVerified, isVerifiedLoaded: true));
//     } catch (e) {
//       emit(state.copyWith(isVerified: false, isVerifiedLoaded: true));
//     }
//   }
// }
