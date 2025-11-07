import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:im_mottu_mobile/data/services/pokemon_service.dart';

void main() {
  final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10)));
  final service = PokemonService(dio);

  test(
    'fetchPokemons retorna lista de Pokémons',
    () async {
      final pokemons = await service.fetchPokemons(limit: 3, offset: 0);
      expect(pokemons, isNotEmpty);
      final p = pokemons.first;
      expect(p.id, greaterThan(0));
      expect(p.name, isNotEmpty);
      expect(p.types, isA<List<String>>());
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  test(
    'fetchPokemonById(1) retorna bulbasaur',
    () async {
      final p = await service.fetchPokemonById('1');
      expect(p.id, 1);
      expect(p.name.toLowerCase(), 'bulbasaur');
    },
    timeout: const Timeout(Duration(seconds: 15)),
  );
}
