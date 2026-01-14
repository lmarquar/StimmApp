import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GooglePlacesPrediction {
  final String description;
  final String placeId;

  GooglePlacesPrediction({required this.description, required this.placeId});

  factory GooglePlacesPrediction.fromJson(Map<String, dynamic> json) {
    return GooglePlacesPrediction(
      description: json['description'] as String,
      placeId: json['place_id'] as String,
    );
  }
}

class GooglePlacesService {
  final String apiKey;

  GooglePlacesService({required this.apiKey});

  Future<List<GooglePlacesPrediction>> getAutocomplete(String input) async {
    if (input.isEmpty) return [];

    final apiUri =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$apiKey&components=country:de&types=address&language=de';

    // On Web, we need a CORS proxy because Google doesn't allow direct cross-origin requests for this API.
    final String url = kIsWeb
        ? 'https://cors-anywhere.herokuapp.com/$apiUri'
        : apiUri;

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'] as String;

        if (status == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions
              .map(
                (p) =>
                    GooglePlacesPrediction.fromJson(p as Map<String, dynamic>),
              )
              .toList();
        } else if (status == 'ZERO_RESULTS') {
          return [];
        } else {
          // Google API error message
          final errorMessage = data['error_message'] as String?;
          throw Exception(errorMessage ?? 'Google Places API Error: $status');
        }
      } else if (response.statusCode == 403 && kIsWeb) {
        throw Exception(
          'CORS Proxy access denied. Please visit https://cors-anywhere.herokuapp.com/corsdemo to temporarily allow access.',
        );
      } else {
        throw Exception(
          'Failed to connect to Google Places API: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is http.ClientException && kIsWeb) {
        debugPrint('GooglePlacesService CORS Error: $e');
        throw Exception(
          'Connection failed. If you are on Web, you might need to visit https://cors-anywhere.herokuapp.com/corsdemo to unlock the proxy.',
        );
      }
      debugPrint('GooglePlacesService Error: $e');
      rethrow;
    }
  }
}
