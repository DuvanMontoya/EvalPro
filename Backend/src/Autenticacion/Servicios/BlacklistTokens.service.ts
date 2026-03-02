import { Injectable } from '@nestjs/common';

/**
 * Blacklist en memoria para invalidar access tokens en logout.
 * Se usa como salvaguarda hasta integrar almacenamiento distribuido.
 */
@Injectable()
export class BlacklistTokensService {
  private readonly tokensRevocados = new Map<string, number>();

  revocar(jti: string, expUnix: number): void {
    if (!jti || !Number.isFinite(expUnix)) {
      return;
    }

    this.tokensRevocados.set(jti, expUnix * 1000);
    this.limpiarExpirados();
  }

  estaRevocado(jti: string | null | undefined): boolean {
    if (!jti) {
      return false;
    }

    this.limpiarExpirados();
    const expiracion = this.tokensRevocados.get(jti);
    if (!expiracion) {
      return false;
    }
    if (expiracion <= Date.now()) {
      this.tokensRevocados.delete(jti);
      return false;
    }
    return true;
  }

  private limpiarExpirados(): void {
    const ahora = Date.now();
    for (const [jti, expMs] of this.tokensRevocados.entries()) {
      if (expMs <= ahora) {
        this.tokensRevocados.delete(jti);
      }
    }
  }
}
