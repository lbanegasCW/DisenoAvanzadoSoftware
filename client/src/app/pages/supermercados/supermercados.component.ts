import { Component, OnDestroy, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Subject, catchError, of, takeUntil } from 'rxjs';

import { NotificationComponent } from '../../components/notificacion/notificacion.component';
import {
  IndecService,
  Localidad,
  Provincia,
  Sucursal,
  Supermercado,
} from '../../services/indec.service';

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

  selectedProvincia = '';
  selectedLocalidad: number | null = null;
  searchTerm = '';

  provincias: Provincia[] = [];
  localidades: Localidad[] = [];
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

  ngOnInit(): void {
    this.loadInitialData();
    this.updateSucursales();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  onProvinciaChange(): void {
    this.selectedLocalidad = null;
    this.selectedSupermercado = null;
    this.sucursales = [];
    this.localidades = [];

    if (!this.selectedProvincia) {
      this.updateSucursales();
      return;
    }

    this.isLoading = true;
    this.indecService
      .getLocalidades(this.selectedProvincia)
      .pipe(
        takeUntil(this.destroy$),
        catchError((error: Error) => {
          this.showNotification('error', 'Error', error.message);
          return of([]);
        })
      )
      .subscribe({
        next: (localidades) => {
          this.localidades = localidades;
        },
        complete: () => {
          this.isLoading = false;
        },
      });

    this.updateSucursales();
  }

  onLocalidadChange(): void {
    this.selectedSupermercado = null;
    this.sucursales = [];
    this.updateSucursales();
  }

  updateSucursales(): void {
    const params: Record<string, string | number> = {};

    if (this.selectedProvincia) params['provinciaId'] = this.selectedProvincia;
    if (this.selectedLocalidad) params['localidadId'] = this.selectedLocalidad;

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

    const params: Record<string, string | number> = {
      supermercadoId: supermercado.nroSupermercado,
    };

    if (this.selectedProvincia) params['provinciaId'] = this.selectedProvincia;
    if (this.selectedLocalidad) params['localidadId'] = this.selectedLocalidad;

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
      .getProvincias()
      .pipe(
        takeUntil(this.destroy$),
        catchError((error: Error) => {
          this.showNotification('error', 'Error', error.message);
          return of([]);
        })
      )
      .subscribe({
        next: (provincias) => {
          this.provincias = provincias;
        },
      });

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
