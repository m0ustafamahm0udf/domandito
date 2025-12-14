// import 'package:domandito/core/constants/app_constants.dart';
// import 'package:domandito/core/services/file_picker_service.dart';
// import 'package:domandito/core/utils/extentions.dart';
// import 'package:domandito/core/utils/shared_prefrences.dart';
// import 'package:domandito/shared/apis/upload_images_services.dart';
// import 'package:domandito/shared/style/app_colors.dart';
// import 'package:domandito/shared/widgets/custom_network_image.dart';
// import 'package:domandito/shared/widgets/custom_text_field.dart';
// import 'package:domandito/shared/widgets/show_image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
// import 'package:image_picker/image_picker.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();

//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _emailController.text = MySharedPreferences.email;
//     _nameController.text = MySharedPreferences.userName;
//     _phoneController.text = MySharedPreferences.phone;
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     AppConstance().showLoading(context);

//     try {
//       final pickedFilePath = await ImagePickerService.pickFile(
//         source: source,
//         type: FileType.image,
//       );
//       if (pickedFilePath != null) {
//         final url = await UploadImagesToS3Api().uploadFiles(
//           filePath: pickedFilePath,
//           fileName:
//               '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}.png',
//           destinationPath: 'profiles/${MySharedPreferences.userId}',
//         );
//         if (url.isNotEmpty) {
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(MySharedPreferences.userId)
//               .update({'image': url})
//               .then((value) {
//                 // Loader.hide();
//                 AppConstance().showSuccesToast(context, msg: 'تم التعديل');
//                 setState(() {
//                   MySharedPreferences.image = url;
//                 });
//                 Loader.hide();
//                 context.backWithValue(true);

//               });
//         } else {
//           Loader.hide();
//           AppConstance().showErrorToast(
//             context,
//             msg: 'حدث خطاء يرجى المحاولة لاحقا',
//           );
//         }
//       } else {
//         Loader.hide();
//       }
//     } catch (e) {
//       Loader.hide();

//       // log("Error picking image: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

//     return Scaffold(
//        appBar: AppBar(
//         title:  Text('تعديل الحساب'),
//         leading: IconButton.filled(
//           onPressed: () => context.back(),
//           icon: Icon(Icons.arrow_back),
//         ),
       
//       ),
//       resizeToAvoidBottomInset: true,
//       floatingActionButton: isKeyboardOpen
//           ? TextButton(
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 // foregroundColor: Colors.white,
//               ),
//               onPressed: () {
//                 FocusScope.of(context).unfocus(); // يقفل الكيبورد
//               },
//               child: Text("تم"),
//             )
//           : null,
//       floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // CustomAppbar(title: 'تعديل الحساب'),

