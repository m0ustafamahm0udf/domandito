import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/landing/views/landing_screen.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:domandito/modules/signin/services/add_user_to_firestore.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_bounce_button.dart';
import 'package:domandito/shared/widgets/custom_text_field.dart';
import 'package:domandito/shared/widgets/phone_number_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class CreateAccountScreen extends StatefulWidget {
  final UserModel newUser;
  const CreateAccountScreen({super.key, required this.newUser});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final nameCtrl = TextEditingController();
  final userNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    nameCtrl.text = widget.newUser.name.contains('null')
        ? ''
        : widget.newUser.name;
    userNameCtrl.text = widget.newUser.userName.contains('null')
        ? ''
        : widget.newUser.userName;
    phoneCtrl.text = widget.newUser.phone;
  }

  // final reservedUsernames = {
  //   "anonymous",
  //   "hidden",
  //   "admin",
  //   "support",
  //   "root",
  //   "system",
  //   "user",
  //   "profile",
  //   "owner",
  //   "manager",
  //   "test",
  //   "q", // علشان متدخلش في الروت بتاع السؤال
  //   "question",
  //   "null",
  // };

  saveNewUser() async {
    if (_formKey.currentState!.validate()) {
      AppConstance().showLoading(context);

      if (!await hasInternetConnection()) {
        AppConstance().showInfoToast(
          context,
          msg: !context.isCurrentLanguageAr()
              ? 'No internet connection'
              : 'لا يوجد اتصال بالانترنت',
        );
        Loader.hide();
        return;
      }

      final String? res = await AddUserToFirestore().validatePhoneAndUsername(
        context: context,
        phone: phoneCtrl.text.trim(),
        username: userNameCtrl.text.trim(),
        currentUserId: widget.newUser.id,
        email: widget.newUser.email,
      );
      if (res == null) {
        final userData = {
          'createdAt': Timestamp.now(),
          'name': nameCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'id': widget.newUser.id,
          'image': widget.newUser.image,
          'provider': widget.newUser.provider,
          'email': widget.newUser.email,
          'token': widget.newUser.token,
          'upload': false,
          'points': 0,
          'isBlocked': false,
          'canBook': true,
          'name_keywords': generateSearchKeywords(nameCtrl.text.trim()),
          'isVerified': widget.newUser.isVerified,
          'userName': userNameCtrl.text.trim(),
          'appVersion': AppConstance.appVersion,
          'followersCount': 0,
          'followingCount': 0,
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.newUser.id)
            .set(userData)
            .then((_) async {
              if (!kIsWeb) {
                //  TODO: send notification
                // await FirebaseMessaging.instance.subscribeToTopic('allUsers');
              }
              // await saveUserNotificationToken(
              //   userId: widget.newUser.id,
              //   name: widget.newUser.name,
              //   token: widget.newUser.token,
              // );
              // AppConstance().showSuccesToast(
              //   context,
              //   msg: 'أهلا ${widget.newUser.name}',
              // );

              MySharedPreferences.isLoggedIn = true;
              MySharedPreferences.userUserName = userNameCtrl.text.trim();
              MySharedPreferences.userName = nameCtrl.text.trim();
              MySharedPreferences.phone = phoneCtrl.text.trim();
              MySharedPreferences.userId = widget.newUser.id;
              MySharedPreferences.email = widget.newUser.email;
              MySharedPreferences.image = widget.newUser.image;
              MySharedPreferences.deviceToken = widget.newUser.token;
              MySharedPreferences.isVerified = widget.newUser.isVerified;

              context.toAndRemoveAll(LandingScreen());
              Loader.hide();
            });
      } else {
        AppConstance().showInfoToast(context, msg: res);
        Loader.hide();

        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return PopScope(
      // canPop: false,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
        floatingActionButton: isKeyboardOpen
            ? TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  // foregroundColor: Colors.white,
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus(); // يقفل الكيبورد
                },
                child: Text(
                  context.isCurrentLanguageAr() ? "تم" : 'Done',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : null,
        appBar: AppBar(
          title: Text(
            context.isCurrentLanguageAr() ? 'إنشاء حساب' : 'Create Account',
          ),
          leading: IconButton.filled(
            onPressed: () => context.back(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              // CustomAppbar(
              //   isColored: true,
              //   title: 'أكمل البيانات',
              //   subTitle:
              //       'يرجى  إستكمال البيانات حتى تتمكن من تسجيل حساب جديد ',
              // ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppConstance.hPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        Text(
                          context.isCurrentLanguageAr() ? 'الإسم' : 'Name',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),

                        CustomTextField(
                          controller: nameCtrl,
                          hintText: !context.isCurrentLanguageAr()
                              ? 'eg: Ahmed'
                              : 'مثال: أحمد',
                          // label: 'اسم الإعلان',
                          validator: (value) => value == null || value.isEmpty
                              ? !context.isCurrentLanguageAr()
                                    ? 'Please enter your name'
                                    : 'الرجاء ادخال الإسم'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          !context.isCurrentLanguageAr()
                              ? 'User Name'
                              : 'اسم المستخدم',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        CustomTextField(
                          suffixIcon: Text('@'),
                          controller: userNameCtrl,
                          // label: 'الوصف التفصيلي',
                          hintText: !context.isCurrentLanguageAr()
                              ? 'eg: ahmed'
                              : 'مثال: ahmed',

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return !context.isCurrentLanguageAr()
                                  ? 'Please enter username'
                                  : 'الرجاء إدخال اسم المستخدم';
                            }
                            // قائمة الأسماء المحجوزة
                            final reservedUsernames = {
                              "anonymous",
                              "hidden",
                              "admin",
                              "support",
                              "root",
                              "system",
                              "user",
                              "profile",
                              "owner",
                              "manager",
                              "test",
                              "q",
                              "question",
                              "null",
                            };

                            final username = value.trim().toLowerCase();

                            // التشيك على الأسماء المحجوزة
                            if (reservedUsernames.contains(username)) {
                              return !context.isCurrentLanguageAr()
                                  ? 'Username is not available, please choose another username'
                                  : "اسم المستخدم غير متاح، برجاء اختيار اسم آخر";
                            }

                            final regex = RegExp(
                              r'^[a-zA-Z][a-zA-Z0-9_.]{5,}$',
                            );
                            if (!regex.hasMatch(value)) {
                              return !context.isCurrentLanguageAr()
                                  ? 'Username must start with an English letter\nand contain only English letters, numbers, and _ characters,\nwith a minimum length of 6 characters'
                                  : 'اسم المستخدم يجب أن يبدأ بحرف إنجليزي\n'
                                        'ويحتوي على حروف إنجليزية وأرقام و _ فقط\n'
                                        'وبحد أدنى 6 خانات';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        Text(
                          !context.isCurrentLanguageAr()
                              ? 'Phone Number (Optional)'
                              : 'رقم الهاتف (اختياري)',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),

                        PhoneNumberTextField(phoneCtrl: phoneCtrl),
                        const SizedBox(height: 50),
                        BounceButton(
                          radius: 60,

                          gradient: LinearGradient(
                            colors: [AppColors.primary, Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          padding: 0,
                          title: !context.isCurrentLanguageAr()
                              ? 'Create Account'
                              : 'إنشاء حساب',
                          onPressed: () async {
                            await saveNewUser();
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
