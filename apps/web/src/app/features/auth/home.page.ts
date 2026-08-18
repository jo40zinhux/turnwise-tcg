import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'tw-home-page',
  imports: [RouterLink],
  template: `
    <main class="page-narrow stack-lg">
      <img src="/logo.svg" width="64" height="64" alt="TurnWise" />
      <h1>TurnWise Events</h1>
      <p class="muted">
        Inscrições, vagas, pagamentos, desistências e waitlist para eventos TCG.
        Sem Swiss, sem bracket — só o controle da lista.
      </p>
      <div class="stack">
        <a class="btn btn-primary" routerLink="/login">Entrar</a>
        <a class="btn btn-surface" routerLink="/signup">Criar conta de jogador</a>
      </div>
      <section class="surface stack">
        <h3>Eventos demo</h3>
        <a routerLink="/events/arena-nexus/pokemon-league-challenge-nexus">Pokémon League Challenge · vagas abertas · Mercado Pago</a>
        <a routerLink="/events/dragao-de-aco/fnm-dragao-aco">Friday Night Magic · lotado · waitlist</a>
        <a routerLink="/events/arena-nexus/yugioh-locals-nexus">Yu-Gi-Oh! Locals · pagamento no local</a>
      </section>
      <p class="subtle">Loja piloto: loja&#64;nexus.demo / demo1234</p>
    </main>
  `,
})
export class HomePageComponent {}
