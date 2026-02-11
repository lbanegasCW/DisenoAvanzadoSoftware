import { CommonModule } from '@angular/common';
import { Component, computed, signal } from '@angular/core';
import { IndecService, Supermercado, ComparadorRow } from '@/app/services/indec.service';
import { CartCodesService } from '@/app/services/cart-codes.service';
import { LocalizacionStore } from '@/app/store/localizacion.store';

@Component({
  selector: 'app-comparador-precios',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './comparador-de-precios.component.html'
})
export class ComparadorPreciosComponent {
  // estado
  loading = signal(false);
  errorMsg = signal<string | null>(null);

  // datos
  rows!: ComparadorRow[];
  supermercados = signal<Supermercado[]>([]);

  // map id -> razonSocial para header
  supName = (id: number) => {
    const s = this.supermercados().find(x => x.nroSupermercado === id);
    return s?.razonSocial ?? `Super ${id}`;
  };

  constructor(
    private indec: IndecService,
    public cart: CartCodesService,
    public locStore: LocalizacionStore
  ) {}

  ngOnInit() {
    this.indec.getSupermercados().subscribe({
      next: ss => this.supermercados.set(ss ?? []),
      error: () => this.supermercados.set([]),
    });
    this.comparar();
  }

  comparar() {
    const loc = this.locStore.localidad();
    const nroLocalidad = loc.nroLocalidad ?? 0;
    const codes = this.cart.codes();

    this.errorMsg.set(null);

    if (!nroLocalidad) {
      this.errorMsg.set($localize`:@@comparador.error_sin_localidad:Seleccioná una localidad desde el navbar.`);
      this.rows = [];
      return;
    }
    if (!codes.length) {
      this.errorMsg.set($localize`:@@comparador.error_carrito_vacio:Tu carrito está vacío. Agregá productos para comparar.`);
      this.rows = [];
      return;
    }

    this.loading.set(true);
    this.indec.compareByLocalidad(nroLocalidad, codes).subscribe({
      next: data => {
        console.log('[comparar] recibido -> filas:', data?.length, data);
        this.rows = data ?? [];
        this.loading.set(false);
      },
      error: (err) => {
        this.errorMsg.set($localize`:@@comparador.error_carga:Error al cargar la comparación.`);
        this.rows = [];
        this.loading.set(false);
      }
    });
  }

  private toNumber(v: any): number | null {
    if (v === null || v === undefined || v === '') return null;
    // normaliza: saca espacios, quita separadores de miles, cambia coma decimal por punto
    let s = String(v).trim().replace(/\s+/g, '');
    // si hay ambas , y . intentá detectar decimal por la última aparición
    const lastComma = s.lastIndexOf(',');
    const lastDot   = s.lastIndexOf('.');
    if (lastComma > -1 && lastDot > -1) {
      // Considerá como separador decimal el que aparece último
      const decimalSep = lastComma > lastDot ? ',' : '.';
      const thousandSep = decimalSep === ',' ? '.' : ',';
      s = s.replace(new RegExp('\\' + thousandSep, 'g'), '').replace(decimalSep, '.');
    } else {
      // Solo hay uno o ninguno: quita puntos de miles y cambia coma por punto
      s = s.replace(/\./g, '').replace(',', '.');
    }
    const n = Number(s);
    return Number.isFinite(n) ? n : null;
  }

  priceFor(r: ComparadorRow, supId: number): number | null {
    const f = r?.ofertas?.find(o => {
      // por si o.nroSupermercado viene como string
      const id = this.toNumber(o.nroSupermercado);
      return id !== null && id === supId;
    });
    return f ? this.toNumber(f.precio) : null;
  }

  minPrice(r: ComparadorRow): number | null {
    const arr = (r?.ofertas ?? [])
      .map(o => this.toNumber(o.precio))
      .filter((n): n is number => n !== null);
    return arr.length ? Math.min(...arr) : null;
  }

  colIds = computed<number[]>(() => {
    const set = new Set<number>();
    for (const r of this.rows) {
      for (const o of (r.ofertas ?? [])) {
        const id = this.toNumber(o.nroSupermercado);
        if (id !== null) set.add(id);
      }
    }
    return Array.from(set).sort((a, b) => a - b);
  });

}
