import 'dart:async';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:im_mottu_mobile/core/constants/contants.dart';
import 'package:im_mottu_mobile/core/constants/app_colors.dart';
import 'package:im_mottu_mobile/data/models/pokemon_model.dart';
import 'package:im_mottu_mobile/views/widgets/pokemon_card.dart';
import 'package:im_mottu_mobile/views/pokemon_details_page.dart';
import 'package:im_mottu_mobile/data/services/pokemon_service.dart';
import 'package:im_mottu_mobile/views/widgets/search_bar_widget.dart';
import 'package:im_mottu_mobile/views/widgets/loading_state_widget.dart';
import 'package:im_mottu_mobile/views/widgets/error_state_widget.dart';

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final PokemonService _service = PokemonService(Dio());
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  final List<Pokemon> _allPokemons = [];
  List<Pokemon> _filteredPokemons = [];
  bool _isLoading = false;
  bool _isSearching = false;
  bool _hasError = false;
  String _searchQuery = '';

  final int _pageSize = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPokemons();

    _searchController.addListener(() {
      _debounceTimer?.cancel();
      setState(() {
        _isSearching = true;
        _searchQuery = _searchController.text;
      });
      _debounceTimer = Timer(const Duration(milliseconds: 450), () {
        _performSearch();
        if (mounted) setState(() => _isSearching = false);
      });
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToPokemonDetails(Pokemon pokemon) =>
      Get.to(() => PokemonDetailPage(pokemon: pokemon));

  Future<void> _loadPokemons({bool refresh = false}) async {
    if (refresh) {
      _allPokemons.clear();
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final pokemons = await _service.fetchPokemons(
        limit: _pageSize,
        offset: _allPokemons.length,
      );
      setState(() {
        _allPokemons.addAll(pokemons);
        if (pokemons.length < _pageSize) _hasMore = false;
        _updateFilteredList();
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _performSearch() {
    final query = _searchQuery.trim();

    if (query.isEmpty) {
      _updateFilteredList();
      return;
    }

    final localResults = _allPokemons
        .where((pokemon) =>
            pokemon.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _filteredPokemons = localResults;
    });
  }

  void _updateFilteredList() {
    final query = _searchQuery.trim();
    if (query.isEmpty) {
      _filteredPokemons = List.from(_allPokemons);
    } else {
      _filteredPokemons = _allPokemons
          .where((pokemon) =>
              pokemon.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _updateFilteredList();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _isLoadingMore = true;
      _loadPokemons();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secundary,
      extendBodyBehindAppBar: false,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            isSearching: _isSearching,
            searchQuery: _searchQuery,
            onClear: _clearSearch,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'POKÉDEX',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.surface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            color: AppColors.cardBackground,
            onSelected: (value) {
              if (value == 'refresh') {
                _loadPokemons();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: AppColors.primary, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Atualizar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingStateWidget();
    }
    if (_hasError) {
      return ErrorStateWidget(onRetry: () => _loadPokemons());
    }
    return _buildPokemonGrid();
  }

  Widget _buildPokemonGrid() {
    if (_filteredPokemons.isEmpty && _searchQuery.isNotEmpty) {
      return _buildEmptySearchState();
    }

    if (_filteredPokemons.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadPokemons(refresh: true),
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: GridView.builder(
        key: const PageStorageKey('pokemonGrid'),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: _filteredPokemons.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _filteredPokemons.length) {
            return const SizedBox();
          }

          final pokemon = _filteredPokemons[index];
          return PokemonCard(
            pokemon: pokemon,
            index: index,
            onTap: () => _navigateToPokemonDetails(pokemon),
          );
        },
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum Pokémon encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente buscar com outro nome',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.catching_pokemon,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum Pokémon disponível',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
