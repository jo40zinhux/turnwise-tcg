# TurnWise — Engineering Review & Changelog

**Data:** 24 maio 2026  
**Baseline (último commit):** `ba44911` — *update for cancel chip selection - action game update for home showing all games and nudge bouncing*  
**Estado analisado:** working tree (alterações locais não commitadas)  
**Regra aplicada:** `.cursor/rules/engineering-review.mdc`

---

## Executive Summary

O TurnWise evoluiu de um **tracker de turnos** para um **motor de partida orientado a JSON**, com validações declarativas, efeitos, tabuleiro simplificado e UX honesta (enforcement vs lembrete). A arquitetura **presentation → domain → data** foi respeitada: regras em assets, lógica no `MatchEngine`/`EffectEngine`, UI em widgets Riverpod.

| Dimensão | Avaliação |
|----------|-----------|
| **Production readiness (match feature)** | Boa para beta — fluxos críticos testados |
| **Arquitetura** | Sólida; domain puro; sem Firebase na UI |
| **Riscos principais** | `MatchBody` grande; copy de tabuleiro ainda em Dart; turno oponente manual |
| **Testes match** | **202 testes** em `test/features/match/` — todos passando |
| **Esforço refactor sugerido** | Baixo–médio (1–2 sprints de polish) |

**Veredicto:** Aprovação condicional para merge após commit — corrigir débitos MEDIUM antes de escalar novos TCGs ou multiplayer.

---

# Parte A — O que foi implementado

## A.1 Já no commit `ba44911` (baseline)

Funcionalidades já integradas em `main` antes deste sprint de match:

### Home & descoberta
- **Carousel de jogos** com strip horizontal e nudge animado (`home_game_carousel.dart`, `home_carousel_hint_provider.dart`)
- **Secção “Todos os jogos”** com sheet em grelha (`home_games_grid_sheet.dart`, `all_games_section.dart`)
- **Jogos recentes** atualizados
- Analytics: eventos de carousel / grid

### Match (incremental no commit)
- **Undo de ações** com coach tip contextual (`match_undo_coach_test.dart`)
- **Cancelar seleção de chip** (tap/long-press refinado em `match_action_chip.dart`)
- **Revert de efeitos** ligado à ação (`effect_engine_revert_test.dart`)
- Integração inicial de coach banner na partida

### Testes (commit)
- `test/features/home/*` — carousel, nudge, all games
- `test/features/coach/coach_tip_banner_test.dart`
- `test/features/match/effect_engine_revert_test.dart`, `match_undo_coach_test.dart`

---

## A.2 Novidades desde `ba44911` (working tree)

### 1. Motor de regras & validações (7 TCGs)

**Ficheiros domain (novos):**
- `validation_evaluator.dart` — `limit`, `player_first_turn`, `first_player_first_turn`, `resource`, `condition`
- `resource_spend_evaluator.dart` — DON!!, Action Points, Energy
- `phase_reminder_evaluator.dart` — lembretes por fase (ex.: One Piece skip draw)
- `action_enforcement.dart` — distingue **enforced** vs **reminder**
- `match_action_filter.dart` — filtro de ações por fase na UI

**Assets atualizados (×7):**
- `assets/rules/{pokemon,one_piece,yugioh,lorcana,magic,flesh_and_blood,riftbound}.json`
- `assets/rules/effects/*_effects.json`

**Comportamento:**
- Regras de primeiro turno por jogo (Pokémon supporter/attack/evolve, Lorcana challenge, Yu-Gi-Oh! no attack, etc.)
- Limites por turno (land, ink, draw, add_don, channel runes)
- Custos de recursos com bloqueio automático quando aplicável

### 2. Setup universal (moeda)

- `match_setup_sheet.dart` — “Quem joga primeiro?” para **todos** os TCGs
- `game_rules_metadata.dart` — `requiresWentFirstSetup` (opt-out via `skip_coin_flip`)
- `match_setup_copy.dart` — lê `metadata.firstTurnHint` do JSON
- Persistência de `playerWentFirst` na sessão

### 3. UX honesta (tracker vs enforcement)

- `match_tracker_notice.dart` — banner “modo tracker”
- Badge **ℹ️** em chips com validações `condition` (`match_action_chip.dart`)
- `match_action_reminder_sheet.dart` — long-press com texto completo da regra
- `ActionEnforcement` documenta o que o app bloqueia vs só lembra

