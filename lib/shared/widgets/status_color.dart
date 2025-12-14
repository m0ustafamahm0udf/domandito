
// import 'package:domandito/core/constants/app_constants.dart';
// import 'package:domandito/shared/models/status_info.dart';
// import 'package:domandito/shared/style/app_colors.dart';
// import 'package:flutter/material.dart';

// GetStatuesInfo getStatusColors(String status) {
//   switch (status) {
//     //  TODO : ('pending', 'completed', 'cancelled', 'rejected', 'approved')

//     case AppConstance.pending:
//       return GetStatuesInfo(
//         bgColor: Colors.grey.shade200,
//         textColor: Colors.grey.shade800,
//         textValue: 'قيد الانتظار',
//       );
//     case AppConstance.approved:
//       return GetStatuesInfo(
//         bgColor: AppColors.success69.withOpacity(.2),
//         textColor: AppColors.success86,
//         textValue: 'يتم التجهيز',
//       );

//     case AppConstance.completed:
//       return GetStatuesInfo(
//         bgColor: AppColors.primary,
//         textColor: AppColors.white,
//         textValue: 'مكتمل',
//       );
//     case AppConstance.rejected || AppConstance.canceled:
//       return GetStatuesInfo(
//         bgColor: AppColors.error62.withOpacity(.2),
//         textColor: AppColors.error4e,
//         textValue: 'ملغي',
//       );

//     default:
//       GetStatuesInfo(
//         bgColor: Colors.grey.shade200,
//         textColor: Colors.grey.shade800,
//         textValue: status,
//       );
//   }
//   return GetStatuesInfo(
//     bgColor: Colors.grey.shade200,
//     textColor: Colors.grey.shade800,
//     textValue: status,
//   );
// }
