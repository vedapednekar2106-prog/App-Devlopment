import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/movie_view_model.dart';

class MovieListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MovieViewModel>(context);

    if (viewModel.movies.isEmpty && !viewModel.isLoading) {
      viewModel.fetchPopularMovies(); // Fetch movies on first build
    }

    return Scaffold(
      appBar: AppBar(title: Text('Popular Movies')),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
              ? Center(child: Text(viewModel.errorMessage!))
              : ListView.builder(
                  itemCount: viewModel.movies.length,
                  itemBuilder: (context, index) {
                    final movie = viewModel.movies[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: ListTile(
                        leading: movie.posterPath.isNotEmpty
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                width: 50,
                                fit: BoxFit.cover,
                              )
                            : SizedBox(width: 50),
                        title: Text(movie.title),
                        subtitle: Text(movie.overview),
                      ),
                    );
                  },
                ),
    );
  }
}
