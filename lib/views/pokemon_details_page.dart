import 'package:flutter/material.dart';
import 'package:im_mottu_mobile/core/constants/contants.dart';
import 'package:im_mottu_mobile/data/models/pokemon_model.dart';

class PokemonDetailPage extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailPage({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pokemon.name.toUpperCase())),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(pokemon.imageUrl, height: 150),
              const SizedBox(height: 16),
              Text(
                pokemon.name.toUpperCase(),
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              _infoRow('Altura', '${pokemon.height}'),
              _infoRow('Peso', '${pokemon.weight}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: AppColors.primary, fontSize: 16),
      ),
    );
  }
}
