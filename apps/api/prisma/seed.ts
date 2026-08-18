import { PrismaClient, PaymentMethod, PaymentStatus, RegistrationStatus } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

const FIRST_NAMES = [
  'Ana', 'Bruno', 'Carla', 'Diego', 'Eva', 'Felipe', 'Gabi', 'Hugo',
  'Iris', 'João', 'Kaio', 'Lia', 'Marcos', 'Nina', 'Otávio', 'Paula',
  'Rafa', 'Sofia', 'Tiago', 'Ursula', 'Vitor', 'Wendy', 'Yasmin', 'Zeca',
];

function slugify(value: string): string {
  return value
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

async function main() {
  const passwordHash = await bcrypt.hash('demo1234', 10);
  const termsAt = new Date('2026-01-10T12:00:00.000Z');

  await prisma.payment.deleteMany();
  await prisma.registration.deleteMany();
  await prisma.gameIdentifier.deleteMany();
  await prisma.storeMember.deleteMany();
  await prisma.event.deleteMany();
  await prisma.user.deleteMany();
  await prisma.store.deleteMany();
  await prisma.game.deleteMany();

  await prisma.game.createMany({
    data: [
      { id: 'pokemon', name: 'Pokémon TCG', accent: '#FBC02D' },
      { id: 'magic', name: 'Magic: The Gathering', accent: '#66BB6A' },
      { id: 'yugioh', name: 'Yu-Gi-Oh!', accent: '#FFD54F' },
      { id: 'one_piece', name: 'One Piece Card Game', accent: '#42A5F5' },
      { id: 'flesh_and_blood', name: 'Flesh and Blood', accent: '#EF5350' },
      { id: 'lorcana', name: 'Disney Lorcana', accent: '#AB47BC' },
    ],
  });

  await prisma.store.createMany({
    data: [
      {
        id: 'store_nexus',
        name: 'Arena Nexus',
        slug: 'arena-nexus',
        city: 'São Paulo',
        state: 'SP',
        locationName: 'Arena Nexus',
        address: 'Rua Augusta, 1200 — Consolação, São Paulo',
        whatsapp: '5511999887766',
        refundEnabled: true,
        refundFeePercent: 20,
        refundNote:
          'Reembolso somente via WhatsApp da loja, após pagamento aprovado no Mercado Pago.',
      },
      {
        id: 'store_dragao',
        name: 'Dragão de Aço',
        slug: 'dragao-de-aco',
        city: 'Curitiba',
        state: 'PR',
        locationName: 'Dragão de Aço',
        address: 'Av. Sete de Setembro, 800 — Centro, Curitiba',
        whatsapp: '5541999776655',
        refundEnabled: false,
        refundFeePercent: 100,
      },
    ],
  });

  await prisma.user.createMany({
    data: [
      {
        id: 'user_loja_nexus',
        email: 'loja@nexus.demo',
        passwordHash,
        fullName: 'Marina Costa',
        displayName: 'Marina',
        phone: '11999887766',
        role: 'STORE_ADMIN',
        acceptedTermsAt: termsAt,
      },
      {
        id: 'user_loja_dragao',
        email: 'loja@dragao.demo',
        passwordHash,
        fullName: 'Paulo Mendes',
        displayName: 'Paulo',
        phone: '41999776655',
        role: 'STORE_ADMIN',
        acceptedTermsAt: termsAt,
      },
      {
        id: 'user_ana',
        email: 'ana@player.demo',
        passwordHash,
        fullName: 'Ana Ribeiro',
        displayName: 'Ana',
        phone: '11987654321',
        city: 'São Paulo',
        state: 'SP',
        role: 'PLAYER',
        acceptedTermsAt: new Date('2026-02-01T12:00:00.000Z'),
      },
    ],
  });

  await prisma.storeMember.createMany({
    data: [
      {
        id: 'mem_nexus',
        storeId: 'store_nexus',
        userId: 'user_loja_nexus',
        role: 'OWNER',
      },
      {
        id: 'mem_dragao',
        storeId: 'store_dragao',
        userId: 'user_loja_dragao',
        role: 'OWNER',
      },
    ],
  });

  await prisma.gameIdentifier.create({
    data: {
      id: 'gid_ana_pkm',
      userId: 'user_ana',
      gameId: 'pokemon',
      type: 'PLAYER_ID',
      value: 'ANA-PKM-1024',
    },
  });

  await prisma.event.createMany({
    data: [
      {
        id: 'event_pokemon_lc',
        storeId: 'store_nexus',
        gameId: 'pokemon',
        slug: 'pokemon-league-challenge-nexus',
        name: 'Pokémon League Challenge',
        description:
          'League Challenge da temporada. Traga deck registrado e sleeved.',
        rules:
          'Check-in 13h30. Formato Standard. Lista de participantes fechada 15 min antes.',
        startsAt: new Date('2026-08-23T14:00:00-03:00'),
        locationName: 'Arena Nexus',
        address: 'Rua Augusta, 1200 — Consolação, São Paulo',
        maxParticipants: 32,
        priceCents: 5000,
        paymentMode: 'ONLINE',
        allowWaitlist: true,
        status: 'OPEN',
        refundEnabled: true,
        refundFeePercent: 20,
        refundNote:
          'Reembolso somente via WhatsApp da loja, após pagamento aprovado no Mercado Pago.',
        createdAt: new Date('2026-08-01T12:00:00.000Z'),
      },
      {
        id: 'event_fnm',
        storeId: 'store_dragao',
        gameId: 'magic',
        slug: 'fnm-dragao-aco',
        name: 'Friday Night Magic',
        description: 'FNM Standard. Evento lotado — waitlist aberta.',
        rules: 'WPN Regular. Chegue com antecedência.',
        startsAt: new Date('2026-08-21T19:30:00-03:00'),
        locationName: 'Dragão de Aço',
        address: 'Av. Sete de Setembro, 800 — Centro, Curitiba',
        maxParticipants: 16,
        priceCents: 4000,
        paymentMode: 'PLAYER_CHOICE',
        allowWaitlist: true,
        status: 'OPEN',
        refundEnabled: true,
        refundFeePercent: 10,
        createdAt: new Date('2026-08-02T12:00:00.000Z'),
      },
      {
        id: 'event_ygo',
        storeId: 'store_nexus',
        gameId: 'yugioh',
        slug: 'yugioh-locals-nexus',
        name: 'Yu-Gi-Oh! Locals',
        description: 'Torneio casual da semana. Pagamento no local.',
        rules: 'Advanced format. Pagamento na recepção.',
        startsAt: new Date('2026-08-25T19:00:00-03:00'),
        locationName: 'Arena Nexus',
        address: 'Rua Augusta, 1200 — Consolação, São Paulo',
        maxParticipants: 20,
        priceCents: 2500,
        paymentMode: 'PAY_ON_SITE',
        allowWaitlist: true,
        status: 'OPEN',
        refundEnabled: false,
        refundFeePercent: 100,
        createdAt: new Date('2026-08-05T12:00:00.000Z'),
      },
    ],
  });

  await seedSeated(
    'event_pokemon_lc',
    'store_nexus',
    24,
    5000,
    PaymentMethod.MERCADO_PAGO,
    PaymentStatus.APPROVED,
  );
  await seedSeated(
    'event_fnm',
    'store_dragao',
    16,
    4000,
    PaymentMethod.ON_SITE,
    PaymentStatus.PAY_ON_SITE,
  );
  await seedWaitlist('event_fnm', 'store_dragao', 3);
  await seedSeated(
    'event_ygo',
    'store_nexus',
    5,
    2500,
    PaymentMethod.ON_SITE,
    PaymentStatus.PAY_ON_SITE,
  );

  await refreshStatus('event_pokemon_lc');
  await refreshStatus('event_fnm');
  await refreshStatus('event_ygo');
}

async function seedSeated(
  eventId: string,
  storeId: string,
  count: number,
  amountCents: number,
  method: PaymentMethod,
  paymentStatus: PaymentStatus,
) {
  const createdAt = new Date('2026-08-10T12:00:00.000Z');
  const paidAt = new Date('2026-08-10T12:05:00.000Z');

  for (let i = 0; i < count; i += 1) {
    const first = FIRST_NAMES[i % FIRST_NAMES.length];
    const user = await prisma.user.create({
      data: {
        email: `${slugify(first)}.${i}.${eventId}@players.demo`,
        fullName: `${first} Silva`,
        displayName: first,
        phone: `1198888${String(1000 + i)}`,
        role: 'PLAYER',
        acceptedTermsAt: createdAt,
      },
    });
    const registration = await prisma.registration.create({
      data: {
        eventId,
        userId: user.id,
        storeId,
        status:
          paymentStatus === PaymentStatus.APPROVED
            ? RegistrationStatus.CONFIRMED
            : RegistrationStatus.REGISTERED,
        guestAccessToken: `tok_seed_${eventId}_${i}`,
        createdAt,
      },
    });
    await prisma.payment.create({
      data: {
        registrationId: registration.id,
        method,
        amountCents,
        status: paymentStatus,
        paidAt: paymentStatus === PaymentStatus.APPROVED ? paidAt : null,
        updatedAt: paidAt,
      },
    });
  }
}

async function seedWaitlist(eventId: string, storeId: string, count: number) {
  const extras = ['Pedro', 'Maria', 'Carlos'];
  const createdAt = new Date('2026-08-12T12:00:00.000Z');
  for (let i = 0; i < count; i += 1) {
    const name = extras[i] ?? `Wait ${i + 1}`;
    const user = await prisma.user.create({
      data: {
        email: `wait.${i}.${eventId}@players.demo`,
        fullName: `${name} Costa`,
        displayName: name,
        phone: `1197777${String(2000 + i)}`,
        role: 'PLAYER',
        acceptedTermsAt: createdAt,
      },
    });
    await prisma.registration.create({
      data: {
        eventId,
        userId: user.id,
        storeId,
        status: RegistrationStatus.WAITLIST,
        waitlistPosition: i + 1,
        guestAccessToken: `tok_wait_${eventId}_${i}`,
        createdAt,
      },
    });
  }
}

async function refreshStatus(eventId: string) {
  const event = await prisma.event.findUniqueOrThrow({ where: { id: eventId } });
  if (['DRAFT', 'CLOSED', 'CANCELLED', 'FINISHED'].includes(event.status)) {
    return;
  }
  const seatedCount = await prisma.registration.count({
    where: {
      eventId,
      status: { in: [RegistrationStatus.REGISTERED, RegistrationStatus.CONFIRMED] },
    },
  });
  const status = seatedCount >= event.maxParticipants ? 'FULL' : 'OPEN';
  await prisma.event.update({ where: { id: eventId }, data: { status } });
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
