import { Component } from '@angular/core';

@Component({
  selector: 'tw-privacy-page',
  template: `
    <main class="page-narrow stack">
      <h1>Política de privacidade</h1>
      <p class="muted">
        Tratamos nome, e-mail, telefone e identificadores de jogo para operar a inscrição.
        A página pública do evento mostra apenas vagas e status — sem lista de nomes.
      </p>
      <p class="muted">
        Você pode solicitar correção ou exclusão dos seus dados à loja organizadora e,
        futuramente, pelo canal da plataforma. Não vendemos dados pessoais.
      </p>
    </main>
  `,
})
export class PrivacyPageComponent {}
