import 'package:dio/dio.dart';
import 'package:im_mottu_mobile/core/constants/contants.dart';
import '../models/pokemon_model.dart';

class PokemonService {
  final dio = Dio();

  Future<List<Pokemon>> fetchPokemons({int limit = 20}) async {
    final url = '${Api.baseUrl}${ApiRoutes.pokemon}?limit=$limit';
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;
      final results = data['results'] as List;

      return Future.wait(results.map((e) async {
        final detailRes = await dio.get(e['url']);
        final detailData = detailRes.data;
        return Pokemon.fromJson(detailData);
      }));
    } else {
      throw Exception('Erro ao carregar Pokémons');
    }
  }
}
