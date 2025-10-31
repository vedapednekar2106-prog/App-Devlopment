import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  final String apiKey = "a39b4964f4eae6297262fd038d8fa10d"; 
  final String baseUrl = "https://api.themoviedb.org/3";

  Future<List<Movie>> fetchPopularMovies() async {
    final url = Uri.parse("$baseUrl/movie/popular?api_key=$apiKey&language=en-US&page=1");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
