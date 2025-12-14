// import 'package:domandito/modules/ask/models/q_model.dart';

// class QuestionState {
//   final QuestionModel question;
//   final bool isLiked;
//   final int likesCount;
//   final bool isVerified;
//   final bool isProcessing;
//   final bool isVerifiedLoaded;
//   QuestionState({
//     required this.question,
//     this.isLiked = false,
//     int? likesCount,
//     this.isVerified = false,
//     this.isProcessing = false,
//     this.isVerifiedLoaded = false,
//   }) : likesCount = likesCount ?? question.likesCount;

//   QuestionState copyWith({
//     QuestionModel? question,
//     bool? isLiked,
//     int? likesCount,
//     bool? isVerified,
//     bool? isProcessing,
//     bool? isVerifiedLoaded,
//   }) {
//     return QuestionState(
//       question: question ?? this.question,
//       isLiked: isLiked ?? this.isLiked,
//       likesCount: likesCount ?? this.likesCount,
//       isVerified: isVerified ?? this.isVerified,
//       isProcessing: isProcessing ?? this.isProcessing,
//       isVerifiedLoaded: isVerifiedLoaded ?? this.isVerifiedLoaded,
//     );
//   }
// }
