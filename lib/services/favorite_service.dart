import 'package:hive_flutter/hive_flutter.dart';
import 'package:reponsss/models/favorite_model.dart';

class FavoriteService {
  static const String _boxName = 'favorites';
  static Box<FavoriteMovie>? _box;

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FavoriteMovieAdapter());
    _box = await Hive.openBox<FavoriteMovie>(_boxName);
  }

  // Get the box instance
  static Box<FavoriteMovie> get box {
    if (_box == null) {
      throw Exception('FavoriteService not initialized. Call init() first.');
    }
    return _box!;
  }

  // Add movie to favorites
  static Future<void> addToFavorites(movie) async {
    final favoriteMovie = FavoriteMovie.fromMovie(movie);
    await box.put(movie.id.toString(), favoriteMovie);
  }

  // Remove movie from favorites
  static Future<void> removeFromFavorites(int movieId) async {
    await box.delete(movieId.toString());
  }

  // Check if movie is in favorites
  static bool isFavorite(int movieId) {
    return box.containsKey(movieId.toString());
  }

  // Get all favorite movies
  static List<FavoriteMovie> getAllFavorites() {
    return box.values.toList();
  }

  // Get favorites count
  static int getFavoritesCount() {
    return box.length;
  }

  // Clear all favorites
  static Future<void> clearAllFavorites() async {
    await box.clear();
  }
}
