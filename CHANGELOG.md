# Changelog

All notable changes to TurnWise are documented in this file.

## [1.1.0] — 2026-06-18

### Added
- Life tracker (prêmios/vida) em todos os TCGs com contadores configuráveis por jogo
- Modo **Ajustar turno** no setup — edita formato/ordem sem resetar contadores ao vivo
- Tabuleiro expande automaticamente na primeira utilização por jogo
- Snackbar com **Desfazer** ao remover slot do tabuleiro
- Testes de integração cross-game para checkups e efeitos

### Fixed
- **Confusion** (e outros checkups) apareciam sem efeito ativo ao avançar fase
- Checkups `before_attack` limitados à fase de ataque
- Seletor de alvo do tabuleiro não abre quando a ação já está bloqueada (ex.: ataque turno 1)
- Copy One Piece: "Draw Phase" → "fase de compra"

### Changed
- Polish UX da ecrã de partida (touch targets 44pt, scroll em sheets, `withValues`)
- App bloqueado em **portrait** (Android + iOS)
- Tooltips de ações: "Mantém pressionado" (PT correto)

### Technical
- `CheckupDefinition.shouldFire()` — gate único para lembretes condicionados a efeitos
- `ActionEnforcement.shouldPromptForTarget()` — skip do picker quando bloqueado
- 363 testes automatizados

## [1.0.0] — baseline

- Tracker de turnos para 7 TCGs (Pokémon, Magic, Yu-Gi-Oh!, Lorcana, One Piece, FAB, Riftbound)
- Motor de regras JSON, efeitos, tabuleiro simplificado, timer de partida
- Auth Firebase, histórico local, sync cloud
