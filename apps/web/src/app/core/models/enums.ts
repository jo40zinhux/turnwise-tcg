export const EventStatus = {
  DRAFT: 'DRAFT',
  OPEN: 'OPEN',
  FULL: 'FULL',
  CLOSED: 'CLOSED',
  CANCELLED: 'CANCELLED',
  FINISHED: 'FINISHED',
} as const;
export type EventStatus = (typeof EventStatus)[keyof typeof EventStatus];

export const RegistrationStatus = {
  REGISTERED: 'REGISTERED',
  CONFIRMED: 'CONFIRMED',
  WAITLIST: 'WAITLIST',
  CANCELLED: 'CANCELLED',
  NO_SHOW: 'NO_SHOW',
} as const;
export type RegistrationStatus =
  (typeof RegistrationStatus)[keyof typeof RegistrationStatus];

export const PaymentStatus = {
  PENDING: 'PENDING',
  APPROVED: 'APPROVED',
  FAILED: 'FAILED',
  CANCELLED: 'CANCELLED',
  PAY_ON_SITE: 'PAY_ON_SITE',
} as const;
export type PaymentStatus = (typeof PaymentStatus)[keyof typeof PaymentStatus];

export const PaymentMethod = {
  MERCADO_PAGO: 'MERCADO_PAGO',
  ON_SITE: 'ON_SITE',
} as const;
export type PaymentMethod = (typeof PaymentMethod)[keyof typeof PaymentMethod];

export const PaymentMode = {
  ONLINE: 'ONLINE',
  PAY_ON_SITE: 'PAY_ON_SITE',
  PLAYER_CHOICE: 'PLAYER_CHOICE',
} as const;
export type PaymentMode = (typeof PaymentMode)[keyof typeof PaymentMode];

export const UserRole = {
  PLAYER: 'PLAYER',
  STORE_ADMIN: 'STORE_ADMIN',
  SUPER_ADMIN: 'SUPER_ADMIN',
} as const;
export type UserRole = (typeof UserRole)[keyof typeof UserRole];

export const ParticipantFilter = {
  ALL: 'ALL',
  CONFIRMED: 'CONFIRMED',
  PENDING: 'PENDING',
  PAID: 'PAID',
  UNPAID: 'UNPAID',
  PAY_ON_SITE: 'PAY_ON_SITE',
  WAITLIST: 'WAITLIST',
  CANCELLED: 'CANCELLED',
} as const;
export type ParticipantFilter =
  (typeof ParticipantFilter)[keyof typeof ParticipantFilter];
