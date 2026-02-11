// src/app/pages/catalogo/catalogo-productos.component.ts
import { Component, computed, inject, signal, HostListener } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IndecService, Producto } from '@/app/services/indec.service';
import { CartCodesService } from '@/app/services/cart-codes.service';
import {RouterModule} from '@angular/router';

type FacetId = number | null;

@Component({
  standalone: true,
  selector: 'app-catalogo-productos',
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './catalogo-productos.component.html',
})
export class CatalogoProductosComponent {
  private indec = inject(IndecService);
  cart = inject(CartCodesService);

  // data
  all = signal<Producto[]>([]);
  loading = signal(false);
  errorMsg = signal<string | null>(null);

  // filtros
  texto = signal('');
  rubroSel = signal<FacetId>(null);
  categoriaSel = signal<FacetId>(null);

  // drawer carrito
  cartOpen = signal(false);
  openCart()  { this.cartOpen.set(true); }
  closeCart() { this.cartOpen.set(false); }
  toggleCart(){ this.cartOpen.set(!this.cartOpen()); }
  @HostListener('window:keydown.escape') onEsc() { this.closeCart(); }

  constructor() {
    this.loading.set(true);
    this.indec.getProductosCatalogo().subscribe({
      next: rows => { this.all.set(rows); this.loading.set(false); },
      error: err => {
        console.error('[Catálogo] error', err);
        this.errorMsg.set($localize`:@@catalogo.error_carga:No pudimos cargar el catálogo.`);
        this.loading.set(false);
      }
    });
  }

  // Facetas: rubros
  rubros = computed(() => {
    const map = new Map<number, { id: number; nombre: string; count: number }>();
    for (const p of this.all()) {
      const id = p.nroRubro;
      if (!map.has(id)) map.set(id, { id, nombre: p.nomRubro, count: 0 });
      map.get(id)!.count++;
    }
    return [...map.values()].sort((a, b) => a.nombre.localeCompare(b.nombre, 'es'));
  });

  // Facetas: categorías (dependen del rubro seleccionado si existe)
  categorias = computed(() => {
    const map = new Map<number, { id: number; nombre: string; count: number }>();
    for (const p of this.all()) {
      if (this.rubroSel() && p.nroRubro !== this.rubroSel()) continue;
      const id = p.nroCategoria;
      if (!map.has(id)) map.set(id, { id, nombre: p.nomCategoria, count: 0 });
      map.get(id)!.count++;
    }
    return [...map.values()].sort((a, b) => a.nombre.localeCompare(b.nombre, 'es'));
  });

  // Acciones filtros
  limpiarRubro()     { this.rubroSel.set(null); this.categoriaSel.set(null); }
  setRubro(id: number) { this.rubroSel.set(id); this.categoriaSel.set(null); }
  setCategoria(id: number) { this.categoriaSel.set(id); }
  limpiarCategoria() { this.categoriaSel.set(null); }

  // Lista filtrada final
  productos = computed<Producto[]>(() => {
    const t = this.texto().trim().toLowerCase();
    return this.all().filter(p => {
      if (this.rubroSel() && p.nroRubro !== this.rubroSel()) return false;
      if (this.categoriaSel() && p.nroCategoria !== this.categoriaSel()) return false;
      if (t) {
        const hay = (p.nomProducto ?? '').toLowerCase().includes(t)
          || (p.nomMarca ?? '').toLowerCase().includes(t)
          || (p.nomCategoria ?? '').toLowerCase().includes(t)
          || (p.nomRubro ?? '').toLowerCase().includes(t)
          || (p.codBarra ?? '').toLowerCase().includes(t);
        if (!hay) return false;
      }
      return true;
    }).sort((a, b) => a.nomProducto.localeCompare(b.nomProducto, 'es'));
  });

  // Getter para ICU plural en template
  get totalResultados(): number { return this.productos().length; }

  // Productos en carrito (para el drawer)
  seleccionados = computed<Producto[]>(() => {
    const codes = new Set(this.cart.codes());
    if (!codes.size) return [];
    const index = new Map(this.all().map(p => [p.codBarra, p] as const));
    return [...codes].map(c => index.get(c)).filter((p): p is Producto => !!p);
  });

  // Al hacer toggle, si agrego uno nuevo, abro el drawer
  onToggleCartFor(code: string) {
    const yaEstaba = this.cart.has(code);
    this.cart.toggle(code);
    if (!yaEstaba) this.openCart();
  }

  track = (_: number, p: Producto) => p.codBarra;
}
