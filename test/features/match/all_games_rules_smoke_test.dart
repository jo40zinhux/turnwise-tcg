import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/action_enforcement.dart';
import 'package:turnwise_tcg/features/match/domain/game_rules.dart';
import 'package:turnwise_tcg/features/match/domain/game_rules_metadata.dart';

import 'support/rules_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('All games — rules smoke', () {
    for (final gameId in kAllGameIds) {
      group(gameId, () {
        late GameRules rules;

        setUpAll(() async {
          rules = await RulesTestHarness.loadRules(gameId);
        });

        test('loads bundled rules and effects', () {
          expect(rules.gameId, gameId);
          expect(rules.name, isNotEmpty);
          expect(rules.phases, isNotEmpty);
          expect(rules.actions, isNotEmpty);
        });

        test('action validations reference known rules', () {
          final validationIds =
              rules.validations.map((v) => v.id).toSet();

          for (final action in rules.actions) {
            for (final validationId in action.validations) {
              expect(
                validationIds,
                contains(validationId),
                reason: 'Action ${action.id} references $validationId',
              );
            }
          }
        });

        test('action phases exist in turn structure', () {
          final phaseIds = rules.phases.map((p) => p.id).toSet();

          for (final action in rules.actions) {
            for (final phaseId in action.allowedPhases) {
              expect(
                phaseIds,
                contains(phaseId),
                reason: 'Action ${action.id} uses unknown phase $phaseId',
              );
            }
          }
        });

        test('has enough trackable actions for gameplay', () {
          expect(
            rules.actions.length,
            greaterThanOrEqualTo(3),
            reason: 'Game should expose a meaningful action set',
          );
        });

        test('requires universal coin-flip setup', () {
          expect(rules.metadata.requiresWentFirstSetup, isTrue);
        });

        test('has game-specific setup hint copy', () {
          final hint = rules.metadata.firstTurnHint;
          expect(hint, isNotNull);
          expect(hint, isNotEmpty);
        });

        test('has board metadata with slot labels', () {
          expect(rules.metadata.board.slotLabels, isNotEmpty);
        });

        test('resource bar flag matches game family', () {
          final expectsBar = GameRulesMetadata.resourceGameIds.contains(gameId);
          expect(GameRulesMetadata.showResourceBarFor(gameId), expectsBar);
        });

        test('phase titles are localized in Portuguese', () {
          final legacyEnglishTitle = RegExp(
            r' (Phase|Step)$|^(Untap|Upkeep|Combat|Draw|Main|Ready|Set|Start|End|Action|Beginning|Awaken|Showdown) ',
          );

          for (final phase in rules.phases) {
            expect(
              legacyEnglishTitle.hasMatch(phase.title),
              isFalse,
              reason:
                  'Phase ${phase.id} title should be Portuguese, got "${phase.title}"',
            );
            expect(phase.title, isNotEmpty);
          }
        });

        test('ActionEnforcement analyzes every action without error', () {
          for (final action in rules.actions) {
            expect(
              () => ActionEnforcement.analyze(rules, action),
              returnsNormally,
            );
          }
        });
      });
    }
  });
}
