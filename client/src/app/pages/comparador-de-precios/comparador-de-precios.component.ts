import { CommonModule } from '@angular/common';
import { Component, OnInit, effect, inject } from '@angular/core';
import {
  ComparadorOferta,
  ComparadorRow,
  IndecService,
  Supermercado,
} from '@/app/services/indec.service';
import { CartCodesService } from '@/app/services/cart-codes.service';
import { LocalizacionStore } from '@/app/store/localizacion.store';

type SupermarketId = number;

interface PriceCell {
  value: number;
  promotionName: string | null;
  promotionPrice: number | null;
  promotionEndDate: string | null;
}

interface VmRow extends ComparadorRow {
  pricesBySup: Record<SupermarketId, PriceCell | null>;
  min: number | null;
}

@Component({
  selector: 'app-comparador-precios',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './comparador-de-precios.component.html',
  styleUrl: './comparador-de-precios.component.css',
})
export class ComparadorPreciosComponent implements OnInit {
  private readonly indec = inject(IndecService);

  readonly cart = inject(CartCodesService);
  readonly locStore = inject(LocalizacionStore);

  loading = false;
  errorMsg: string | null = null;

  supermercados: Supermercado[] = [];
  colIds: SupermarketId[] = [];
  vmRows: VmRow[] = [];

  // ✅ fijo: siempre number
  totalBySup: Record<SupermarketId, number> = {};
  isCompleteBySup: Record<SupermarketId, boolean> = {};
  cheapestSupId: SupermarketId | null = null;

  constructor() {
    effect(() => {
      this.locStore.localidad();
      this.cart.codes();
      this.comparar();
    });
  }

  ngOnInit(): void {
    this.loadSupermarkets();
  }

  comparar(): void {
    const { nroLocalidad = 0 } = this.locStore.localidad() ?? {};
    const codes = this.cart.codes();

    this.errorMsg = null;

    if (!nroLocalidad) {
      this.errorMsg = 'Seleccioná una localidad desde el navbar.';
      this.resetTable();
      return;
    }

    if (!codes.length) {
      this.errorMsg = 'Tu carrito está vacío. Agregá productos para comparar.';
      this.resetTable();
      return;
    }

    this.loading = true;

    this.indec.compareByLocalidad(nroLocalidad, codes).subscribe({
      next: (rows) => this.buildTable(rows ?? []),
      error: (error) => {
        this.errorMsg = error?.message || 'Error al cargar la comparación.';
        this.resetTable();
      },
      complete: () => {
        this.loading = false;
      },
    });
  }

  supName(id: SupermarketId): string {
    return (
      this.supermercados.find((market) => market.nroSupermercado === id)
        ?.razonSocial ?? `Super ${id}`
    );
  }

  trackCol = (_: number, id: SupermarketId): SupermarketId => id;
  trackRow = (_: number, row: VmRow): string => row.codBarra;

  getPrice(row: VmRow, supermarketId: SupermarketId): PriceCell | null {
    return row.pricesBySup[supermarketId] ?? null;
  }

