import 'package:flutter/material.dart';
import 'package:reponsss/models/film_model.dart';
import 'package:reponsss/presenters/film_presenter.dart';
import 'package:reponsss/views/film_detail.dart';
import 'package:reponsss/services/auth_service.dart';
import 'package:reponsss/services/favorite_service.dart';
import 'package:reponsss/views/favorites_screen.dart';

class FilmListScreen extends StatefulWidget {
  const FilmListScreen({super.key});

  @override
  State<FilmListScreen> createState() => _FilmListScreenState();
}

class _FilmListScreenState extends State<FilmListScreen>
    implements FilmView {
  late FilmPresenter _presenter;
  bool _isLoading = false;
  List<Movie> _filmList = [];
  List<Movie> _filteredFilmList = [];
  String? _errorMessage;
  String _currentEndpoint = "";
  String _selectedGenre = "Semua";
  Set<String> _availableGenres = {"Semua"};

  @override
  void initState() {
    super.initState();
    _presenter = FilmPresenter(this);
    _presenter.loadFilmData(_currentEndpoint);
  }

  void _fetchData(String endpoint) {
    setState(() {
      _currentEndpoint = endpoint;
      _presenter.loadFilmData(endpoint);
    });
  }

  void _updateAvailableGenres() {
    Set<String> genres = {"Semua"};
    for (Movie movie in _filmList) {
      genres.addAll(movie.genre);
    }
    setState(() {
      _availableGenres = genres;
    });
  }

  void _filterFilmsByGenre(String genre) {
    setState(() {
      _selectedGenre = genre;
      if (genre == "Semua") {
        _filteredFilmList = List.from(_filmList);
      } else {
        _filteredFilmList = _filmList
            .where((movie) => movie.genre.contains(genre))
            .toList();
      }
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void showFilmList(List<Movie> filmList) {
    setState(() {
      _filmList = filmList;
      _filteredFilmList = List.from(filmList);
      _errorMessage = null;
    });
    _updateAvailableGenres();
    // Reset filter ke "Semua" ketika data baru dimuat
    _filterFilmsByGenre("Semua");
  }

  @override
  void showError(String message) {
    setState(() {
      _errorMessage = message;
      print('Error occurred: $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Beranda"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Apakah Anda yakin ingin logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _logout();
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Bagian Favorit di atas
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Film Favorit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoritesScreen(),
                          ),
                        );
                      },
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildFavoritesSection(),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Filter Genre Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter berdasarkan Genre:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableGenres.length,
                    itemBuilder: (context, index) {
                      final genre = _availableGenres.elementAt(index);
                      final isSelected = genre == _selectedGenre;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            genre,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.deepPurple,
                              fontSize: 12,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            if (selected) {
                              _filterFilmsByGenre(genre);
                            }
                          },
                          selectedColor: Colors.deepPurple,
                          backgroundColor: Colors.grey[200],
                          checkmarkColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          const SizedBox(height: 10),
          
          // Film List Section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Error: $_errorMessage",
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            ElevatedButton(
                              onPressed: () => _fetchData(_currentEndpoint),
                              child: const Text("Try Again"),
                            )
                          ],
                        ),
                      )
                    : _filteredFilmList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.movie_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedGenre == "Semua" 
                                    ? "Tidak ada data film"
                                    : "Tidak ada film dengan genre $_selectedGenre",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              // Menampilkan jumlah film yang ditemukan
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedGenre == "Semua"
                                          ? "Menampilkan ${_filteredFilmList.length} film"
                                          : "Ditemukan ${_filteredFilmList.length} film genre $_selectedGenre",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (_selectedGenre != "Semua")
                                      TextButton(
                                        onPressed: () => _filterFilmsByGenre("Semua"),
                                        child: const Text(
                                          "Reset Filter",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _filteredFilmList.length,
                                  itemBuilder: (context, index) {
                                    final film = _filteredFilmList[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      child: Card(
                                        elevation: 2,
                                        child: ListTile(
                                          leading: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              film.imgUrl.isNotEmpty
                                                  ? film.imgUrl
                                                  : 'https://via.placeholder.com/100',
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.movie),
                                                );
                                              },
                                            ),
                                          ),
                                          title: Text(
                                            film.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Rating: ${film.rating} | Tanggal Rilis: ${film.releaseDate}",
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Wrap(
                                                spacing: 4,
                                                runSpacing: 2,
                                                children: film.genre.map((genre) {
                                                  return Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.deepPurple.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: Colors.deepPurple.withOpacity(0.3),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      genre,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.deepPurple,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DetailScreen(
                                                  id: film.id,
                                                  endpoint: _currentEndpoint,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection() {
    final favorites = FavoriteService.getAllFavorites();
    
    if (favorites.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Belum ada film favorit',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.take(5).length,
        itemBuilder: (context, index) {
          final movie = favorites[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    movie.imgUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.movie),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  movie.title,
                  style: const TextStyle(fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}