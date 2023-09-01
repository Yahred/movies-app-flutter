import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/helpers/debouncer.dart';

import 'package:peliculas/models/models.dart';
import 'package:peliculas/models/search_movies_response.dart';

class MoviesProvider extends ChangeNotifier {
  final String _baseURL = 'api.themoviedb.org';
  final String _apiKey = '0265f393235d1142858ea115eae6dcdc';
  final String _lang = 'es-ES';

  int _popularPage = 0;

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> moviesCast = {};

  final Debouncer debouncer = Debouncer(duration: Duration(milliseconds: 500));

  final StreamController<List<Movie>> _suggestionsStreamController =
      StreamController.broadcast();

  Stream<List<Movie>> get suggestionStream =>
      _suggestionsStreamController.stream;

  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(String endpoint, {int page = 1}) async {
    var url = Uri.https(_baseURL, endpoint,
        {'api_key': _apiKey, 'language': _lang, 'page': '$page'});

    final response = await http.get(url);
    return response.body;
  }

  getPopularMovies() async {
    _popularPage += 1;
    final popularRespose = PopularResponse.fromJson(
        await _getJsonData('3/movie/popular', page: _popularPage));

    popularMovies = [...popularMovies, ...popularRespose.results];
    notifyListeners();
  }

  getOnDisplayMovies() async {
    final movies = NowPlayingResponse.fromJson(await _getJsonData(
      '3/movie/now_playing',
    ));

    onDisplayMovies = movies.results;
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieID) async {
    if (moviesCast[movieID] != null) return moviesCast[movieID]!;

    final response = CreditsResponse.fromJson(
        await _getJsonData('3/movie/$movieID/credits'));
    moviesCast.addAll({movieID: response.cast});

    return response.cast;
  }

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.http(_baseURL, '3/search/movie',
        {'api_key': _apiKey, 'language': _lang, 'query': query});

    final response = await http.get(url);

    final SearchMoviesResponse search =
        SearchMoviesResponse.fromJson(response.body);

    return search.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await searchMovies(searchTerm);
      _suggestionsStreamController.add(results);
    };

    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(const Duration(milliseconds: 301))
        .then((_) => timer.cancel());
  }
}
