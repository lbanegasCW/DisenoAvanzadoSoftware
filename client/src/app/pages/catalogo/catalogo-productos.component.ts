import { Component, HostListener, computed, effect, inject, signal, untracked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

import { IndecService, Producto } from '@/app/services/indec.service';
import { CartCodesService } from '@/app/services/cart-codes.service';
import { LocalizacionStore } from '@/app/store/localizacion.store';

type FacetId = number | null;

interface Facet {
  id: number;
  nombre: string;
  count: number;
}

@Component({
  standalone: true,
  selector: 'app-catalogo-productos',
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './catalogo-productos.component.html',
  styleUrl: './catalogo-productos.component.css',
})
export class CatalogoProductosComponent {
  private readonly indec = inject(IndecService);
  readonly cart = inject(CartCodesService);
  readonly locStore = inject(LocalizacionStore);

  readonly all = signal<Producto[]>([]);
  readonly loading = signal(false);
  readonly errorMsg = signal<string | null>(null);

  readonly texto = signal('');
  readonly rubroSel = signal<FacetId>(null);
  readonly categoriaSel = signal<FacetId>(null);

  readonly cartOpen = signal(false);

  readonly rubros = computed(() => this.buildFacet(this.all(), 'nroRubro', 'nomRubro'));

  readonly categorias = computed(() => {
    const rubroSeleccionado = this.rubroSel();
    const products = rubroSeleccionado
      ? this.all().filter((producto) => producto.nroRubro === rubroSeleccionado)
      : this.all();

    return this.buildFacet(products, 'nroCategoria', 'nomCategoria');
  });

  readonly productos = computed<Producto[]>(() => {
    const query = this.texto().trim().toLowerCase();
    const rubro = this.rubroSel();
    const categoria = this.categoriaSel();

    return this.all()
      .filter((producto) => {
        if (rubro && producto.nroRubro !== rubro) return false;
        if (categoria && producto.nroCategoria !== categoria) return false;

        if (!query) return true;

        return [
          producto.nomProducto,
          producto.nomMarca,
          producto.nomCategoria,
          producto.nomRubro,
          producto.codBarra,
        ]
          .filter(Boolean)
          .some((value) => value!.toLowerCase().includes(query));
      })
      .sort((a, b) => a.nomProducto.localeCompare(b.nomProducto, 'es'));
  });

  readonly seleccionados = computed<Producto[]>(() => {
    const codes = new Set(this.cart.codes());
    if (!codes.size) return [];

    const index = new Map(this.all().map((producto) => [producto.codBarra, producto] as const));
    return [...codes]
      .map((code) => index.get(code))
      .filter((producto): producto is Producto => Boolean(producto));
  });

  constructor() {
    effect(() => {
      const loc = this.locStore.localidad();
      untracked(() => this.loadProductos(loc));
    });
  }

  get totalResultados(): number {
    return this.productos().length;
  }

  openCart(): void {
    this.cartOpen.set(true);
  }

  closeCart(): void {
    this.cartOpen.set(false);
  }

  toggleCart(): void {
    this.cartOpen.update((isOpen) => !isOpen);
  }

  limpiarRubro(): void {
    this.rubroSel.set(null);
    this.categoriaSel.set(null);
  }

  setRubro(id: number): void {
    this.rubroSel.set(id);
    this.categoriaSel.set(null);
  }

  setCategoria(id: number): void {
    this.categoriaSel.set(id);
  }

  limpiarCategoria(): void {
    this.categoriaSel.set(null);
  }

  onToggleCartFor(code: string): void {
    const alreadyAdded = this.cart.has(code);
    this.cart.toggle(code);

    if (!alreadyAdded) {
      this.openCart();
    }
  }

  track = (_: number, producto: Producto): string => producto.codBarra;

  @HostListener('window:keydown.escape')
  onEsc(): void {
    this.closeCart();
  }

  private loadProductos(loc: { codProvincia?: any; nroLocalidad?: any }): void {
    this.loading.set(true);

    const { codProvincia, nroLocalidad } = loc;
    const filters: Record<string, string | number> = {};

    if (codProvincia) filters['provinciaId'] = codProvincia;
    if (nroLocalidad) filters['localidadId'] = nroLocalidad;

    this.indec.getProductosCatalogo(filters).subscribe({
      next: (rows) => {
        this.all.set(rows);
        this.errorMsg.set(null); // opcional: limpiar error al éxito
      },
      error: (error) => {
        console.error('[Catálogo] error', error);
        this.errorMsg.set($localize`:@@catalogo.error_carga:No pudimos cargar el catálogo.`);
      },
      complete: () => {
        this.loading.set(false);
      },
    });
  }

  private buildFacet<TId extends keyof Producto, TName extends keyof Producto>(
    products: Producto[],
    idKey: TId,
    nameKey: TName
  ): Facet[] {
    const map = new Map<number, Facet>();

    for (const producto of products) {
      const id = producto[idKey];
      const nombre = producto[nameKey];

      if (typeof id !== 'number' || typeof nombre !== 'string') continue;

      if (!map.has(id)) {
        map.set(id, { id, nombre, count: 0 });
      }

      map.get(id)!.count += 1;
    }

    return [...map.values()].sort((a, b) => a.nombre.localeCompare(b.nombre, 'es'));
  }
}
