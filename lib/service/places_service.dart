import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacesService {
  static Future<List<Map<String, String>>> searchPlaces(String query) async {
    //Kiểm tra độ dài của query
    if (query.length < 3) return [];

//Gửi yêu cầu HTTP đến OpenStreetMap
    final response = await http.get(
      Uri.parse(
        //giới hạn kết quả trong 5 địa điểm (limit=5), và lọc theo mã quốc gia Việt Nam (countrycodes=vn).
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&countrycodes=vn&limit=5'
      ),
      //kết quả bằng tiếng Việt
      headers: {'Accept-Language': 'vi'},
    );

//Xử lý và trả về kết quả
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((place) => {
        'display_name': place['display_name'].toString(),
        'lat': place['lat'].toString(), //Vĩ độ của địa điểm.
        'lon': place['lon'].toString(), //Kinh độ của địa điểm.
      }).toList();
    }
    return [];
  }
} 