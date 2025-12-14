import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StaticMapService {
  /// Generic function to fetch the static map image
  Future<Uint8List?> fetchStaticMap({
    required String baseUrl,
    required double latitude,
    required double longitude,
    required String apiKey,
    int zoom = 18,
    String mapType = '',
    String markerLabel = 'C',
    int width = 600,
    int height = 400,
    String? mapStyle,
  }) async {
    final url =
        '$baseUrl'
        '?center=$latitude,$longitude'
        '&markers=color:red%7Clabel:$markerLabel%7C$latitude,$longitude'
        '&zoom=$zoom'
        '&size=${width}x$height'
        '&maptype=$mapType'
        '$mapStyle'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load map: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching map: $e');
      return null;
    }
  }
}
