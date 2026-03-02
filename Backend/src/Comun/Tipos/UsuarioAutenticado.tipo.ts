import { RolUsuario } from '@prisma/client';

export interface UsuarioAutenticado {
  id: string;
  correo: string;
  rol: RolUsuario;
  idInstitucion: string | null;
}
