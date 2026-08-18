import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import { EventStatus, PaymentMode } from '@prisma/client';

export class RefundPolicyDto {
  @IsBoolean()
  enabled!: boolean;

  @IsInt()
  @Min(0)
  @Max(100)
  feePercent!: number;

  @IsOptional()
  @IsString()
  note?: string;
}

export class CreateEventDto {
  @IsString()
  name!: string;

  @IsString()
  gameId!: string;

  @IsString()
  description!: string;

  @IsString()
  rules!: string;

  @IsString()
  startsAt!: string;

  @IsString()
  locationName!: string;

  @IsString()
  address!: string;

  @IsInt()
  @Min(1)
  maxParticipants!: number;

  @IsInt()
  @Min(0)
  priceCents!: number;

  @IsEnum(PaymentMode)
  paymentMode!: PaymentMode;

  @IsBoolean()
  allowWaitlist!: boolean;

  @ValidateNested()
  @Type(() => RefundPolicyDto)
  refundPolicy!: RefundPolicyDto;
}

export class UpdateEventDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  gameId?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  rules?: string;

  @IsOptional()
  @IsString()
  startsAt?: string;

  @IsOptional()
  @IsString()
  locationName?: string;

  @IsOptional()
  @IsString()
  address?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  maxParticipants?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  priceCents?: number;

  @IsOptional()
  @IsEnum(PaymentMode)
  paymentMode?: PaymentMode;

  @IsOptional()
  @IsBoolean()
  allowWaitlist?: boolean;

  @IsOptional()
  @ValidateNested()
  @Type(() => RefundPolicyDto)
  refundPolicy?: RefundPolicyDto;
}

export class SetEventStatusDto {
  @IsEnum(EventStatus)
  status!: EventStatus;
}
