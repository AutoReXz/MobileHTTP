import 'package:flutter/material.dart';
import 'package:reponsss/models/film_model.dart';
import 'package:reponsss/network/base_network.dart';
import 'package:reponsss/services/favorite_service.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  final String endpoint;

  const DetailScreen({
    Key? key,
    required this.id,
    required this.endpoint,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isLoading = true;
  Movie? _movie;
  String? _errorMessage;
  Map<String, dynamic>? _rawData;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadMovieDetail();
  }
  Future<void> _loadMovieDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await BaseNetwork.getDetail(widget.endpoint, widget.id);
      _rawData = data;
      setState(() {
        try {
          _movie = Movie.fromJson(data);
          _isFavorite = FavoriteService.isFavorite(_movie!.id);
        } catch (e) {
          throw Exception('Failed to parse movie data: $e');
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite() async {
    if (_movie == null) return;

    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      if (_isFavorite) {
        await FavoriteService.addToFavorites(_movie!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_movie!.title} ditambahkan ke favorit'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await FavoriteService.removeFromFavorites(_movie!.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_movie!.title} dihapus dari favorit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Rollback state if error
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah favorit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: AppBar(
        title: Text(_movie?.title ?? 'Detail Film'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: _movie != null
            ? [
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      if (_rawData != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: SingleChildScrollView(
                            child: Text(
                              'Raw Data: $_rawData',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMovieDetail,
                        child: const Text("Try Again"),
                      )
                    ],
                  ),
                )
              : _buildDetailContent(),
    );
  }

  Widget _buildDetailContent() {
    if (_movie == null) {
      return const Center(child: Text("No data available"));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  _movie!.imgUrl.isNotEmpty
                      ? _movie!.imgUrl
                      : 'https://via.placeholder.com/400x250?text=No+Image',
                ),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  print('Error loading image: $exception');
                },
              ),
            ),
          ),

          // Movie Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _movie!.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            _movie!.rating,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      Icons.calendar_today,
                      'Rilis: ${_movie!.releaseDate}',
                    ),
                    _buildInfoChip(
                      Icons.timelapse,
                      'Durasi: ${_movie!.duration}',
                    ),
                    _buildInfoChip(
                      Icons.language,
                      'Bahasa: ${_movie!.language}',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Sutradara'),
                Text(
                  _movie!.director,
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 16),

                // Genre
                _buildSectionTitle('Genre'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _movie!.genre.map((genre) => Chip(
                    label: Text(genre),
                    backgroundColor: Colors.grey[200],
                  )).toList(),
                ),

                const SizedBox(height: 16),

                // Cast
                _buildSectionTitle('Cast'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _movie!.cast.map((actor) => Chip(
                    label: Text(actor),
                  )).toList(),
                ),

                const SizedBox(height: 16),

                // Description
                _buildSectionTitle('Deskripsi'),
                Text(
                  _movie!.description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
