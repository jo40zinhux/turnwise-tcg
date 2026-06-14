# TurnWise TCG — Documentação de Funcionalidades do Produto

**Versão:** 1.0  
**Público:** produto, design, QA, stakeholders e desenvolvimento  
**Complemento técnico:** [`arquitetura-tecnica.md`](arquitetura-tecnica.md)

---

## Índice

1. [O que é o TurnWise](#1-o-que-é-o-turnwise)
2. [Para quem é o produto](#2-para-quem-é-o-produto)
3. [Mapa da aplicação](#3-mapa-da-aplicação)
4. [Jornada do utilizador](#4-jornada-do-utilizador)
5. [Autenticação e conta](#5-autenticação-e-conta)
6. [Onboarding](#6-onboarding)
7. [Home — painel principal](#7-home--painel-principal)
8. [Catálogo de jogos](#8-catálogo-de-jogos)
9. [Experiência de partida](#9-experiência-de-partida)
10. [Funcionalidades por TCG](#10-funcionalidades-por-tcg)
11. [Cronómetro e modos de tempo](#11-cronómetro-e-modos-de-tempo)
12. [Encerrar partida e resumo](#12-encerrar-partida-e-resumo)
13. [Histórico de partidas](#13-histórico-de-partidas)
14. [Estatísticas](#14-estatísticas)
15. [Conquistas](#15-conquistas)
16. [Definições](#16-definições)
17. [Sincronização e offline](#17-sincronização-e-offline)
18. [Princípios de produto (o que o app promete — e o que não promete)](#18-princípios-de-produto)
19. [Glossário](#19-glossário)

---

## 1. O que é o TurnWise

O **TurnWise** é um **assistente de turno para partidas presenciais de TCG** (Trading Card Game). O jogador usa o telemóvel **ao lado da mesa física** para:

- Seguir a **estrutura de fases** do turno do jogo escolhido  
- **Registar ações** que fez (comprar, atacar, evoluir, etc.)  
- Receber **lembretes e bloqueios** quando as regras do jogo permitem validação automática  
- **Cronometrar** a partida ou séries (BO1/BO3)  
- **Guardar resultados**, ver estatísticas e desbloquear conquistas  

O TurnWise **não substitui** um árbitro oficial de torneio nem valida o estado completo do tabuleiro físico. Funciona como um **tracker inteligente e honesto**: ajuda a não esquecer regras comuns, mas deixa claro quando algo depende da confirmação manual do jogador.

### Jogos suportados (v1)

| Jogo | Nome na app |
|------|-------------|
| Pokémon TCG | Pokémon TCG |
| One Piece Card Game | One Piece TCG |
| Yu-Gi-Oh! | Yu-Gi-Oh! |
| Disney Lorcana | Disney Lorcana |
| Magic: The Gathering | Magic: The Gathering |
| Flesh and Blood | Flesh and Blood |
| Riftbound | Riftbound |

---

## 2. Para quem é o produto

| Perfil | Benefício |
|--------|-----------|
| **Jogador casual** | Lembretes de primeiro turno, fases e limites por turno |
| **Jogador em loja / mesa amiga** | Timer, histórico e stats entre sessões |
| **Quem alterna TCGs** | Um único app com vocabulário por jogo (ex.: “Exaurida” no Riftbound vs “Descansado” no One Piece) |
| **Utilizador com conta** | Backup de histórico e conquistas na cloud (Firebase) |

**Não é ideal para:** arbitragem competitiva automática, multiplayer online integrado, ou substituição do rulebook oficial em disputas.

---

## 3. Mapa da aplicação

```
                    ┌─────────────┐
                    │   Splash    │
                    └──────┬──────┘
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
        ┌──────────┐              ┌─────────────┐
        │  Login   │              │  (sessão    │
        └────┬─────┘              │   activa)   │
             │                    └─────────────┘
             ▼
      ┌─────────────┐
      │ Onboarding  │  (primeira vez)
      └──────┬──────┘
             ▼
      ┌─────────────────────────────────────┐
      │              HOME                    │
      │  retomar · stats · atalhos · jogos  │
      └───┬─────────┬─────────┬────────────┘
          │         │         │
    Histórico  Conquistas  Estatísticas
          │
          ▼
    ┌─────────────┐     Definições
    │   PARTIDA   │◄──── (logout, hápticos)
    │  por gameId │
    └──────┬──────┘
           │ encerrar
           ▼
    ┌─────────────┐
    │   Resumo    │  → volta à Home
    └─────────────┘
```

**Rotas principais (navegação):**

| Ecrã | Como chegar |
|------|-------------|
| Home | Após login + onboarding |
| Partida | Toque num jogo no Home |
| Histórico | Atalho no Home |
| Estatísticas | Atalho no Home |
| Conquistas | Atalho no Home ou Stats |
| Definições | Ícone ⚙️ na AppBar do Home |
| Resumo da partida | Ao encerrar uma partida |

---

## 4. Jornada do utilizador

### 4.1 Primeira utilização

1. Abre a app → **Splash** (aguarda estado de login).  
2. **Login** — convidado, Google ou Apple.  
3. **Onboarding** — 3 ecrãs explicativos (pode “Pular”).  
4. Chega ao **Home** — escolhe um TCG e inicia a primeira partida.

### 4.2 Iniciar uma partida

1. No Home, toca num jogo (carousel, recentes ou lista completa).  
2. Se for partida nova: escolhe **perfil de timer** (Casual, BO1, BO3, Round).  
3. Na partida: define **quem joga primeiro** (moeda) — obrigatório na primeira vez.  
4. Joga a partida física usando a app como guia.

### 4.3 Durante a partida

- Avança **fases** do turno.  
- Toca nos **chips de ação** para registar o que fez.  
- Ajusta **tabuleiro** (slots + flags) e **recursos** quando o jogo exige.  
- Usa o **cronómetro** no topo.  
- No fim do próprio turno → **Terminar turno** → **Turno do oponente** → **Oponente terminou**.

### 4.4 Terminar

1. Menu ⋮ → **Encerrar partida** (ou fluxo equivalente).  
2. Escolhe **resultado** (vitória, derrota, empate, abandonada) e notas opcionais.  
3. Vê o **Resumo** — duração, conquistas novas, botão para Home.  
4. A partida fica no **Histórico** e alimenta **Estatísticas**.

### 4.5 Retomar partida interrompida

Se sair da app a meio de uma partida (sem encerrar):

- No Home aparece o banner **“Retomar partida”** com o nome do jogo.  
- Pode **Retomar** ou **Descartar** (com confirmação).  
- O estado guardado inclui fase, ações usadas, efeitos, tabuleiro, timer e ordem de turnos.

---

## 5. Autenticação e conta

### O que o utilizador pode fazer

| Método | Descrição |
|--------|-----------|
| **Convidado (anónimo)** | Entrar sem email — dados locais; sync limitado à conta criada depois |
| **Google** | Sign-in com conta Google |
| **Apple** | Sign in with Apple (iOS) |
| **Sair** | Definições → Sair da conta (com confirmação) |

### Comportamento de produto

- Sem login, o utilizador **não acede** ao Home (redireccionado para Login).  
- Após login, o perfil é sincronizado em **Firestore** (`users/{uid}`) com email, nome e último login.  
- A **sincronização de histórico e conquistas** corre em background quando há sessão autenticada.

---

## 6. Onboarding

**Objectivo:** explicar valor em menos de 1 minuto.

| Ecrã | Mensagem (resumo) |
|------|-------------------|
| 1 | “Jogue com confiança” — assistente para mesas presenciais |
| 2 | “Nunca perca uma ação importante” — checklist, prémios, lembretes |
| 3 | “Evolua a cada partida” — histórico, estatísticas, conquistas |

- Botão **Pular** em qualquer momento.  
- Na última página, **Começar** → Home.  
- Só aparece **uma vez** (flag guardada localmente).

---

## 7. Home — painel principal

O Home é o **centro de comando** após o login.

### 7.1 Cabeçalho

- Saudação contextual.  
- Indicação se existe **partida em curso**.

### 7.2 Retomar partida

Se há sessão activa guardada:

- **Banner** com nome do jogo.  
- **Retomar** — abre a partida no mesmo estado.  
- **Fechar (X)** — pede confirmação e apaga a sessão activa.

### 7.3 Resumo rápido (stats no dashboard)

- Métricas derivadas do histórico local (ex.: partidas recentes, atividade).  
- Atualiza após sync ou novas partidas.

### 7.4 Atalhos

| Atalho | Destino |
|--------|---------|
| Histórico | Lista de partidas terminadas |
| Conquistas | Progresso e troféus |
| Estatísticas | Winrate, gráficos, breakdown por jogo |

### 7.5 Jogos recentes

- Carousel horizontal dos TCGs que jogaste **recentemente** (por histórico).  
- Subtítulo com contexto de actividade.  
- Toque → inicia/retoma partida desse jogo.

### 7.6 Todos os jogos

- Secção com **carousel** dos 7 jogos (cores e ícones por TCG).  
- **Nudge de scroll** animado nas primeiras visitas (dica para deslizar).  
- Botão **“Ver todos”** → folha em grelha com todos os jogos.

### 7.7 Definições

- Ícone ⚙️ na AppBar do Home.

---

## 8. Catálogo de jogos

- Lista fixa definida em `games_manifest.json` (nome, ícone, cor de destaque).  
- Não há loja in-app nem DLC de jogos: novos TCGs exigem actualização da app.  
- Cada jogo carrega **regras próprias** (fases, acções, validações) ao abrir a partida.

---

## 9. Experiência de partida

A partida é o **núcleo do produto**. Combina guia de turno, registo de acções e assistência de regras.

### 9.1 Fluxo de entrada

| Passo | O que acontece |
|-------|----------------|
| Escolha do timer | Sheet: Casual / BO1 / BO3 / Round timer |
| Setup da moeda | Sheet: “Eu jogo primeiro” vs “Oponente joga primeiro” + dica específica do jogo |
| Carregar regras | Spinner se necessário; erro → voltar ao Home |

O setup da moeda é **universal** (todos os TCGs): a ordem de turnos activa lembretes e validações de primeiro turno.

### 9.2 Barra superior da partida

| Elemento | Função |
|----------|--------|
| **Cronómetro** | Tempo decorrido ou countdown; alertas visuais/hápticos |
| **Progresso de fases** | Fase actual + título (ex.: “Draw Phase”) |
| **Contexto de turno** | Número do turno, quem jogou primeiro, botão **Alterar** |
| **Turno do oponente** | Após “Terminar turno”, mostra estado + **Oponente terminou** |
| **Barra de recursos** | Só em jogos que usam DON!!, AP ou Energy (ver secção 10) |
| **Painel de tabuleiro** | Slots com flags por jogo (ver secção 9.5) |

### 9.3 Lista de fases

- Por defeito mostra só a **fase actual** (tile destacado).  
- Opção **“Ver todas as fases”** para ver o turno completo.  
- Fases passadas aparecem como concluídas visualmente.

### 9.4 Zona de jogo (acções e estado)

#### Banner “Modo tracker”

- Explica que a app é um **tracker**: acções com ícone ℹ️ precisam de confirmação no tabuleiro físico.  
- Pode ser dispensado (X).

#### Coach tips (dicas contextuais)

- Banners no **turno 1** com regras do jogo (ex.: “sem Apoiador no primeiro turno” no Pokémon).  
- Variam conforme **quem ganhou a moeda**.  
- Dispensáveis; não voltam a aparecer na mesma partida para a mesma dica.

#### Dica de undo

- Após a primeira acção registada: lembrete de que pode **tocar outra vez** (ou manter premido) para **desfazer**.

#### Estado da mesa (efeitos)

- Lista de **efeitos activos** (locks, durações).  
- **Marcar efeito** manualmente a partir da biblioteca do jogo (ex.: Item Lock, Exerted).  
- Remover efeito com toque.  
- Mostra **acções bloqueadas** quando um lock está activo.

#### Checkups

- Lembretes automáticos entre turnos ou em momentos definidos nas regras (ex.: passos de manutenção).

#### Chips de acção

- Uma grelha de acções **da fase actual** (ex.: só acções da “Draw Phase”).  
- Estados visuais:  
  - **Normal** — pronto a registar  
  - **Usado** — já registado neste turno (check)  
  - **Esgotado** — limite atingido (ex.: 1 land/turno)  
- **Toque** — regista a acção (ou desfaz se limite 1 e já usada).  
- **Manter premido** — desfaz em acções multi-uso; abre **folha com texto completo da regra** quando há lembrete ℹ️.  
- **Badge ℹ️** — validação tipo “condição” (depende do tabuleiro ou confirmação manual).

#### Feedback imediato

- **Snackbars** de sucesso, erro ou informação após cada acção ou bloqueio.  
- **Hápticos** configuráveis (Definições).

### 9.5 Tabuleiro (tracker simplificado)

**Objectivo:** representar o mínimo do tabuleiro necessário para regras com “alvo” (evoluir, challenge, posição de ataque, etc.).

| Funcionalidade | Descrição |
|----------------|-----------|
| Slots | Labels por jogo (ex.: Ativo, Banco 1, Banco 2 no Pokémon) |
| Adicionar / remover slot | Até 6 slots; mínimo 1 |
| Flags por slot | Chips por TCG (ver tabela na secção 10) |
| Escolha de alvo | Antes de certas acções, sheet para escolher slot e ajustar flags |

**Flesh and Blood:** slots existem para referência; mensagem explica que o jogo usa **Action Points**, não estados no tabuleiro.

### 9.6 Avançar fase e terminar turno

| Botão | Quando |
|-------|--------|
| **Próxima fase** | Ainda há fases no turno |
| **Terminar turno** | Última fase do turno |
| *(desactivado)* | Durante **turno do oponente** — deve usar “Oponente terminou” |

Ao terminar o turno:

- Contador de turno incrementa.  
- Flags “neste turno” no tabuleiro limpam.  
- Recursos podem resetar conforme regras (ex.: DON no novo turno).  
- Entra em **turno do oponente** até o jogador confirmar que o oponente acabou.

### 9.7 Menu da partida (⋮)

| Opção | Função |
|-------|--------|
| **Quem joga primeiro** | Reabre sheet da moeda (corrige erro) |
| **Encerrar partida** | Diálogo de resultado → resumo → histórico |

### 9.8 Persistência automática

- A partida **grava-se sozinha** no dispositivo (debounce ~400 ms).  
- Fechar a app não apaga o progresso se não encerrar explicitamente.

---

## 10. Funcionalidades por TCG

Cada jogo tem **fases**, **acções** e **regras** próprias. A tabela resume o que o utilizador **vê e sente** na app — não é o rulebook completo.

### 10.1 Visão comparativa

| Jogo | Fases (ex.) | Recursos na app | Tabuleiro (flags) | Destaques de regras na app |
|------|-------------|-----------------|-------------------|----------------------------|
| **Pokémon** | Draw → Ações → Atacar | — | Entrou em jogo neste turno | 1º turno: sem Apoiador/ataque (quem vai primeiro); evoluir; energia; locks de Item |
| **One Piece** | Fases do OP | DON!! (+/−) | Descansado (Rested) | 1º jogador não compra no turno 1; limite 2 DON/turno; personagens descansados |
| **Yu-Gi-Oh!** | Fases YGO | — | Em posição de ataque | Ninguém ataca no 1º turno do duelo; posição para atacar |
| **Lorcana** | Fases Lorcana | — | Exertado | Sem challenge no 1º turno; exerted não challenge; ink 1×/turno |
| **Magic** | Fases MTG | — | Enjoo de invocação | 1 land/turno; criaturas não atacam no turno em que entram |
| **Flesh and Blood** | Action Phase, etc. | Action Points | *(sem flags — só slots)* | AP para jogar acções e atacar; Go Again |
| **Riftbound** | Beginning, Action, etc. | Energy (+/−) | **Exaurida** | Channel runes; draw na beginning; unidades exauridas |

### 10.2 Pokémon TCG (detalhe)

**Fases:** Draw Phase → Ações do turno → Atacar.

**Acções típicas registáveis:** baixar básico, evoluir, anexar energia, item, apoiador, recuar, atacar.

**Regras assistidas:**

- Quem foi primeiro no turno 1: **sem Apoiador** e **sem atacar**.  
- **Ninguém evolui** no primeiro turno global.  
- Evoluir bloqueado se o Pokémon **entrou em jogo neste turno** (com alvo no tabuleiro).  
- Limite de **1 energia** anexada por turno.  
- Efeitos como **Item Lock** (até fim do turno do oponente).

### 10.3 One Piece (detalhe)

**Recursos:** contador **DON!!** manual (gasta ao jogar cartas com custo).

**Tabuleiro:** flag **Descansado (Rested)** em personagens.

**Regras assistidas:** primeiro jogador **não compra** na Draw do turno 1; limite de adicionar DON por turno; validações de custo.

### 10.4 Yu-Gi-Oh! (detalhe)

**Tabuleiro:** **Em posição de ataque** para monstros que vão atacar.

**Regras assistidas:** **nenhum ataque** no primeiro turno do duelo (ambos os jogadores); lembrete em acções de ataque.

### 10.5 Disney Lorcana (detalhe)

**Tabuleiro:** **Exertado** em personagens.

**Regras assistidas:** **sem desafiar** no primeiro turno; não challenge exerted; **ink** uma vez por turno.

### 10.6 Magic: The Gathering (detalhe)

**Tabuleiro:** **Enjoo de invocação** (entrou neste turno).

**Regras assistidas:** **uma land por turno**; criaturas com enjoo não atacam no turno de entrada.

### 10.7 Flesh and Blood (detalhe)

**Recursos:** **Action Points** — a app bloqueia jogar acção/atacar sem AP.

**Tabuleiro:** apenas slots nomeados (Herói, Equipamento); sem flags — copy explica uso de AP.

### 10.8 Riftbound (detalhe)

**Recursos:** **Energy** para jogar unidades.

**Tabuleiro:** **Exaurida** (mesma mecânica interna que “exerted”, label do Riftbound).

**Regras assistidas:** channel runes, draw na fase inicial, custos de energy, lembrete de unidades prontas vs exauridas.

---

## 11. Cronómetro e modos de tempo

Escolhido **uma vez por partida** (sheet no início).

| Perfil | Comportamento para o jogador |
|--------|------------------------------|
| **Casual** | Cronómetro livre, sem limite |
| **BO1** | Timer de ronda (~50 min), alertas ao aproximar do fim |
| **BO3** | Melhor de 3 jogos; regista vitórias na série; timer por jogo |
| **Round timer** | Countdown configurável por ronda |

**Na partida:**

- Play / pause do timer.  
- Cor e háptico mudam em **aviso** e **tempo esgotado**.  
- Em BO3, placar de jogos ganhos na série (persistido na sessão).

---

## 12. Encerrar partida e resumo

### 12.1 Diálogo “Encerrar partida”

- Pergunta **como terminou** (perspectiva do jogador local):  
  - Vitória  
  - Derrota  
  - Empate  
  - Abandonada  
- Campo **observações** opcional (até 500 caracteres).

### 12.2 O que acontece ao confirmar

1. Grava **MatchRecord** no histórico local.  
2. Tenta enviar para **Firestore** se logado (estado: sincronizado / pendente / falhou).  
3. Avalia **conquistas** novas.  
4. **Apaga** a sessão activa.  
5. Navega para o **Resumo**.

### 12.3 Ecrã de resumo

- Visual grande do **resultado** (cor e ícone).  
- Duração, jogo, modo de timer, notas.  
- Lista de **conquistas desbloqueadas** nesta partida (com feedback háptico).  
- Botão para voltar ao **Home**.

---

## 13. Histórico de partidas

- Lista cronológica de partidas **terminadas** (mais recentes primeiro).  
- Cada item mostra: jogo, data, resultado, duração, estado de sync (quando relevante).  
- Toque pode abrir detalhe / contexto (conforme implementação do tile).  
- Estado vazio: convida a completar a primeira partida.

**Fonte de dados:** armazenamento **local (Hive)**; após login, dados podem ser enriquecidos pelo **sync** da cloud.

---

## 14. Estatísticas

Calculadas **a partir do histórico local** — não há servidor de analytics de stats.

| Métrica | Descrição |
|---------|-----------|
| Total de partidas | Contagem global |
| Winrate | % vitórias sobre partidas com resultado |
| Tempo médio | Duração média das partidas |
| Partidas esta semana | Actividade recente |
| Por TCG | Partidas e desempenho por jogo |
| Frequência semanal | Gráfico de partidas por semana |

- Estado vazio se nunca completou partidas.  
- Atalho para Conquistas na AppBar.

---

## 15. Conquistas

- Lista de troféus definidos em `achievements.json`.  
- Cada conquista tem: título, descrição, ícone, **meta numérica** (ex.: 10 partidas, 5 vitórias).  
- Progresso calculado após cada partida.  
- **Desbloqueio** com destaque no resumo pós-partida.  
- Sincronização com Firestore para utilizadores logados.

**Exemplos actuais:**

| Conquista | Critério |
|-----------|----------|
| Primeira partida | 1 partida completa |
| Veterano | 10 partidas |
| Competidor | 5 vitórias |

---

## 16. Definições

| Opção | Efeito |
|-------|--------|
| **Vibração háptica** | Liga/desliga feedback tátil (acções, fases, timer, conquistas) |
| **Sons** | Preparado na UI; marcado como “em breve” |
| **Sair da conta** | Logout com confirmação |

---

## 17. Sincronização e offline

### O que funciona offline

- Iniciar e jogar partidas (regras em assets).  
- Guardar sessão activa e histórico local.  
- Ver estatísticas e conquistas já no dispositivo.

### O que precisa de rede

- Login Google / Apple.  
- Primeiro sync após login (pull de partidas/conquistas da cloud).  
- Upload imediato de partida terminada (se falhar, fica **pendente** e retry automático depois).

### Comportamento de sync (utilizador)

- **Transparente** — não há ecrã de “a sincronizar” obrigatório.  
- Em caso de conflito, prevalece o registo **mais recente** (`updatedAt`).  
- Utilizador com vários dispositivos pode ver histórico alinhado após abrir a app logado.

---

## 18. Princípios de produto

### O que o TurnWise promete

| Promessa | Como se manifesta |
|----------|-------------------|
| Ajudar a não esquecer o fluxo do turno | Fases, CTA, coach tips |
| Registar o que já fizeste | Chips, contadores, undo |
| Aplicar regras simples e repetíveis | Limites por turno, primeiro turno, recursos |
| Ser honesto sobre limites | Banner tracker, badge ℹ️, long-press com regra completa |
| Guardar a tua jornada | Histórico, stats, conquistas, sync |

### O que o TurnWise não promete

| Limitação | Porquê importa para o utilizador |
|-----------|----------------------------------|
| Não vê as cartas na mesa | Condições complexas exigem alvo manual ou ℹ️ |
| Não substitui judge de torneio | Disputas precisam do rulebook oficial |
| Não há jogo online integrado | Oponente é físico; “turno oponente” é manual |
| Regras actualizam com a app | Erratas de TCG requerem update da app |
| Sons ainda não activos | Definição mostra “em breve” |

### Tipos de validação (linguagem de produto)

| Tipo | Experiência |
|------|-------------|
| **Bloqueio automático** | Toque na acção → mensagem de erro (ex.: limite atingido, sem AP) |
| **Lembrete (ℹ️)** | Acção permitida, mas com aviso — jogador confirma no físico |
| **Com alvo no tabuleiro** | Escolhe slot + flags → pode passar a bloquear (ex.: evoluir Pokémon que entrou este turno) |

---

## 19. Glossário

| Termo | Significado no TurnWise |
|-------|-------------------------|
| **Partida (sessão activa)** | Jogo em curso, ainda não arquivado no histórico |
| **Turno** | Ciclo de fases do jogador local; incrementa ao “Terminar turno” |
| **Turno do oponente** | Período entre o fim do teu turno e “Oponente terminou” |
| **Fase** | Etapa dentro do turno (ex.: Draw Phase) |
| **Acção** | Botão que registas (ex.: “Usar Item”, “Atacar”) |
| **Chip esgotado** | Acção já usada o máximo de vezes neste turno |
| **Tracker** | Modo em que a app regista e lembra, sem controlar o físico |
| **Exaurida / Exertado / Descansado** | Mesma ideia mecânica (não pode actuar de novo), nomes por TCG |
| **Enjoo de invocação** | Magic: criatura não ataca no turno em que entra |
| **Entrou em jogo neste turno** | Pokémon / Magic: restrições de evoluir ou atacar |
| **MatchRecord** | Partida terminada guardada no histórico |
| **Sync pendente** | Partida guardada localmente, upload à cloud ainda não confirmado |

---

## Documentos relacionados

| Documento | Conteúdo |
|-----------|----------|
| [`arquitetura-tecnica.md`](arquitetura-tecnica.md) | Camadas, dados, motor, Firebase, testes |
| [`engineering-review-and-changelog.md`](engineering-review-and-changelog.md) | Changelog recente e revisão de engenharia |
| [`README.md`](../README.md) | Setup Firebase, build, deploy |

---

*Documentação de produto TurnWise — descreve funcionalidades da app tal como implementadas no código e assets actuais.*
