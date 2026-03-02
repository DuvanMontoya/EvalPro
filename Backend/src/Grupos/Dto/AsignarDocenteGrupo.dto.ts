import { ApiProperty } from '@nestjs/swagger';
import { IsUUID } from 'class-validator';

export class AsignarDocenteGrupoDto {
  @ApiProperty({ description: 'ID del docente a asignar al grupo' })
  @IsUUID()
  idDocente!: string;
}
