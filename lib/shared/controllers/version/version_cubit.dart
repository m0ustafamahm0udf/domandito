// import 'dart:convert';

// import 'package:bloc/bloc.dart';

// import 'package:cpv_end_user/core/constants/api_urls.dart';
// import 'package:cpv_end_user/core/constants/app_constants.dart';
// import 'package:cpv_end_user/core/constants/app_strings.dart';
// import 'package:cpv_end_user/shared/models/version_model.dart';
// import 'package:equatable/equatable.dart';
// import 'package:http/http.dart' as http;

// part 'version_state.dart';

// class VersionCubit extends Cubit<VersionState> {
//   VersionCubit() : super(VersionInitial());

//   VersionModel version = VersionModel(
//     version: "",
//     isForce: false,
//     iosLink: "",
//     androidLink: "",
//     description: "",
//   );

//   Future<void> getTheVersion() async {
//     try {
//       final res = await http.get(Uri.parse('${ApiUrl.mainUrl}${ApiUrl.versionCheck}'));

//       final data = jsonDecode(res.body);
//       if (res.statusCode == 200) {
//         final versionModel = VersionModel.fromJson(data);

//         if (AppConstance.currentVersion.trim() != versionModel.version.trim()) {
//           emit(VersionUpdateAvalibleState(version: versionModel));
//         }
//       }
//     } catch (e) {}
//   }
// }
