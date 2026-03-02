import { ApiProperty } from '@nestjs/swagger';
import { IsUUID } from 'class-validator';

export class InscribirEstudianteGrupoDto {
  @ApiProperty({ description: 'ID del estudiante a inscribir en el grupo' })
  @IsUUID()
  idEstudiante!: string;
}