### 4. BoardState (MVP tabuleiro)

| Componente | Função |
|------------|--------|
| `board_target.dart` | Flags: `enteredThisTurn`, `exerted`, `inAttackPosition` |
| `match_board_state.dart` | Slots dinâmicos (1–6), `onNewTurn()` limpa flags |
| `board_game_config.dart` | **Labels por jogo** (ex.: Exaurida, Descansado, Enjoo) |
| `condition_evaluator.dart` | Avalia `requires` do JSON no alvo |
| `board_state_updater.dart` | Marca flags após ações |
| `board_undo_entry.dart` | Snapshot para undo |
| `match_board_panel.dart` | UI compacta + add/remove slots |
| `match_target_picker_sheet.dart` | Escolha de alvo antes da ação |

**Semântica “Exaurido”:** mesma flag `exerted`; label **Exaurida** só em Riftbound; FAB sem flags (usa AP).

### 5. Recursos por jogo

- `match_resources_state.dart` — DON!!, Action Points, Energy
- `match_resource_bar.dart` — barra para One Piece, FAB, Riftbound
- `GameRulesMetadata.showResourceBarFor()` / `showBoardPanelFor()`

### 6. Coach tips & copy unificada

- `coach_tip_definition.dart` + `metadata.coachTips[]` em cada JSON
- `match_coach_tips.dart` — lê do JSON; fallback genérico por ordem de turno
- **Fix:** `game_rules_merger.dart` preserva `metadata` ao fundir efeitos (bug que descartava hints)

### 7. Turno do oponente

- `MatchEffectsState.isOpponentTurn` — persistido em JSON da sessão
- Ao terminar última fase → `isOpponentTurn = true`
- `MatchTurnContextBar` — “Turno do oponente” + **Oponente terminou**
- `MatchEngine.completeOpponentTurn()` — expira efeitos `until_end_opponent_turn` (ex.: Pokémon Item Lock)
- `attemptAction` bloqueado durante turno do oponente

### 8. Refactor de apresentação

- `match_screen.dart` — ~232 linhas (antes ~600+)
- `match_body.dart` — área scrollável da partida (fases, board, ações, coach)
- `match_providers.dart` — `completeOpponentTurn`, `updateBoard`, setup

### 9. Observabilidade

- Novos eventos em `analytics_events.dart` / `app_analytics.dart` (setup, board, etc.)

### 10. Suite de testes (novos / expandidos)

| Ficheiro | Cobertura |
|----------|-----------|
| `all_games_rules_smoke_test.dart` | Estrutura JSON × 7 jogos |
| `all_games_engine_rules_test.dart` | Comportamento do motor por jogo |
| `all_games_reminder_badges_test.dart` | Badges ℹ️ na UI |
| `board_state_test.dart` | Evolve, challenge, Yu-Gi-Oh!, undo |
| `board_game_config_test.dart` | Labels por TCG |
| `opponent_turn_test.dart` | Ciclo oponente + Item Lock |
| `validation_evaluator_test.dart` | Resource / limit |
| `match_setup_sheet_test.dart` | Sheet da moeda |
| `pokemon_first_turn_rules_test.dart` | Regras Pokémon |
| `support/rules_test_harness.dart` | Fixture partilhado |

**Total:** 202 testes em `test/features/match/`.

### 11. Ficheiros removidos / limpeza

- PDFs Firebase Apple Auth (não relacionados com match)
- `board_target_flags.dart` substituído por `board_game_config.dart`

---

## A.3 Mapa de ficheiros (working tree)

```
31 modificados + ~40 novos (domain, presentation, test)
~897 linhas adicionadas, ~666 removidas (diff tracked)
```

**Domain novo:** 16 ficheiros em `lib/features/match/domain/`  
**Presentation novo:** 8 widgets em `lib/features/match/presentation/widgets/`  
**Testes novo:** 15+ ficheiros em `test/features/match/`

---

# Parte B — Engineering Review

## Planning Alignment

| Requisito | Estado |
|-----------|--------|
| 7 TCGs com regras JSON | ✅ |
| Setup moeda universal | ✅ |
| Enforcement honesto | ✅ |
| Board MVP com undo | ✅ |
| Turno oponente | ✅ (manual) |
| Copy centralizada em JSON | ✅ setup + coach; ⚠️ board labels ainda em Dart |
| Testes cross-game | ✅ |

