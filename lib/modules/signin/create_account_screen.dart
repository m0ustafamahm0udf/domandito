import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/landing/views/landing_screen.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:domandito/modules/signin/services/add_user_to_supabase.dart';
import 'package:domandito/modules/signin/widgets/create_account_button.dart';
import 'package:domandito/modules/signin/widgets/create_account_form.dart';
import 'package:domandito/modules/signin/widgets/create_account_terms.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:uuid/uuid.dart';

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

  bool _agreeToTerms = false;
  String? _termsError;

  saveNewUser() async {
    if (!_agreeToTerms) {
      setState(() {
        _termsError = context.isCurrentLanguageAr()
            ? 'يجب الموافقة على الشروط والأحكام أولاً'
            : 'You must agree to the Terms & Conditions';
      });
      return;
    }

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

      final String? res = await AddUserToSupabase().validatePhoneAndUsername(
        context: context,
        phone: phoneCtrl.text.trim(),
        username: userNameCtrl.text.trim(),
        email: widget.newUser.email,
      );
      if (res == null) {
        final uuid = const Uuid().v4();
        final userData = {
          'created_at': DateTime.now().toString(),
          'name': nameCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'id': uuid, // Generating a new UUID for Supabase
          'image': widget.newUser.image,
          'provider': widget.newUser.provider,
          'email': widget.newUser.email,
          'token': widget.newUser.token,
          // 'upload': false,
          // 'points': 0,
          'is_blocked': false,
          // 'can_book': true,
          // 'name_keywords': generateSearchKeywords(nameCtrl.text.trim()),
          'is_verified': widget.newUser.isVerified,
          'username': userNameCtrl.text.trim(),
          'app_version': AppConstance.appVersion,
          'followers_count': 0,
          'following_count': 0,
          'posts_count': 0,
          'can_asked_anonymously': true,
          'bio': '',
        };

        await AddUserToSupabase().saveUser(userData).then((_) async {
          if (!kIsWeb) {
            //  TODO: send notification
            await FirebaseMessaging.instance.subscribeToTopic('allUsers');
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
          MySharedPreferences.userId = uuid; // Saving the new Supabase ID
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
                        CreateAccountForm(
                          nameCtrl: nameCtrl,
                          userNameCtrl: userNameCtrl,
                          phoneCtrl: phoneCtrl,
                        ),
                        CreateAccountTerms(
                          agreeToTerms: _agreeToTerms,
                          termsError: _termsError,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                              _termsError = null;
                            });
                          },
                        ),
                        const SizedBox(height: 50),
                        CreateAccountButton(
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
      ),
    );
  }
}
