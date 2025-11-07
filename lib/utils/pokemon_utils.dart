import 'package:im_mottu_mobile/data/models/pokemon_model.dart';

class PageResult<T> {
  final List<T> items;
  final bool hasMore;

  PageResult({required this.items, required this.hasMore});
}

List<Pokemon> filterPokemons(List<Pokemon> list, String query) {
  final q = query.trim();
  if (q.isEmpty) return List.from(list);
  final lower = q.toLowerCase();
  return list.where((p) => p.name.toLowerCase().contains(lower)).toList();
}

PageResult<Pokemon> paginatePokemons(
    List<Pokemon> list, int limit, int offset) {
  if (limit <= 0 || offset < 0) return PageResult(items: [], hasMore: false);
  final start = offset;
  if (start >= list.length) return PageResult(items: [], hasMore: false);
  final end = (start + limit) > list.length ? list.length : (start + limit);
  final page = list.sublist(start, end);
  final hasMore = end < list.length;
  return PageResult(items: page, hasMore: hasMore);
}
