/**
 * @archivo   ErrorLimite.tsx
 * @descripcion Implementa un error boundary para capturar errores no controlados en renderizado.
 * @modulo    ComponentesComunes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import React from 'react';
import { AlertTriangle } from 'lucide-react';
import { Boton } from '@/Componentes/Ui/Boton';

interface PropiedadesErrorLimite {
  children: React.ReactNode;
}

interface EstadoErrorLimite {
  tieneError: boolean;
}

/**
 * Captura errores de render y muestra fallback amigable.
 */
export class ErrorLimite extends React.Component<PropiedadesErrorLimite, EstadoErrorLimite> {
  constructor(props: PropiedadesErrorLimite) {
    super(props);
    this.state = { tieneError: false };
  }

  /**
   * Marca el estado de error tras una excepción de render.
   * @returns Estado actualizado del boundary.
   */
  static getDerivedStateFromError(): EstadoErrorLimite {
    return { tieneError: true };
  }

  /**
   * Restaura el estado normal del boundary.
   */
  reiniciar = () => {
    this.setState({ tieneError: false });
  };

  render() {
    if (!this.state.tieneError) {
      return this.props.children;
    }

    return (
      <div className="m-6 rounded-lg border border-borde bg-white p-10 text-center">
        <AlertTriangle className="mx-auto h-10 w-10 text-peligro" />
        <h2 className="mt-3 text-lg font-semibold">Ocurrió un error inesperado</h2>
        <p className="mt-1 texto-muted">Recarga la vista para continuar trabajando.</p>
        <Boton className="mt-5" onClick={this.reiniciar}>
          Reintentar
        </Boton>
      </div>
    );
  }
}
