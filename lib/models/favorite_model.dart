import 'package:hive/hive.dart';

part 'favorite_model.g.dart';

@HiveType(typeId: 0)
class FavoriteMovie extends HiveObject {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String releaseDate;

  @HiveField(3)
  late String imgUrl;

  @HiveField(4)
  late String rating;

  @HiveField(5)
  late List<String> genre;

  @HiveField(6)
  late String description;

  @HiveField(7)
  late String director;

  @HiveField(8)
  late List<String> cast;

  @HiveField(9)
  late String language;

  @HiveField(10)
  late String duration;

  FavoriteMovie({
    required this.id,
    required this.title,
    required this.releaseDate,
    required this.imgUrl,
    required this.rating,
    required this.genre,
    required this.description,
    required this.director,
    required this.cast,
    required this.language,
    required this.duration,
  });

  // Convert from Movie model to FavoriteMovie
  factory FavoriteMovie.fromMovie(movie) {
    return FavoriteMovie(
      id: movie.id,
      title: movie.title,
      releaseDate: movie.releaseDate,
      imgUrl: movie.imgUrl,
      rating: movie.rating,
      genre: List<String>.from(movie.genre),
      description: movie.description,
      director: movie.director,
      cast: List<String>.from(movie.cast),
      language: movie.language,
      duration: movie.duration,
    );
  }
}
