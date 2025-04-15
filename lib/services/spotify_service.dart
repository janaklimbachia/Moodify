import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyService {
  final String clientId = '5ec001e8f0624483b789c8c1f6689227';
  final String clientSecret = '060b2afe2f584b8d9de57dc020eb7860';

  Future<String?> _getAccessToken() async {
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['access_token'];
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getMoodPlaylists(String mood) async {
    final token = await _getAccessToken();
    if (token == null) return [];

    String queryGenre;
    switch (mood.toLowerCase()) {
      case "happy 😊":
        queryGenre = "happy";
        break;
      case "sad 😞":
        queryGenre = "chill";
        break;
      case "neutral 😐":
        queryGenre = "focus";
        break;
      default:
        queryGenre = "mood";
    }

    final response = await http.get(
      Uri.parse("https://api.spotify.com/v1/search?q=$queryGenre&type=playlist&limit=5"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List playlists = data['playlists']['items'];
      return playlists
          .map((p) => {
                'name': p['name'],
                'url': p['external_urls']['spotify'],
                'image': p['images'][0]['url'],
              })
          .toList();
    }

    return [];
  }
}
