import {
  IsBoolean,
  IsEmail,
  IsEnum,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator';
import { PaymentMethod } from '@prisma/client';

export class RegisterDto {
  @IsString()
  @MinLength(2)
  fullName!: string;

  @IsEmail()
  email!: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsString()
  displayName?: string;

  @IsOptional()
  @IsString()
  gameIdentifierValue?: string;

  @IsOptional()
  @IsEnum(PaymentMethod)
  paymentChoice?: PaymentMethod;

  @IsBoolean()
  acceptedTerms!: boolean;

  @IsOptional()
  @IsString()
  createPassword?: string;

  @IsOptional()
  @IsString()
  storeSlug?: string;

  @IsOptional()
  @IsString()
  eventSlug?: string;
}
