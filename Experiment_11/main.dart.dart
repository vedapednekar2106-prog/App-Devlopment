import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/movie_list_screen.dart';
import 'view_model/movie_view_model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MovieViewModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MovieListScreen(),
    );
  }
}
