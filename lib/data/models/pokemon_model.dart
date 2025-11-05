class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final int height;
  final int weight;
  final List<String> types;
  final List<String> abilities;
  final int baseExperience;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.baseExperience,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['sprites']?['front_default'] ?? '',
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
      types: (json['types'] as List<dynamic>?)
              ?.map((type) => type['type']['name'] as String)
              .toList() ??
          [],
      abilities: (json['abilities'] as List<dynamic>?)
              ?.map((ability) => ability['ability']['name'] as String)
              .toList() ??
          [],
      baseExperience: json['base_experience'] ?? 0,
    );
  }
}
