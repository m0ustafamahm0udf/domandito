
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_bounce_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerSheet extends StatelessWidget {
  const ImagePickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstance.radiusBig)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstance.hPadding, vertical: AppConstance.vPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: <Widget>[
            // SvgPicture.asset(AppIcons.bottomSheetDivider),
            BounceButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              isOutline: true,
              title: !context.isCurrentLanguageAr()? 'Add from Camera' : 'إضافة من الكاميرا',
            ),
            BounceButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              isOutline: true,
              title: !context.isCurrentLanguageAr()? 'Add from Gallery' : 'إضافة من المعرض',
            ),
          ],
        ),
      ),
    );
  }
}



// Future showImagePicker(BuildContext context) async {
//   showModalBottomSheet(
//     context: context,
//     builder: (BuildContext context) => ImagePickerSheet(),
//   );
// }
