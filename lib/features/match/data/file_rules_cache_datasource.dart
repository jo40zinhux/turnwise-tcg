import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileRulesCacheDataSource {
  static const _cacheFolderName = 'rules_cache';

  Future<Directory> _cacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheFolderName');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  Future<String?> read(String gameId) async {
    final file = File('${(await _cacheDirectory()).path}/$gameId.json');
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  Future<void> write(String gameId, String rawJson) async {
    final file = File('${(await _cacheDirectory()).path}/$gameId.json');
    await file.writeAsString(rawJson);
  }
}