  formatPrice(value: number): string {
    return new Intl.NumberFormat('es-AR', {
      style: 'currency',
      currency: 'ARS',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(value);
  }

  private loadSupermarkets(): void {
    this.indec.getSupermercados().subscribe({
      next: (supermarkets) => {
        this.supermercados = supermarkets ?? [];
      },
      error: () => {
        this.supermercados = [];
      },
    });
  }

  private buildTable(rows: ComparadorRow[]): void {
    this.colIds = this.buildColIds(rows);

    this.vmRows = rows.map((row) => {
      const pricesBySup = this.buildPriceMap(row);
      return {
        ...row,
        pricesBySup,
        min: this.minPrice(pricesBySup),
      };
    });

    this.computeTotals();
  }

  private buildColIds(rows: ComparadorRow[]): SupermarketId[] {
    const ids = new Set<SupermarketId>();

    for (const row of rows) {
      for (const offer of row.ofertas ?? []) {
        const id = Number(offer.nroSupermercado);
        if (Number.isFinite(id)) ids.add(id);
      }
    }

    return [...ids].sort((a, b) => a - b);
  }

  private buildPriceMap(row: ComparadorRow): Record<SupermarketId, PriceCell | null> {
    const pricesBySup = Object.fromEntries(
      this.colIds.map((id) => [id, null])
    ) as Record<SupermarketId, PriceCell | null>;

    for (const offer of row.ofertas ?? []) {
      const id = Number(offer.nroSupermercado);
      if (Number.isFinite(id)) {
        pricesBySup[id] = this.toPriceCell(offer);
      }
    }

    return pricesBySup;
  }

  private minPrice(
    pricesBySup: Record<SupermarketId, PriceCell | null>
  ): number | null {
    const numericPrices = Object.values(pricesBySup).filter(
      (value): value is PriceCell => value !== null
    ).map((value) => value.value);

    return numericPrices.length ? Math.min(...numericPrices) : null;
  }

  private toPriceCell(offer: ComparadorOferta): PriceCell {
    return {
      value: offer.precio,
      promotionName: offer.tipoPromocion ?? null,
      promotionPrice: offer.precioPromocion ?? null,
      promotionEndDate: offer.finVigencia ?? null,
    };
  }

  private hasNumericPrice(price: PriceCell | null): price is PriceCell {
    return !!price && Number.isFinite(price.value);
  }

  isMinPrice(row: VmRow, supermarketId: SupermarketId): boolean {
    const price = row.pricesBySup[supermarketId];
    return !!price && row.min !== null && price.value === row.min;
  }

  showPromotionDetails(price: PriceCell | null): boolean {
    if (!price) return false;

    const hasPromotionName = !!price.promotionName?.trim();
    const hasPromotionPrice = Number.isFinite(price.promotionPrice);

    return hasPromotionName || hasPromotionPrice;
  }

  promotionLabel(price: PriceCell | null): string {
    const promotionType = price?.promotionName?.trim();
    return promotionType ? `Promoción: ${promotionType}` : '';
  }

  promotionTooltip(price: PriceCell | null): string {
    if (!price) return '';

    return `Válida hasta ${this.formatPromotionEndDate(price.promotionEndDate)}`;
  }

  private formatPromotionEndDate(value: string | null): string {
    if (!value) return 'fecha no informada';

    const parsedDate = new Date(value);
    if (!Number.isNaN(parsedDate.getTime())) {
      return new Intl.DateTimeFormat('es-AR').format(parsedDate);
    }

    return value;
  }

  private computeTotals(): void {
    // ✅ inicialización fuerte: todos los ids tienen total = 0 y complete = true
    this.totalBySup = Object.fromEntries(
      this.colIds.map((id) => [id, 0])
    ) as Record<SupermarketId, number>;

    this.isCompleteBySup = Object.fromEntries(
      this.colIds.map((id) => [id, true])
    ) as Record<SupermarketId, boolean>;

    for (const row of this.vmRows) {
      for (const id of this.colIds) {
        const price = row.pricesBySup[id];

        if (this.hasNumericPrice(price)) {
          this.totalBySup[id] = this.totalBySup[id] + price.value;
        } else {
          this.isCompleteBySup[id] = false;
        }
      }
    }

    this.cheapestSupId = this.colIds.reduce<SupermarketId | null>(
      (winnerId, id) => {
        if (!this.isCompleteBySup[id]) return winnerId;
        if (winnerId === null) return id;

        return this.totalBySup[id] < this.totalBySup[winnerId]
          ? id
          : winnerId;
      },
      null
    );
  }

  private resetTable(): void {
    this.vmRows = [];
    this.colIds = [];
    this.totalBySup = {};
    this.isCompleteBySup = {};
    this.cheapestSupId = null;
    this.loading = false;
  }
}
