import 'package:flutter_test/flutter_test.dart';
import 'package:im_mottu_mobile/utils/pokemon_utils.dart';
import 'package:im_mottu_mobile/data/models/pokemon_model.dart';

Pokemon generatePokemon(int id, String name) {
  return Pokemon(
    id: id,
    name: name,
    imageUrl: '',
    height: 1,
    weight: 1,
    types: [],
    abilities: [],
    baseExperience: 0,
  );
}

void main() {
  group('Testes de regra de negócio', () {
    test('Paginação funciona corretamente', () {
      final pokemons = List.generate(
          10, (index) => generatePokemon(index + 1, 'Pokemon${index + 1}'));

      final page1 = paginatePokemons(pokemons, 3, 0);
      expect(page1.items.length, 3);
      expect(page1.hasMore, true);
      expect(page1.items.first.id, 1);

      final page2 = paginatePokemons(pokemons, 3, 3);
      expect(page2.items.length, 3);
      expect(page2.hasMore, true);
      expect(page2.items.first.id, 4);

      final page3 = paginatePokemons(pokemons, 3, 6);
      expect(page3.items.length, 3);
      expect(page3.hasMore, true);
      expect(page3.items.first.id, 7);

      final page4 = paginatePokemons(pokemons, 3, 9);
      expect(page4.items.length, 1);
      expect(page4.hasMore, false);
      expect(page4.items.first.id, 10);
    });
  });
}
