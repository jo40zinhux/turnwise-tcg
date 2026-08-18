import { Component } from '@angular/core';

@Component({
  selector: 'tw-terms-page',
  template: `
    <main class="page-narrow stack">
      <h1>Termos de uso</h1>
      <p class="muted">
        O TurnWise Events organiza inscrições, vagas, pagamentos, desistências e waitlist.
        Não executa o torneio (Swiss, bracket, mesas ou resultados).
      </p>
      <p class="muted">
        Dados informados na inscrição são usados para a lista do evento e comunicação da loja.
        Pagamentos online são processados pelo Mercado Pago. A confirmação de pagamento só vale
        após a notificação recebida pelo sistema, nunca pela declaração do jogador.
      </p>
    </main>
  `,
})
export class TermsPageComponent {}
