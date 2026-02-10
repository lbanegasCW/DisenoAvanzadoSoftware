import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { IndecService, Supermercado, ComparadorRow } from '@/app/services/indec.service';
import { CartCodesService } from '@/app/services/cart-codes.service';
import { LocalizacionStore } from '@/app/store/localizacion.store';

type VmRow = ComparadorRow & {
  pricesBySup: Record<string, any>; // raw
};

@Component({
  selector: 'app-comparador-precios',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './comparador-de-precios.component.html'
})
export class ComparadorPreciosComponent {
  loading = false;
  errorMsg: string | null = null;

  supermercados: Supermercado[] = [];

  colIds: number[] = [];
  vmRows: VmRow[] = [];

  supName = (id: number) => {
    const s = this.supermercados.find(x => x.nroSupermercado === id);
    return s?.razonSocial ?? `Super ${id}`;
  };

  constructor(
    private indec: IndecService,
    public cart: CartCodesService,
    public locStore: LocalizacionStore
  ) {}

  ngOnInit() {
    this.indec.getSupermercados().subscribe({
      next: ss => (this.supermercados = ss ?? []),
      error: () => (this.supermercados = []),
    });

    this.comparar();
  }

  comparar() {
    const loc = this.locStore.localidad();
    const nroLocalidad = loc?.nroLocalidad ?? 0;
    const codes = this.cart.codes();

    this.errorMsg = null;

    if (!nroLocalidad) {
      this.errorMsg = 'Seleccioná una localidad desde el navbar.';
      this.vmRows = [];
      this.colIds = [];
      return;
    }
    if (!codes.length) {
      this.errorMsg = 'Tu carrito está vacío. Agregá productos para comparar.';
      this.vmRows = [];
      this.colIds = [];
      return;
    }

    this.loading = true;

    this.indec.compareByLocalidad(nroLocalidad, codes).subscribe({
      next: data => {
        const rows = data ?? [];

        // columnas desde lo que viene
        this.colIds = this.buildColIds(rows);

        // armamos mapa raw por super
        this.vmRows = rows.map(r => {
          const pricesBySup: Record<string, any> = {};

          for (const id of this.colIds) pricesBySup[String(id)] = null;

          for (const o of (r.ofertas ?? [])) {
            pricesBySup[String(o.nroSupermercado)] = o.precio; // ✅ RAW TAL CUAL
          }

          return { ...r, pricesBySup };
        });

        console.log('[DEBUG] colIds:', this.colIds);
        console.log('[DEBUG] vmRows[0]:', this.vmRows[0]);

        this.loading = false;
      },
      error: err => {
        this.errorMsg = err?.message || 'Error al cargar la comparación.';
        this.vmRows = [];
        this.colIds = [];
        this.loading = false;
      }
    });
  }

  private buildColIds(rows: ComparadorRow[]): number[] {
    const set = new Set<number>();
    for (const r of rows) {
      for (const o of (r.ofertas ?? [])) set.add(Number(o.nroSupermercado));
    }
    return Array.from(set).filter(Number.isFinite).sort((a, b) => a - b);
  }

  trackCol = (_: number, id: number) => id;
  trackRow = (_: number, r: VmRow) => r.codBarra;
}
