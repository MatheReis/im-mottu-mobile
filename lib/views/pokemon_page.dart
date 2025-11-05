import 'package:flutter/material.dart';
import 'package:im_mottu_mobile/core/constants/contants.dart';
import 'package:im_mottu_mobile/data/models/pokemon_model.dart';
import 'package:im_mottu_mobile/data/services/pokemon_service.dart';
import 'package:im_mottu_mobile/views/pokemon_details_page.dart';

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final service = PokemonService();
  late Future<List<Pokemon>> pokemons;

  @override
  void initState() {
    super.initState();
    pokemons = service.fetchPokemons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PokeDex')),
      body: FutureBuilder<List<Pokemon>>(
        future: pokemons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final pokemon = data[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PokemonDetailPage(pokemon: pokemon)),
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(pokemon.imageUrl,
                          height: 80, fit: BoxFit.contain),
                      const SizedBox(height: 8),
                      Text(
                        pokemon.name.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
