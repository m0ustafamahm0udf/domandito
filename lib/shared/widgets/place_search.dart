// import 'package:flutter/material.dart';
// import 'package:back_appcore/constants/app_constants.dart';
// import 'package:back_appmodels/restaurant_model.dart';
// import 'package:back_appmodules/home/views/widgets/restaurant_card.dart';
// import 'package:back_appshared/style/app_colors.dart';

// class PlaceSearchScreen extends StatefulWidget {
//   final List<RestaurantModel> places;

//   const PlaceSearchScreen({super.key, required this.places});

//   @override
//   State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
// }

// class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
//   late List<RestaurantModel> _filteredPlaces;
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     _filteredPlaces = widget.places
//         .where((place) => !place.deleted && !place.hasOtherOrders)
//         .toList();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _searchRestaurants(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredPlaces = widget.places
//             .where((place) => !place.deleted && !place.hasOtherOrders)
//             .toList();
//       } else {
//         _filteredPlaces = widget.places
//             .where((place) =>
//                 place.restaurantName
//                     .toLowerCase()
//                     .contains(query.toLowerCase()) &&
//                 !place.deleted &&
//                 !place.hasOtherOrders)
//             .toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: TextField(
//           controller: _searchController,
//           autofocus: true,
//           decoration: const InputDecoration(
//             hintText: 'ابحث عن المحلات والمطاعم والمزيد',
//             border: InputBorder.none,
//           ),
//           onChanged: _searchRestaurants,
//         ),
//         actions: [
//           if (_searchController.text.isNotEmpty)
//             IconButton(
//               icon: const Icon(Icons.clear, color: AppColors.black),
//               onPressed: () {
//                 _searchController.clear();
//                 _searchRestaurants('');
//               },
//             ),
//         ],
//       ),
//       body: _buildSearchResults(),
//     );
//   }

//   Widget _buildSearchResults() {
//     return ListView.separated(
//       padding: EdgeInsetsDirectional.only(
//         start: AppConstance.hPadding,
//         end: AppConstance.hPadding,
//         top: AppConstance.hPaddingBig,
//         bottom: AppConstance.hPaddingBig * 2,
//       ),
//       itemCount: _filteredPlaces.length,
//       separatorBuilder: (context, index) =>
//           SizedBox(height: AppConstance.gap / 2),
//       itemBuilder: (context, index) {
//         return RestaurantCard(
//           restaurant: _filteredPlaces[index],
//         );
//       },
//     );
//   }
// }
