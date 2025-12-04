import 'dart:convert';
import 'package:http/http.dart' as http;

class RawgService {
  // Cadastre-se em https://rawg.io/apidocs para pegar sua chave
  static const String _apiKey = '8dda469b61ab4ef097313b28e7fa1409'; 
  static const String _baseUrl = 'https://api.rawg.io/api';

  Future<List<Map<String, dynamic>>> searchGames(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse('$_baseUrl/games?key=$_apiKey&search=$query&page_size=5');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // --- CORREÇÃO DE ACENTUAÇÃO AQUI ---
        // Usamos utf8.decode(response.bodyBytes) em vez de response.body
        final data = json.decode(utf8.decode(response.bodyBytes));
        // -----------------------------------
        
        final List results = data['results'];

        return results.map((game) {
          String genre = 'Desconhecido';
          if (game['genres'] != null && (game['genres'] as List).isNotEmpty) {
            genre = game['genres'][0]['name'];
          }

          return {
            'title': game['name'],
            'image': game['background_image'],
            'genre': genre,
            'rating': game['rating']
          };
        }).toList();
      } else {
        throw Exception('Falha ao carregar jogos');
      }
    } catch (e) {
      print('Erro na API: $e');
      return [];
    }
  }
}