import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../match_history/presentation/providers/match_history_providers.dart';
import '../../domain/calculate_match_stats.dart';
import '../../domain/match_stats.dart';

final calculateMatchStatsProvider = Provider<CalculateMatchStats>((ref) {
  return const CalculateMatchStats();
});

final matchStatsProvider = FutureProvider<MatchStats>((ref) async {
  final repository = ref.watch(matchHistoryRepositoryProvider);
  final records = await repository.getAllRecords();
  return ref.watch(calculateMatchStatsProvider)(records);
});
