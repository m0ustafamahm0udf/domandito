import 'dart:typed_data';

import 'package:domandito/shared/functions/static_map_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'static_map_state.dart';

class StaticMapCubit extends Cubit<StaticMapState> {
  StaticMapCubit() : super(StaticMapInitial());

  static const String darkMapStyle =
      '&style=element:geometry|color:0x242f3e'
      '&style=element:labels.text.fill|color:0x746855'
      '&style=element:labels.text.stroke|color:0x242f3e'
      '&style=feature:administrative.locality|element:labels.text.fill|color:0xd59563'
      '&style=feature:poi|element:labels.text.fill|color:0xd59563'
      '&style=feature:poi.park|element:geometry|color:0x263c3f'
      '&style=feature:poi.park|element:labels.text.fill|color:0x6b9a76'
      '&style=feature:road|element:geometry|color:0x38414e'
      '&style=feature:road|element:geometry.stroke|color:0x212a37'
      '&style=feature:road|element:labels.text.fill|color:0x9ca5b3'
      '&style=feature:road.highway|element:geometry|color:0x746855'
      '&style=feature:road.highway|element:geometry.stroke|color:0x1f2835'
      '&style=feature:road.highway|element:labels.text.fill|color:0xf3d19c'
      '&style=feature:transit|element:geometry|color:0x2f3948'
      '&style=feature:transit.station|element:labels.text.fill|color:0xd59563'
      '&style=feature:water|element:geometry|color:0x17263c'
      '&style=feature:water|element:labels.text.fill|color:0x515c6d'
      '&style=feature:water|element:labels.text.stroke|color:0x17263c';

  final StaticMapService _mapService = StaticMapService();
  final String _apiKey = 'AIzaSyCcOWxQgXGToRfKLlt1KjU_ev-ohFmPbRY';

  Uint8List? mapImage;

  Future<void> loadMapImage({
    required double latitude,
    required double longitude,
  }) async {
    emit(StaticMapLoading());
    try {
      final imageBytes = await _mapService.fetchStaticMap(
        baseUrl: 'https://maps.googleapis.com/maps/api/staticmap',
        latitude: latitude,
        longitude: longitude,
        apiKey: _apiKey,
        mapStyle: darkMapStyle,
      );
      if (imageBytes != null) {
        mapImage = imageBytes;
        emit(StaticMapSuccess());
        // log(mapImage.toString());
      } else {
        emit(StaticMapFailed());
      }
    } catch (e) {
      emit(StaticMapFailed());
    }
  }
}
