import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/signin/services/add_user_to_supabase.dart';
import 'package:domandito/modules/signin/widgets/create_account_button.dart';
import 'package:domandito/modules/signin/widgets/create_account_form.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domandito/shared/apis/upload_images_services.dart';
import 'package:domandito/core/services/file_picker_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:domandito/shared/services/crop_image_service.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:domandito/shared/widgets/show_image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameCtrl = TextEditingController();
  final userNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  File? _imageFile;
  String? _currentImageUrl;
  bool _canAskedAnonymously = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    nameCtrl.text = MySharedPreferences.userName;
    userNameCtrl.text = MySharedPreferences.userUserName;
    phoneCtrl.text = MySharedPreferences.phone;
    bioCtrl.text = MySharedPreferences.bio;
    emailCtrl.text = MySharedPreferences.email;
    _currentImageUrl = MySharedPreferences.image;
    _canAskedAnonymously = MySharedPreferences.canAskedAnonymously;
    setState(() {});
  }

  Future<void> _pickImage(ImageSource source) async {
    // AppConstance().showLoading(context);

    try {
      final pickedFilePath = await ImagePickerService.pickFile(
        source: source,
        type: FileType.image,
      );
      if (pickedFilePath != null) {
        final croppedPath = await ImageCropService.cropImage(
          filePath: pickedFilePath,
        );
        if (croppedPath == null) {
          // Loader.hide();
          return;
        }

        setState(() {
          _imageFile = File(croppedPath);
        });
      }
      // Loader.hide();
    } catch (e) {
      debugPrint("Error picking image: $e");
      // Loader.hide();
    }
  }

  Future<void> _showImageSourceDialog() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => const ImagePickerSheet(),
    );

    if (source != null) {
      _pickImage(source);
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final url = await UploadImagesToS3Api().uploadFiles(
        filePath: image.path,
        fileName:
            '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}.png',
        destinationPath: 'profiles/${MySharedPreferences.userId}',
      );
      if (url.isEmpty) return null;
      return url;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _updateProfile() async {
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

      // 1. Validate Uniqueness (excluding current user ID)
      final String? res = await AddUserToSupabase().validatePhoneAndUsername(
        context: context,
        phone: phoneCtrl.text.trim(),
        username: userNameCtrl.text.trim(),
        email: emailCtrl.text.trim(), // Check email too just in case
        currentUserId: MySharedPreferences.userId,
      );

      if (res != null) {
        AppConstance().showInfoToast(context, msg: res);
        Loader.hide();
        return;
      }

      try {
        String? newImageUrl;
        // 2. Upload Image if changed
        if (_imageFile != null) {
          // Upload to S3
          newImageUrl = await _uploadImage(_imageFile!);
          if (newImageUrl == null) {
            AppConstance().showInfoToast(
              context,
              msg: context.isCurrentLanguageAr()
                  ? 'فشل رفع الصورة'
                  : 'Failed to upload image',
            );
            Loader.hide();
            return;
          }
        }

        final updateData = {
          'name': nameCtrl.text.trim(),
          'username': userNameCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'bio': bioCtrl.text.trim(),
          'can_asked_anonymously': _canAskedAnonymously,
          if (newImageUrl != null) 'image': newImageUrl,
        };

        await Supabase.instance.client
            .from('users')
            .update(updateData)
            .eq('id', MySharedPreferences.userId);

        // 3. Update Shared Preferences
        MySharedPreferences.userName = nameCtrl.text.trim();
        MySharedPreferences.userUserName = userNameCtrl.text.trim();
        MySharedPreferences.phone = phoneCtrl.text.trim();
        MySharedPreferences.bio = bioCtrl.text.trim();
        MySharedPreferences.canAskedAnonymously = _canAskedAnonymously;
        if (newImageUrl != null) {
          MySharedPreferences.image = newImageUrl;
        }

        AppConstance().showSuccesToast(
          context,
          msg: context.isCurrentLanguageAr()
              ? 'تم تحديث البيانات بنجاح'
              : 'Profile updated successfully',
        );

        Loader.hide();
        context.backWithValue(
          true,
        ); // Return to previous screen with success flag
      } catch (e) {
        debugPrint('Error updating profile: $e');
        AppConstance().showInfoToast(
          context,
          msg: context.isCurrentLanguageAr()
              ? 'حدث خطأ ما'
              : 'Something went wrong',
        );
        Loader.hide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.isCurrentLanguageAr() ? 'تعديل الملف الشخصي' : 'Edit Profile',
        ),
        leading: IconButton.filled(
          onPressed: () => context.back(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstance.hPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // --- Image Picker ---
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: _imageFile != null
                                      ? Image.file(
                                          _imageFile!,
                                          fit: BoxFit.cover,
                                          height: 100,
                                          width: 100,
                                        )
                                      : (_currentImageUrl != null &&
                                            _currentImageUrl!.isNotEmpty)
                                      ? CustomNetworkImage(
                                          url: _currentImageUrl!,
                                          radius: 999,
                                          height: 100,
                                          width: 100,
                                          boxFit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showImageSourceDialog,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primary,
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // --- Form ---
                      CreateAccountForm(
                        nameCtrl: nameCtrl,
                        userNameCtrl: userNameCtrl,
                        phoneCtrl: phoneCtrl,
                        emailCtrl: emailCtrl,
                        bioCtrl: bioCtrl,
                        isEditMode: true,
                      ),

                      SwitchListTile(
                        value: _canAskedAnonymously,
                        onChanged: (value) {
                          setState(() {
                            _canAskedAnonymously = value;
                          });
                        },
                        title: Text(
                          !context.isCurrentLanguageAr()
                              ? 'Receive questions from anonymous users'
                              : 'إستقبال أسئلة من مستخدمين مجهولين',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      CreateAccountButton(
                        onPressed: _updateProfile,
                        text: context.isCurrentLanguageAr()
                            ? 'حفظ التعديلات'
                            : 'Save Changes',
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
