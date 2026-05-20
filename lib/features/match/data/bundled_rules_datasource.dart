import 'package:flutter/services.dart';

class BundledRulesDataSource {
  Future<String> loadRawJson(String gameId) async {
    return rootBundle.loadString('assets/rules/$gameId.json');
  }
}
