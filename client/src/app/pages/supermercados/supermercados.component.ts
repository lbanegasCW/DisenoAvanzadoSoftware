import { Component, OnDestroy, OnInit, effect, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Subject, catchError, of, takeUntil } from 'rxjs';

import { NotificationComponent } from '../../components/notificacion/notificacion.component';
import {
  IndecService,
  Sucursal,
  Supermercado,
} from '../../services/indec.service';
import { LocalizacionStore } from '../../store/localizacion.store';

type NotificationKind = 'success' | 'error' | 'info' | 'warning';

interface NotificationState {
  show: boolean;
  type: NotificationKind;
  title: string;
  message: string;
}

@Component({
  selector: 'app-supermercados',
  templateUrl: './supermercados.component.html',
  styleUrl: './supermercados.component.css',
  standalone: true,
  imports: [CommonModule, FormsModule, NotificationComponent],
})
export class SupermercadosComponent implements OnInit, OnDestroy {
  private readonly destroy$ = new Subject<void>();
  private readonly indecService = inject(IndecService);
  readonly locStore = inject(LocalizacionStore);

  searchTerm = '';

  supermercados: Supermercado[] = [];
  filteredSupermercados: Supermercado[] = [];
  selectedSupermercado: Supermercado | null = null;
  sucursales: Sucursal[] = [];

  isLoading = false;

  notification: NotificationState = {
    show: false,
    type: 'info',
    title: '',
    message: '',
  };

  constructor() {
    effect(() => {
      this.locStore.localidad();
      this.selectedSupermercado = null;
      this.sucursales = [];
      this.updateSucursales();
    });
  }

  ngOnInit(): void {
    this.loadInitialData();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  updateSucursales(): void {
    const { codProvincia, nroLocalidad } = this.locStore.localidad();
    const params: Record<string, string | number> = {};

    if (codProvincia) params['provinciaId'] = codProvincia;
    if (nroLocalidad) params['localidadId'] = nroLocalidad;

    this.isLoading = true;
    this.indecService
      .getSucursales(params)
      .pipe(
        takeUntil(this.destroy$),
        catchError((error: Error) => {
          this.showNotification('error', 'Error', error.message);
          return of([]);
        })
      )
      .subscribe({
        next: (sucursales) => {
          const supermercadosIds = new Set(
            sucursales.map((sucursal) => sucursal.nroSupermercado)
          );
          this.filteredSupermercados = this.supermercados.filter((supermercado) =>
            supermercadosIds.has(supermercado.nroSupermercado)
          );
        },
        complete: () => {
          this.isLoading = false;
        },
      });
  }

  filterSupermercados(): void {
    const query = this.searchTerm.trim().toLowerCase();

    if (!query) {
      this.updateSucursales();
      return;
    }

    this.filteredSupermercados = this.supermercados.filter((supermercado) =>
      supermercado.razonSocial.toLowerCase().includes(query)
    );
  }

  selectSupermercado(supermercado: Supermercado): void {
    this.selectedSupermercado = supermercado;
    const { codProvincia, nroLocalidad } = this.locStore.localidad();

    const params: Record<string, string | number> = {
      supermercadoId: supermercado.nroSupermercado,
    };

    if (codProvincia) params['provinciaId'] = codProvincia;
    if (nroLocalidad) params['localidadId'] = nroLocalidad;

    this.isLoading = true;
    this.indecService
      .getSucursales(params)
      .pipe(
        takeUntil(this.destroy$),
        catchError((error: Error) => {
          this.showNotification('error', 'Error', error.message);
          return of([]);
        })
      )
      .subscribe({
        next: (sucursales) => {
          this.sucursales = sucursales;
        },
        complete: () => {
          this.isLoading = false;
        },
      });
  }

  private loadInitialData(): void {
    this.isLoading = true;

    this.indecService
      .getSupermercados()
      .pipe(
        takeUntil(this.destroy$),
        catchError((error: Error) => {
          this.showNotification('error', 'Error', error.message);
          return of([]);
        })
      )
      .subscribe({
        next: (supermercados) => {
          this.supermercados = supermercados;
          this.filteredSupermercados = supermercados;
          this.updateSucursales();
        },
        complete: () => {
          this.isLoading = false;
        },
      });
  }

  private showNotification(
    type: NotificationKind,
    title: string,
    message: string,
    duration = 5000
  ): void {
    this.notification = {
      show: true,
      type,
      title,
      message,
    };

    setTimeout(() => {
      this.notification.show = false;
    }, duration);
  }
}
