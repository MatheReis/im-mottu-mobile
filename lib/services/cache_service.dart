import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  Directory? _cacheDir;

  Future<Directory> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory('${appDir.path}/cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cacheDir = dir;
    if (kDebugMode) {
      print('Cache directory: ${_cacheDir!.path}');
    }
    return _cacheDir!;
  }

  String _fileNameForKey(String key) {
    final encoded = base64Url.encode(utf8.encode(key));
    return encoded;
  }

  Future<void> setJson(String key, dynamic jsonData) async {
    try {
      final dir = await _getCacheDir();
      final file = File('${dir.path}/${_fileNameForKey(key)}.json');
      final payload = jsonEncode({
        'ts': DateTime.now().toIso8601String(),
        'data': jsonData,
      });
      await file.writeAsString(payload);

      try {
        if (kDebugMode) {
          print('Cache salvo: $key, file: ${file.path}');
        }
      } catch (_) {}
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar cache para $key: $e');
      }
    }
  }

  Future<dynamic> getJson(String key, {Duration? maxAge}) async {
    try {
      final dir = await _getCacheDir();
      final file = File('${dir.path}/${_fileNameForKey(key)}.json');
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final Map<String, dynamic> obj = jsonDecode(content);
      final ts = DateTime.parse(obj['ts'] as String);
      if (maxAge != null) {
        if (DateTime.now().difference(ts) > maxAge) {
          try {
            if (kDebugMode) {
              print('Cache expirado: $key');
            }
          } catch (_) {}
          return null;
        }
      }
      return obj['data'];
    } catch (e) {
      if (kDebugMode) print('Erro ao ler cache: $e');
      return null;
    }
  }

  Future<void> remove(String key) async {
    try {
      final dir = await _getCacheDir();
      final file = File('${dir.path}/${_fileNameForKey(key)}.json');
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  Future<void> clear() async {
    try {
      final dir = await _getCacheDir();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        _cacheDir = null;
      }
    } catch (_) {}
  }
}
