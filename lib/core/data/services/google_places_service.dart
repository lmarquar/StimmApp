import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:stimmapp/core/constants/german_states.dart';

class GooglePlacesService {
  final Dio _dio = Dio();
  final String _apiKey;

  GooglePlacesService(this._apiKey);

  Future<String?> getStateFromPlaceId(String placeId) async {
    try {
      final url =
          'https://places.googleapis.com/v1/places/$placeId?fields=addressComponents&key=$_apiKey';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final List<dynamic>? addressComponents =
            response.data['addressComponents'];
        if (addressComponents != null) {
          for (var component in addressComponents) {
            final List<dynamic>? types = component['types'];
            if (types != null &&
                types.contains('administrative_area_level_1')) {
              final String? stateName = component['longText'];
              return _matchState(stateName);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
    }
    return null;
  }

  String? _matchState(String? stateName) {
    if (stateName == null) return null;

    // Direct match
    for (var state in germanStates) {
      if (state.toLowerCase() == stateName.toLowerCase()) {
        return state;
      }
    }

    // Handle cases like "Free Hanseatic City of Bremen" -> "Bremen"
    // or common variations
    final lowercaseName = stateName.toLowerCase();
    if (lowercaseName.contains('berlin')) {
      return 'Berlin';
    }
    if (lowercaseName.contains('bayern') || lowercaseName.contains('bavaria')) {
      return 'Bayern';
    }
    if (lowercaseName.contains('bremen')) {
      return 'Bremen';
    }
    if (lowercaseName.contains('hamburg')) {
      return 'Hamburg';
    }
    if (lowercaseName.contains('hessen') || lowercaseName.contains('hesse')) {
      return 'Hessen';
    }
    if (lowercaseName.contains('niedersachsen') ||
        lowercaseName.contains('lower saxony')) {
      return 'Niedersachsen';
    }
    if (lowercaseName.contains('nordrhein-westfalen') ||
        lowercaseName.contains('north rhine-westphalia')) {
      return 'Nordrhein-Westfalen';
    }
    if (lowercaseName.contains('rheinland-pfalz') ||
        lowercaseName.contains('rhineland-palatinate')) {
      return 'Rheinland-Pfalz';
    }
    if (lowercaseName.contains('saarland')) {
      return 'Saarland';
    }
    if (lowercaseName.contains('sachsen-anhalt') ||
        lowercaseName.contains('saxony-anhalt')) {
      return 'Sachsen-Anhalt';
    }
    if (lowercaseName.contains('sachsen') || lowercaseName.contains('saxony')) {
      return 'Sachsen';
    }
    if (lowercaseName.contains('schleswig-holstein')) {
      return 'Schleswig-Holstein';
    }
    if (lowercaseName.contains('thüringen') ||
        lowercaseName.contains('thuringia')) {
      return 'Thüringen';
    }
    if (lowercaseName.contains('baden-württemberg')) {
      return 'Baden-Württemberg';
    }
    if (lowercaseName.contains('brandenburg')) {
      return 'Brandenburg';
    }
    if (lowercaseName.contains('mecklenburg-vorpommern')) {
      return 'Mecklenburg-Vorpommern';
    }

    return null;
  }
}
