import { Injectable } from '@angular/core';
import { Event, RegistrationView, Store } from '../models/domain';
import { formatBrl } from '../../shared/pipes/formatters';

@Injectable({ providedIn: 'root' })
export class WhatsAppService {
  refundUrl(view: RegistrationView): string {
    const { store, event, player, payment, registration } = view;
    const fee = event.refundPolicy.enabled
      ? `Taxa informada: ${event.refundPolicy.feePercent}% (reembolso de ${100 - event.refundPolicy.feePercent}% se a loja confirmar).`
      : 'A loja informou que não garante reembolso automático.';
    const amount = payment ? formatBrl(payment.amountCents) : '';
    const message = [
      `Olá, ${store.name}!`,
      `Sou ${player.fullName} e gostaria de solicitar o reembolso da inscrição no evento "${event.name}".`,
      `Inscrição: ${registration.id}`,
      amount ? `Valor pago: ${amount}` : '',
      fee,
      'Podem me ajudar com essa solicitação?',
    ]
      .filter(Boolean)
      .join('\n');
    return `https://wa.me/${store.whatsapp}?text=${encodeURIComponent(message)}`;
  }

  storeUrl(store: Store, event?: Event): string {
    const text = event
      ? `Oi, ${store.name}! Tenho uma dúvida sobre o evento ${event.name}.`
      : `Oi, ${store.name}!`;
    return `https://wa.me/${store.whatsapp}?text=${encodeURIComponent(text)}`;
  }
}
