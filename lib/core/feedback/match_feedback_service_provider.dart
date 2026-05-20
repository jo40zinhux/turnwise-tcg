import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/presentation/providers/feedback_preferences_providers.dart';
import 'haptics_player.dart';
import 'match_feedback_service.dart';

final hapticsPlayerProvider = Provider<HapticsPlayer>((ref) {
  return const SystemHapticsPlayer();
});

final matchFeedbackServiceProvider = Provider<MatchFeedbackService>((ref) {
  return MatchFeedbackService(
    haptics: ref.watch(hapticsPlayerProvider),
    preferencesProvider: () => ref.read(feedbackPreferencesProvider),
  );
});