//               Expanded(
//                 child: ListView(
//                   padding: EdgeInsets.zero,
//                   children: [
//                     SizedBox(height: AppConstance.vPaddingBig * 2),
//                     if (MySharedPreferences.image.isNotEmpty)
//                       Center(
//                         child: GestureDetector(
//                           onTap: () async {
//                             final source =
//                                 await showModalBottomSheet<ImageSource>(
//                                   useRootNavigator: true,
//                                   routeSettings: RouteSettings(
//                                     name: 'ImagePickerSheet',
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.only(
//                                       topLeft: Radius.circular(
//                                         AppConstance.radiusBig,
//                                       ),
//                                       topRight: Radius.circular(
//                                         AppConstance.radiusBig,
//                                       ),
//                                     ),
//                                   ),
//                                   context: context,
//                                   builder: (BuildContext context) =>
//                                       const ImagePickerSheet(),
//                                 );

//                             if (source != null) {
//                               await _pickImage(source);
//                             }
//                           },
//                           child: CustomNetworkImage(
//                             url: MySharedPreferences.image,
//                             radius: 999,
//                             height: 160,
//                             width: 160,
//                           ),
//                         ),
//                       )
//                     else
//                       Center(
//                         child: GestureDetector(
//                           onTap: () async {
//                             final source =
//                                 await showModalBottomSheet<ImageSource>(
//                                   useRootNavigator: true,
//                                   routeSettings: RouteSettings(
//                                     name: 'ImagePickerSheet',
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.only(
//                                       topLeft: Radius.circular(
//                                         AppConstance.radiusBig,
//                                       ),
//                                       topRight: Radius.circular(
//                                         AppConstance.radiusBig,
//                                       ),
//                                     ),
//                                   ),
//                                   context: context,
//                                   builder: (BuildContext context) =>
//                                       const ImagePickerSheet(),
//                                 );

//                             if (source != null) {
//                               await _pickImage(source);
//                             }
//                           },
//                           child: CircleAvatar(
//                             backgroundColor: AppColors.primary,
//                             radius: 80,
//                             child: Padding(
//                               padding: const EdgeInsets.only(top: 4),
//                               child: Text(
//                                 MySharedPreferences.userName.isNotEmpty
//                                     ? MySharedPreferences.userName[0]
//                                           .toUpperCase()
//                                     : '?',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 50,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),

//                     SizedBox(height: AppConstance.vPaddingBig),
//                     Center(
//                       child: CustomTextField(
//                         readOnly: true,
//                         padding: AppConstance.hPadding,
//                         controller: _emailController,
//                         label: 'البريد الالكتروني',
//                       ),
//                     ),
//                     // SizedBox(height: AppConstance.gap),
//                     // Center(
//                     //   child: CustomTextField(
//                     //     suffixIcon: MySharedPreferences.isVerified
//                     //         ? Padding(
//                     //             padding: const EdgeInsets.only(left: 20),
//                     //             child: SvgPicture.asset(
//                     //               AppIcons.verified,
//                     //               color: AppColors.primary,
//                     //             ),
//                     //           )
//                     //         : null,
//                     //     padding: AppConstance.hPadding,
//                     //     controller: _nameController,
//                     //     label: 'اسم المستخدم',
//                     //     validator: (value) {
//                     //       if (value!.isEmpty || value.trim().length < 4) {
//                     //         return 'مطلوب';
//                     //       }
//                     //       return null;
//                     //     },
//                     //   ),
//                     // ),
//                     SizedBox(height: AppConstance.gap),
//                     // Center(
//                     //   child: CustomTextField(
//                     //     padding: AppConstance.hPadding,
//                     //     controller: _phoneController,
//                     //     keyboardType: TextInputType.number,
//                     //     suffixIcon: Text('🇪🇬'),
//                     //     inputFormatters: [
//                     //       FilteringTextInputFormatter.digitsOnly,
//                     //       LengthLimitingTextInputFormatter(11),
//                     //     ],
//                     //     label: 'رقم التليفون',
//                     //     validator: (value) {
//                     //       if (value!.length != 11) {
//                     //         return 'خطأ في رقم التليفون';
//                     //       }
//                     //       if (!value.startsWith('01')) {
//                     //         return 'خطأ في رقم التليفون';
//                     //       }
//                     //       return null;
//                     //     },
//                     //   ),
//                     // ),
//                     SizedBox(height: 20), // مساحة تحت عشان الـ FAB
//                     // BounceButton(
//                     //   padding: AppConstance.hPadding,
//                     //   onPressed: () async {
//                     //     // if (_formKey.currentState!.validate()) {
//                     //     //   AppConstance().showLoading(context);
//                     //     //   final phoneExists = await AddUserToFirestore()
//                     //     //       .isPhoneUsed(
//                     //     //         _phoneController.text.trim(),
//                     //     //         MySharedPreferences.userId,
//                     //     //       );

//                     //     //   if (phoneExists) {
//                     //     //     AppConstance().showErrorToast(
//                     //     //       context,
//                     //     //       msg: 'هذا الرقم مسجل بالفعل',
//                     //     //     );
//                     //     //     Loader.hide();
//                     //     //     return; // وقف التسجيل
//                     //     //   }

//                     //     //   await FirebaseFirestore.instance
//                     //     //       .collection('users')
//                     //     //       .doc(MySharedPreferences.userId)
//                     //     //       .update({
//                     //     //         'name': _nameController.text.trim(),
//                     //     //         'phone': _phoneController.text.trim(),
//                     //     //         'name_keywords': generateSearchKeywords(
//                     //     //           _nameController.text.trim(),
//                     //     //         ),
//                     //     //       })
//                     //     //       .then((value) async {
//                     //     //         MySharedPreferences.isEditProfile = true;
//                     //     //         MySharedPreferences.userName =
//                     //     //             _nameController.text;
//                     //     //         MySharedPreferences.phone =
//                     //     //             _phoneController.text;
//                     //     //         MySharedPreferences.isVerified = false;
//                     //     //         await saveUserNotificationToken(
//                     //     //           userId: MySharedPreferences.userId,
//                     //     //           name: MySharedPreferences.userName,
//                     //     //           token: MySharedPreferences.deviceToken,
//                     //     //         );
//                     //     //         AppConstance().showSuccesToast(
//                     //     //           context,
//                     //     //           msg: 'تم التعديل',
//                     //     //         );
//                     //     //         context.toAndRemoveAll(LandingScreen());
//                     //     //         Loader.hide();
//                     //     //         // context.back();
//                     //     //       })
//                     //     //       .onError((error, stackTrace) {
//                     //     //         Loader.hide();
//                     //     //         AppConstance().showErrorToast(
//                     //     //           context,
//                     //     //           msg: 'حدث خطاء يرجى المحاولة لاحقا',
//                     //     //         );
//                     //     //       });
//                     //     // }
//                     //   },
//                     //   title: 'تأكيد',
//                     // ),
//                     SizedBox(height: 20), // مساحة تحت عشان الـ FAB
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           // child: SingleChildScrollView(
//           //   child: ConstrainedBox(
//           //     constraints: BoxConstraints(
//           //       minHeight: MediaQuery.of(context).size.height,
//           //     ),
//           //     child: IntrinsicHeight(
//           //       child: Column(
//           //         children: [
//           //           CustomAppbar(title: 'تعديل الحساب'),
//           //           SizedBox(height: AppConstance.vPaddingBig * 2),
//           //           if (MySharedPreferences.image.isNotEmpty)
//           //             GestureDetector(
//           //               onTap: () async {
//           //                 final source =
//           //                     await showModalBottomSheet<ImageSource>(
//           //                       // isDismissible: false,
//           //                       // enableDrag: false,
//           //                       useRootNavigator: true,
//           //                       routeSettings: RouteSettings(
//           //                         name: 'ImagePickerSheet',
//           //                       ),
//           //                       shape: RoundedRectangleBorder(
//           //                         borderRadius: BorderRadius.only(
//           //                           topLeft: Radius.circular(
//           //                             AppConstance.radiusBig,
//           //                           ),
//           //                           topRight: Radius.circular(
//           //                             AppConstance.radiusBig,
//           //                           ),
//           //                         ),
//           //                       ),
//           //                       context: context,
//           //                       builder:
//           //                           (BuildContext context) =>
//           //                               const ImagePickerSheet(),
//           //                     );

//           //                 if (source != null) {
//           //                   await _pickImage(source);
//           //                 }
//           //               },
//           //               child: CustomNetworkImage(
//           //                 url: MySharedPreferences.image,
//           //                 radius: 999,
//           //                 height: 160,
//           //                 width: 160,
//           //               ),
//           //             )
//           //           else
//           //             GestureDetector(
//           //               onTap: () async {
//           //                 final source =
//           //                     await showModalBottomSheet<ImageSource>(
//           //                       // isDismissible: false,
//           //                       // enableDrag: false,
//           //                       useRootNavigator: true,
//           //                       routeSettings: RouteSettings(
//           //                         name: 'ImagePickerSheet',
//           //                       ),
//           //                       shape: RoundedRectangleBorder(
//           //                         borderRadius: BorderRadius.only(
//           //                           topLeft: Radius.circular(
//           //                             AppConstance.radiusBig,
//           //                           ),
//           //                           topRight: Radius.circular(
//           //                             AppConstance.radiusBig,
//           //                           ),
//           //                         ),
//           //                       ),
//           //                       context: context,
//           //                       builder:
//           //                           (BuildContext context) =>
//           //                               const ImagePickerSheet(),
//           //                     );

//           //                 if (source != null) {
//           //                   await _pickImage(source);
//           //                 }
//           //               },
//           //               child: CircleAvatar(
//           //                 backgroundColor: AppColors.primary,
//           //                 radius: 80,
//           //                 child: Padding(
//           //                   padding: const EdgeInsets.only(top: 4),
//           //                   child: Text(
//           //                     MySharedPreferences.userName.isNotEmpty
//           //                         ? MySharedPreferences.userName[0]
//           //                             .toUpperCase()
//           //                         : '?', // Fallback in case the name is empty
//           //                     style: TextStyle(
//           //                       color: Colors.white,
//           //                       fontSize: 50,
//           //                     ),
//           //                   ),
//           //                 ),
//           //               ),
//           //             ),
//           //           SizedBox(height: AppConstance.vPaddingBig),
//           //           Center(
//           //             child: CustomTextField(
//           //               readOnly: true,
//           //               padding: AppConstance.hPadding,
//           //               controller: _emailController,
//           //               label: 'البريد الالكتروني',
//           //             ),
//           //           ),
//           //           SizedBox(height: AppConstance.gap),

//           //           Center(
//           //             child: CustomTextField(
//           //               padding: AppConstance.hPadding,
//           //               controller: _nameController,
//           //               label: 'اسم المستخدم',
//           //               validator: (value) {
//           //                 if (value!.isEmpty || value.trim().length < 4) {
//           //                   return 'مطلوب';
//           //                 }
//           //                 return null;
//           //               },
//           //             ),
//           //           ),
//           //           SizedBox(height: AppConstance.gap),
//           //           Center(
//           //             child: CustomTextField(
//           //               padding: AppConstance.hPadding,
//           //               controller: _phoneController,
//           //               keyboardType: TextInputType.number,
//           //               suffixIcon: Text('🇪🇬'),
//           //               inputFormatters: [
//           //                 FilteringTextInputFormatter.digitsOnly,
//           //                 LengthLimitingTextInputFormatter(11),
//           //               ],
//           //               label: 'رقم التليفون',
//           //               validator: (value) {
//           //                 if (value!.length != 11) {
//           //                   return 'خطأ في رقم التليفون';
//           //                 }
//           //                 if (!value.startsWith('01')) {
//           //                   return 'خطأ في رقم التليفون';
//           //                 }

//           //                 return null;
//           //               },
//           //             ),
//           //           ),
//           //         ],
//           //       ),
//           //     ),
//           //   ),
//           // ),
//         ),
//       ),
//       // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       // floatingActionButton: BounceButton(
//       //   padding: AppConstance.hPaddingBig,
//       //   onPressed: () async {
//       //     if (_formKey.currentState!.validate()) {
//       //       AppConstance().showLoading(context);
//       //       final phoneExists = await AddUserToFirestore().checkIfPhoneExists(
//       //         _phoneController.text.trim(),
//       //         MySharedPreferences.userId,
//       //       );

//       //       if (phoneExists) {
//       //         AppConstance().showErrorToast(
//       //           context,
//       //           msg: 'هذا الرقم مسجل بالفعل',
//       //         );
//       //         Loader.hide();
//       //         return; // وقف التسجيل
//       //       }

//       //       await FirebaseFirestore.instance
//       //           .collection('users')
//       //           .doc(MySharedPreferences.userId)
//       //           .update({
//       //             'name': _nameController.text.trim(),
//       //             'phone': _phoneController.text.trim(),
//       //             'name_keywords': generateSearchKeywords(
//       //               _nameController.text.trim(),
//       //             ),
//       //           })
//       //           .then((value) async {
//       //             MySharedPreferences.isEditProfile = true;
//       //             MySharedPreferences.userName = _nameController.text;
//       //             MySharedPreferences.phone = _phoneController.text;
//       //             MySharedPreferences.isVerified = _phoneController.text.trim() == MySharedPreferences.phone;
//       //             await saveUserNotificationToken(
//       //               userId: MySharedPreferences.userId,
//       //               name: MySharedPreferences.userName,
//       //               token: MySharedPreferences.deviceToken,
//       //             );
//       //             AppConstance().showSuccesToast(context, msg: 'تم التعديل');
//       //             context.toAndRemoveAll(LandingScreen());
//       //             Loader.hide();
//       //             // context.back();
//       //           })
//       //           .onError((error, stackTrace) {
//       //             Loader.hide();
//       //             AppConstance().showErrorToast(
//       //               context,
//       //               msg: 'حدث خطاء يرجى المحاولة لاحقا',
//       //             );
//       //           });
//       //     }
//       //   },
//       //   title: 'تأكيد',
//       // ),
//     );
//   }
// }