**Gaps:** UseCases explícitos não existem — `MatchEngine` actua como façade (aceitável no tamanho actual).

---

## Architecture Assessment

### Pontos fortes
- **Domain puro:** `MatchEngine`, `EffectEngine`, evaluators sem imports Flutter/Firebase
- **Regras declarativas:** alterações de balanceamento via JSON sem redeploy de lógica
- **Separação enforcement/reminder:** alinhado com produto (tracker assistido)
- **Repository de regras:** `CachedRulesRepository` + merger de efeitos
- **Riverpod:** `gameRulesProvider`, `matchStateProvider` por `gameId`

### Desvios / melhorias
- **MatchBody (441 linhas)** — concentra scroll, coach, board, actions, analytics; candidato a sub-widgets ou coordinator
- **BoardGameConfig** — vocabulário duplicado vs potencial `metadata.board` no JSON
- **Sem camada UseCase** — `MatchNotifier` chama engine directamente (OK até ~400 linhas de orquestração)

**Fluxo actual:**  
`UI → matchStateProvider → MatchEngine / EffectEngine → MatchEffectsState`  
`Rules ← CachedRulesRepository ← assets JSON`

---

## Flutter & Riverpod Analysis

| Item | Nota |
|------|------|
| `match_screen` slim | ✅ Boa decomposição |
| `ConsumerStatefulWidget` em `MatchBody` | ✅ Scoped state (dismissed tips) |
| `gameRulesProvider` no setup sheet | ✅ Async com fallback |
| Rebuild scope | ⚠️ `MatchBody` rebuild amplo; considerar `select` no provider |
| Modal setup | ⚠️ Testes widget sensíveis a `pumpAndSettle` — usar `pump` limitado |

---

## Backend Integration

- **Sem impacto Firestore** neste sprint — regras 100% bundled assets
- **REST-ready:** regras já abstraídas em `RulesRepository`; persistência de sessão local (`SharedPreferences`)
- **Offline-first:** regras e efeitos funcionam offline

---

## Security Assessment

| Área | Risco |
|------|-------|
| Secrets em código | ✅ Nenhum novo |
| Dados de partida local | Baixo — estado de jogo não sensível |
| Validação client-side | ⚠️ Esperado — app é tracker, não árbitro oficial |
| PDFs removidos | ✅ Reduz ruído no repo |

**Nota de produto:** Bloqueios são assistência local; não substituem regulamento oficial do torneio.

---

## Performance Analysis

- **JSON parse:** uma vez por `gameRulesProvider` — aceitável
- **Board slots:** máx. 6 — O(1) por avaliação de condição
- **Lista de ações:** filtrada por fase — sem virtualização necessária (poucas ações)
- **Risco:** múltiplos `setState`/notifier updates em sequência ao registar ação + board — monitorizar jank em dispositivos baixos

---

## Testing Assessment

| Camada | Cobertura |
|--------|-----------|
| Domain / engine | ✅ Forte (7 jogos) |
| Merger metadata | ✅ Smoke + coach tips |
| Widget match | ✅ Parcial (board, setup, badges, undo) |
| Integration Firebase | N/A neste escopo |
| E2E | ❌ Não adicionado |

**Fragilidade conhecida:** testes de `match_setup_sheet` com modal + FutureProvider — evitar `pumpAndSettle` infinito.

---

## Observability Assessment

- Analytics para interacções de home (commit anterior)
- Eventos de match expandidos no working tree
- Feedback via `MatchFeedback` + snackbar — boa rastreabilidade UX
- **Gap:** não há logging estruturado de “validation blocked” para debug em produção

---

## Technical Debt

### [MEDIUM] `MatchBody` monolítico (~441 linhas) — **RESOLVIDO**
Extraído para `match_body_header`, `match_body_play_area`, `match_body_phase_button`. `match_body.dart` ~340 linhas.

### [MEDIUM] Labels do tabuleiro só em `BoardGameConfig` — **RESOLVIDO**
`metadata.board` no JSON; `BoardGameConfig.resolve*` com fallback Dart.

### [LOW] Turno oponente 100% manual — **RESOLVIDO**
Botão de fase desactivado + bloqueio no engine + copy de orientação.

