export function formatBrl(cents: number): string {
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
  }).format(cents / 100);
}

export function formatEventWhen(iso: string): string {
  const date = new Date(iso);
  const day = new Intl.DateTimeFormat('pt-BR', {
    weekday: 'short',
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }).format(date);
  const time = new Intl.DateTimeFormat('pt-BR', {
    hour: '2-digit',
    minute: '2-digit',
  }).format(date);
  return `${day} · ${time}`;
}

export function refundCopy(enabled: boolean, feePercent: number): string {
  if (!enabled) {
    return 'Esta loja não garante reembolso automático. Se você já pagou pelo Mercado Pago, fale no WhatsApp da loja.';
  }
  return `Reembolsos de inscrições pagas são solicitados pelo WhatsApp da loja. Taxa de ${feePercent}% (você recebe ${100 - feePercent}% se a loja confirmar). Quem ainda não pagou ou escolheu pagar no local pode desistir por aqui.`;
}
