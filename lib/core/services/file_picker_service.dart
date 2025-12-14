import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

// class FilePickerService {
//   static Future<String?> pickFile({
//     required FileType type,
//   }) async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: type,
//       );

//       if (result != null) {
//         // Get the file path
//         String filePath = result.files.single.path!;
//         // String fileName = basename(filePath);
//         return filePath;
//       } else {
//         return null;
//       }
//     } catch (e) {
//       print("Error picking file: $e");
//       return null;
//     }
//   }
// }

class ImagePickerService {
  static Future<String?> pickFile({
    required ImageSource source,
    required FileType type,
  }) async {
    final ImagePicker picker = ImagePicker();
    try {
      XFile? result = await picker.pickImage(
          source: source, imageQuality: 50, maxHeight: 720, maxWidth: 720);

      if (result != null) {
        // Get the file path
        String filePath = result.path;
        // String fileName = basename(filePath);
        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      // log("Error picking file: $e");
      return null;
    }
  }
}
