import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MinLength } from 'class-validator';

export class CambiarContrasenaPrimerLoginDto {
  @ApiProperty({
    description: 'Nueva contraseña definitiva del usuario',
    example: 'ContrasenaSegura123!',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  nuevaContrasena!: string;
}