### [LOW] `MatchEngine` ~382 linhas
**Impacto:** Crescimento futuro.  
**Recomendação:** Extrair `MatchTurnCoordinator` quando passar de 450 linhas.  
**Esforço:** 1 dia (futuro).

### [LOW] Board slot labels em Dart + JSON separados
**Impacto:** Consistência copy.  
**Recomendação:** Unificar com sprint de i18n.  

### [FIXED neste sprint] Metadata perdida no merger
**Impacto:** Hints vazios após merge de efeitos.  
**Estado:** Corrigido em `game_rules_merger.dart`.

---

## Mandatory Corrections (antes de release público)

Nenhum **CRITICAL** ou **HIGH** bloqueante identificado para merge interno/beta.

| Item | Estado |
|------|--------|
| Bloquear avanço de fase durante `isOpponentTurn` | ✅ `MatchEngine.nextPhase` + botão desactivado |
| Widget test estável para setup sheet | ✅ |
| `flutter test test/features/match/` | ✅ (~205 testes) |

---

## Refactoring Recommendations (priorizado)

| # | Recomendação | Estado |
|---|--------------|--------|
| 1 | Desactivar fase durante turno oponente | ✅ |
| 2 | Dividir `MatchBody` | ✅ `match_body_header`, `match_body_play_area`, `match_body_phase_button` |
| 3 | `board` em JSON metadata | ✅ `metadata.board` nos 7 TCGs |
| 4 | `select()` no provider | ✅ `isOpponentTurn` |
| 5 | Analytics `match_validation_blocked` | ✅ |

### Ficheiros novos (ajustes pós-revisão)

- `lib/features/match/domain/board_metadata.dart`
- `lib/features/match/presentation/widgets/match_body_header.dart`
- `lib/features/match/presentation/widgets/match_body_play_area.dart`
- `lib/features/match/presentation/widgets/match_body_phase_button.dart`

---

## Risk Assessment

| Risco | Severidade | Mitigação |
|-------|------------|-----------|
| Jogador confia cegamente no bloqueio | Média | Copy “modo tracker” já presente |
| Regras JSON incorrectas | Média | Smoke + engine tests por jogo |
| Sessão corrupta com novo campo `isOpponentTurn` | Baixa | Default `false` no `fromJson` |
| Regressão ao adicionar 8º jogo | Baixa | Harness `kAllGameIds` |

---

## Governance Checklist

- [x] Clean Architecture respeitada (domain sem Flutter)
- [x] Separação de camadas
- [x] Lógica de negócio isolada no engine
- [x] Firebase não usado na UI de match
- [x] REST migration viável (rules repository)
- [x] Error handling via `MatchFeedback`
- [x] Security sem regressões óbvias
- [x] Performance aceitável para MVP
- [x] Testes cobrem caminhos críticos (202)
- [x] Observabilidade parcial (analytics)
- [x] Offline (assets bundled)
- [x] Débito técnico documentado
- [ ] Production readiness global (auth, Firestore, E2E) — fora do escopo deste sprint

---

## Rollout Strategy (sugestão)

1. **Commit** working tree com mensagem focada em “match engine v2 + 7 TCG validation”
2. **QA manual:** 1 partida por TCG — setup moeda, board flag, undo, turno oponente (Pokémon)
3. **Monitorização:** taxa de abandono na partida pós-setup sheet
4. **Rollback:** revert commit único; JSON assets versionados no mesmo commit

---

## Comandos úteis

```bash
# Testes do módulo match
flutter test test/features/match/

# Smoke estrutural + engine (7 jogos)
flutter test test/features/match/all_games_rules_smoke_test.dart
flutter test test/features/match/all_games_engine_rules_test.dart
```

---

## Referências rápidas

| Conceito | Ficheiro |
|----------|----------|
| Motor principal | `lib/features/match/domain/match_engine.dart` |
| Efeitos / locks | `lib/features/match/domain/effect_engine.dart` |
| Validações JSON | `lib/features/match/domain/validation_evaluator.dart` |
| Labels tabuleiro | `lib/features/match/domain/board_game_config.dart` |
| Metadata / hints | `lib/features/match/domain/game_rules_metadata.dart` |
| UI partida | `lib/features/match/presentation/widgets/match_body.dart` |
| Regras bundled | `assets/rules/*.json` |

---

*Documento gerado por revisão de engenharia sobre o estado do repositório em 24/05/2026.*
