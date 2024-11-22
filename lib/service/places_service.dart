import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacesService {
  static Future<List<Map<String, String>>> searchPlaces(String query) async {
    if (query.length < 3) return [];

    final response = await http.get(
      Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&countrycodes=vn&limit=5'
      ),
      headers: {'Accept-Language': 'vi'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((place) => {
        'display_name': place['display_name'].toString(),
        'lat': place['lat'].toString(),
        'lon': place['lon'].toString(),
      }).toList();
    }
    return [];
  }
} 