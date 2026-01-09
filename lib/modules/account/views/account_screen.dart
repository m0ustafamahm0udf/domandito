import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_platforms_serv.dart';
import 'package:domandito/core/services/badge_service.dart';
import 'package:domandito/core/services/get_device_serv.dart';
import 'package:domandito/core/services/launch_urls.dart';
import 'package:domandito/core/services/share_service.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/account/views/widgets/account_footer.dart';
import 'package:domandito/modules/account/views/widgets/account_settings_list.dart';
import 'package:domandito/modules/account/views/widgets/web_download_section.dart';
import 'package:domandito/modules/privacy/privacy.dart';
import 'package:domandito/modules/profile/view/edit_profile_screen.dart';
import 'package:domandito/modules/terms/teerms.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_dialog.dart';
import 'package:domandito/shared/widgets/fading_effect.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Data State
  String _appVersion = '';
  String _appStoreUrl = '';
  String _playStoreUrl = '';
  String _facebook = '';
  String _appLogoUrl = '';
  String _appTitle = '';
  String _adminId = '';

  @override
  void initState() {
    super.initState();
    _fetchAppDetails();
  }

  Future<void> _fetchAppDetails() async {
    try {
      final docInfo = await FirebaseFirestore.instance
          .collection('appInfo')
          .doc('appDetails')
          .get();

      if (docInfo.exists && docInfo.data() != null) {
        final data = docInfo.data()!;
        final platform = PlatformService.platform;
        final version = (AppPlatform.androidApp == platform)
            ? data['appVersionAndroid']
            : data['appVersionIos'];

        if (mounted) {
          setState(() {
            _appVersion = version ?? '';
            _appStoreUrl = data['appStoreUrl'] ?? '';
            _playStoreUrl = data['playStoreUrl'] ?? '';
            _facebook = data['facebook'] ?? '';
            _appLogoUrl = data['appLogoUrl'] ?? '';
            _appTitle = data['appTitle'] ?? '';
            _adminId = data['adminId'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching app details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Loader.hide();
    final isAr = context.isCurrentLanguageAr();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton.filled(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: AccountFooter(
        adminId: _adminId,
        appLogoUrl: _appLogoUrl,
        appTitle: _appTitle,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      AccountSettingsList(onTileTap: _handleTileTap),
                      SizedBox(height: AppConstance.vPadding * 2),
                      const SizedBox(height: 40),
                      if (_appVersion.isNotEmpty)
                        Center(
                          child: Text(
                            isAr
                                ? 'إصدار $_appVersion'
                                : 'Version $_appVersion',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      SizedBox(height: AppConstance.vPadding),
                      if (kIsWeb) const WebDownloadSection(),
                    ],
                  ),
                  const FadingEffect(isFromTop: true),
                  const FadingEffect(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTileTap(int index) async {
    final isAr = context.isCurrentLanguageAr();

    switch (index) {
      case 0: // Edit Profile
        final result = await pushScreen(
          context,
          screen: const EditProfileScreen(),
        );
        if (result == true) {
          setState(() {});
        }
        break;

      case 1: // Terms
        pushScreenWithoutNavBar(context, TermsScreen());
        break;

      case 2: // Privacy
        pushScreenWithoutNavBar(context, PrivacyPolicyScreen());
        break;

      case 3: // Share
        if (_playStoreUrl.isNotEmpty && _appStoreUrl.isNotEmpty) {
          final platform = PlatformService.platform;
          if (!kIsWeb) {
            ShareService1.shareContent(
              data: AppPlatform.androidApp == platform
                  ? _playStoreUrl
                  : _appStoreUrl,
              context: context,
            );
          } else {
            LaunchUrlsService().launchBrowesr(
              uri: AppConstance.appStoreUrl,
              context: context,
            );
          }
        }
        break;

      case 4: // Report Problem
        await LaunchUrlsService().launchBrowesr(
          uri: _facebook,
          context: context,
        );
        break;

      case 5: // Logout
        final confirmLogout = await showDialog<bool>(
          context: context,
          builder: (context) => CustomDialog(
            title: isAr ? 'تسجيل الخروج' : 'Logout',
            content: isAr
                ? 'هل أنت متأكد من تسجيل الخروج؟'
                : 'Are you sure you want to logout?',
            isConfirm: true,
            onConfirm: () {},
          ),
        );

        if (confirmLogout == true) {
          BadgeService.removeBadge();
          if (mounted) {
            MySharedPreferences.clearProfile(context: context);
          }
        }
        break;

      case 6: // Delete Account
        final confirmDelete = await showDialog<bool>(
          context: context,
          builder: (context) => CustomDialog(
            title: isAr ? 'حذف الحساب' : 'Delete Account',
            content: isAr
                ? 'هل أنت متأكد من حذف حسابك؟ سيتم حذف حسابك نهائياً بعد 30 يوم.'
                : 'Are you sure you want to delete your account? Your account will be permanently deleted after 30 days.',
            isConfirm: true,
            onConfirm: () {},
          ),
        );

        if (confirmDelete == true) {
          BadgeService.removeBadge();
          if (mounted) {
            MySharedPreferences.clearProfile(context: context);
          }
        }
        break;
    }
  }
}
