import 'package:reponsss/models/film_model.dart';
import 'package:reponsss/network/base_network.dart';

abstract class FilmView {
    void showLoading();
    void hideLoading();
    void showFilmList(List<Movie> filmList);
    void showError(String message);
}

class FilmPresenter {
    final FilmView view;
    FilmPresenter(this.view);    Future<void> loadFilmData(String endpoint) async {
        try {
            view.showLoading();
            final List<dynamic> data = await BaseNetwork.getList(endpoint);
            print('API Response: ${data.length} items');
            
            if (data.isEmpty) {
              view.showFilmList([]);
              return;
            }
            
            final filmList = <Movie>[];
            
            for (int i = 0; i < data.length; i++) {
              try {
                final movie = Movie.fromJson(data[i]);
                filmList.add(movie);
              } catch (e) {
                print('Error parsing item $i: $e');
                print('Problematic JSON: ${data[i]}');
                // Skip item yang bermasalah dan lanjutkan ke item berikutnya
                continue;
              }
            }
            
            view.showFilmList(filmList);
        } catch (e) {
            print('Error in presenter: $e');
            view.showError('Gagal memuat data: ${e.toString()}');
        } finally {
            view.hideLoading();
        }
    }
}
