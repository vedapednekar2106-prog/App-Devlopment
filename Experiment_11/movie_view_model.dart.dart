import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';

class MovieViewModel extends ChangeNotifier {
  final MovieRepository _movieRepository = MovieRepository();

  List<Movie> movies = [];
  bool isLoading = false;
  String? errorMessage;

  // Fetch popular movies
  Future<void> fetchPopularMovies() async {
    isLoading = true;
    notifyListeners();

    try {
      movies = await _movieRepository.getPopularMovies();
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to load movies: $e';
    }

    isLoading = false;
    notifyListeners();
  }
}
