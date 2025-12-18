
// import 'package:domandito/core/constants/app_constants.dart';
// import 'package:domandito/shared/controllers/static_map/static_map_cubit.dart';
// import 'package:domandito/shared/style/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:glass/glass.dart';

// class StaticMapWidget extends StatefulWidget {
//   final double latitude;
//   final double longitude;
//   final String title;
//   final Function() onMapTap;
//   const StaticMapWidget({
//     super.key,
//     required this.latitude,
//     required this.longitude,
//     required this.title,
//     required this.onMapTap,
//   });

//   @override
//   State<StaticMapWidget> createState() => _StaticMapWidgetState();
// }

// class _StaticMapWidgetState extends State<StaticMapWidget>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return BlocProvider(
//       create:
//           (context) =>
//               StaticMapCubit()..loadMapImage(
//                 latitude: widget.latitude,
//                 longitude: widget.longitude,
//               ),
//       child: BlocBuilder<StaticMapCubit, StaticMapState>(
//         builder: (context, state) {
//           final cubit = context.read<StaticMapCubit>();
//           return Column(
//             children: [
//               if (state is StaticMapLoading)
//                 LinearProgressIndicator(color: AppColors.primary,minHeight: 1,),
//               if (state is StaticMapSuccess)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 0,
//                   ),
//                   child: Stack(
//                     alignment: Alignment.topCenter,
//                     clipBehavior: Clip.none,
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(
//                           AppConstance.radiusTiny,
//                         ),
//                         child: Image.memory(cubit.mapImage!),
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         left: 0,
//                         child: GestureDetector(
//                           onTap: widget.onMapTap,
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(
//                               AppConstance.radiusTiny,
//                             ),
//                             child: Container(
//                               alignment: Alignment.center,
//                               // width: context.w - AppConstance.hPadding * 2,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(
//                                   AppConstance.radiusTiny,
//                                 ),
//                               ),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: AppConstance.hPadding,
//                                 vertical: AppConstance.vPadding,
//                               ),
//                               child: Text(
//                                 widget.title,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                   color: AppColors.greyf8,
//                                 ),
//                               ),
//                             ).asGlass(blurX: 5),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }
