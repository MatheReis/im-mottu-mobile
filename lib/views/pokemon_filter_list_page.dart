import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:im_mottu_mobile/core/constants/contants.dart';
import 'package:im_mottu_mobile/data/models/pokemon_model.dart';
import 'package:im_mottu_mobile/views/pokemon_details_page.dart';
import 'package:im_mottu_mobile/views/widgets/pokemon_card.dart';

class PokemonFilterListPage extends StatelessWidget {
  const PokemonFilterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final title = (args != null && args['title'] != null)
        ? args['title'] as String
        : 'Filtrados';
    final list = (args != null && args['list'] != null)
        ? (args['list'] as List<Pokemon>)
        : <Pokemon>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(title.toUpperCase()),
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.secundary,
      body: list.isEmpty
          ? Center(
              child: Text(
                'Nenhum pokémon encontrado para $title',
                style: const TextStyle(color: Colors.white70),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final p = list[index];
                return PokemonCard(
                  pokemon: p,
                  index: index,
                  onTap: () => Get.to(() => PokemonDetailPage(pokemon: p)),
                );
              },
            ),
    );
  }
}
