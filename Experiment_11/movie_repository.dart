import '../models/movie.dart';
import '../services/movie_service.dart';

class MovieRepository {
  final MovieService _movieService = MovieService();

  Future<List<Movie>> getPopularMovies() async {
    return await _movieService.fetchPopularMovies();
  }
}
