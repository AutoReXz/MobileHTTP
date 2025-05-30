class Movie {
  final int id;
  final String title;
  final String releaseDate;
  final String imgUrl;
  final String rating;
  final List<String> genre;
  final String createdAt;
  final String description;
  final String director;
  final List<String> cast;
  final String language;
  final String duration;

  Movie({
    required this.id,
    required this.title,
    required this.releaseDate,
    required this.imgUrl,
    required this.rating,
    required this.genre,
    required this.createdAt,
    required this.description,
    required this.director,
    required this.cast,
    required this.language,
    required this.duration,
  });
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      releaseDate: json['release_date']?.toString() ?? '',
      imgUrl: json['imgUrl']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '',
      genre: json['genre'] != null 
        ? List<String>.from(json['genre'].map((item) => item.toString()))
        : [],
      createdAt: json['created_at']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      director: json['director']?.toString() ?? '',
      cast: json['cast'] != null 
        ? List<String>.from(json['cast'].map((item) => item.toString()))
        : [],
      language: json['language']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
    );
  }
}
