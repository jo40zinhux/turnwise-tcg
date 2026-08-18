import { IsOptional, IsString, MinLength } from 'class-validator';

export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  fullName?: string;

  @IsOptional()
  @IsString()
  displayName?: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsString()
  city?: string;

  @IsOptional()
  @IsString()
  state?: string;
}

export class GameIdentifierDto {
  @IsString()
  gameId!: string;

  @IsString()
  type!: string;

  @IsString()
  @MinLength(1)
  value!: string;
}

export class SetPasswordDto {
  @IsString()
  @MinLength(6)
  password!: string;
}
