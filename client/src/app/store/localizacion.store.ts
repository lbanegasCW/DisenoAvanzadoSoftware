import { Injectable, signal, computed, effect } from '@angular/core';

export interface LocalidadSeleccionada {
  nroLocalidad: number | null;
  nomLocalidad: string | null;
  codProvincia: string | null;
}

const STORAGE_KEY = 'localizacion.seleccion';

@Injectable({ providedIn: 'root' })
export class LocalizacionStore {
  private _nroLocalidad = signal<number | null>(null);
  private _nomLocalidad = signal<string | null>(null);
  private _codProvincia = signal<string | null>(null);

  localidad = computed<LocalidadSeleccionada>(() => ({
    nroLocalidad: this._nroLocalidad(),
    nomLocalidad: this._nomLocalidad(),
    codProvincia: this._codProvincia(),
  }));

  constructor() {
    // Rehidratar
    try {
      const raw = typeof window !== 'undefined' ? localStorage.getItem(STORAGE_KEY) : null;
      if (raw) {
        const v = JSON.parse(raw) as LocalidadSeleccionada;
        this._nroLocalidad.set(v.nroLocalidad ?? null);
        this._nomLocalidad.set(v.nomLocalidad ?? null);
        this._codProvincia.set(v.codProvincia ?? null);
      }
    } catch {}

    // Persistir
    effect(() => {
      try {
        if (typeof window !== 'undefined') {
          localStorage.setItem(STORAGE_KEY, JSON.stringify(this.localidad()));
        }
      } catch {}
    });
  }

  setProvincia(codProvincia: string | null) {
    this._codProvincia.set(codProvincia);
    // Si cambia la provincia, reseteo la localidad
    this._nroLocalidad.set(null);
    this._nomLocalidad.set(null);
  }

  setLocalidad(nroLocalidad: number | null, nomLocalidad: string | null) {
    this._nroLocalidad.set(nroLocalidad);
    this._nomLocalidad.set(nomLocalidad);
  }

  // Opcional: limpiar todo
  clear() {
    this._codProvincia.set(null);
    this._nroLocalidad.set(null);
    this._nomLocalidad.set(null);
  }
}
