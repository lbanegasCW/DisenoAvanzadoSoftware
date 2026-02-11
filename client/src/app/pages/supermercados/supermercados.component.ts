import { Component, OnInit, OnDestroy, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { NotificationComponent } from '../../components/notificacion/notificacion.component';
import { IndecService } from '../../services/indec.service';
import { Subject, takeUntil, catchError, of } from 'rxjs';

// Interfaces (movidas a un archivo separado idealmente)
interface Provincia {
  codProvincia: string;
  nomProvincia: string;
  codPais: string;
  nomPais: string;
}

interface Localidad {
  nroLocalidad: number;
  nomLocalidad: string;
  codProvincia: string;
  nomProvincia: string;
  codPais: string;
  nomPais: string;
}

interface Supermercado {
  nroSupermercado: number;
  razonSocial: string;
  urlServicio: string;
  tipoServicio: string;
  estadoServicio: boolean;
}

interface Sucursal {
  nroSupermercado: number;
  nroSucursal: number;
  nomSucursal: string;
  calle: string;
  nroCalle: string;
  telefonos: string;
  coordLatitud: number;
  coordLongitud: number;
  horarioSucursal: string;
  serviciosDisponibles: string;
  habilitada: boolean;
  razonSocial: string;
  nroLocalidad: number;
  nomLocalidad: string;
  codProvincia: string;
  nomProvincia: string;
}

interface NotificationType {
  show: boolean;
  type: 'success' | 'error' | 'info' | 'warning';
  title: string;
  message: string;
}

@Component({
  selector: 'app-supermercados',
  templateUrl: './supermercados.component.html',
  standalone: true,
  imports: [CommonModule, FormsModule, NotificationComponent],
})
export class SupermercadosComponent implements OnInit, OnDestroy {
  private readonly destroy$ = new Subject<void>();
  private readonly indecService = inject(IndecService);

  // Properties
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

  notification: NotificationType = {
    show: false,
    type: 'info',
    title: '',
    message: '',
  };

  ngOnInit(): void {
    this.loadInitialData();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  private loadInitialData(): void {
    this.isLoading = true;

    // Load provincias
    this.indecService
      .getProvincias()
      .pipe(
        takeUntil(this.destroy$),
        catchError((error) => {
          this.showNotification('error', 'Error', error.message);
          return of([]);
        })
      )
      .subscribe({
        next: (provincias) => {
          this.provincias = provincias;
        },
        complete: () => {
          this.isLoading = false;
        },
      });

    // Load supermercados
    this.indecService
      .getSupermercados()
      .pipe(
        takeUntil(this.destroy$),
        catchError((error) => {
          this.showNotification('error', 'Error', error.message);
          return of([]);
        })
      )
      .subscribe({
        next: (supermercados) => {
          this.supermercados = supermercados;
          this.filteredSupermercados = supermercados;
        },
      });
  }

  onProvinciaChange(): void {
    this.selectedLocalidad = null;
    this.selectedSupermercado = null;
    this.sucursales = [];
    this.localidades = [];

    if (this.selectedProvincia) {
      this.isLoading = true;
      this.indecService
        .getLocalidades(this.selectedProvincia)
        .pipe(
          takeUntil(this.destroy$),
          catchError((error) => {
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
  }

  onLocalidadChange(): void {
    this.selectedSupermercado = null;
    this.sucursales = [];
    this.updateSucursales();
  }

  updateSucursales(): void {
    const params: Record<string, string | number> = {};

    if (this.selectedProvincia) {
      params['provinciaId'] = this.selectedProvincia;
    }

    if (this.selectedLocalidad) {
      params['localidadId'] = this.selectedLocalidad;
    }

    this.isLoading = true;
    this.indecService
      .getSucursales(params)
      .pipe(
        takeUntil(this.destroy$),
        catchError((error) => {
          this.showNotification('error', 'Error', error.message);
          return of([]);
        })
      )
      .subscribe({
        next: (sucursales) => {
          const supermercadosIds = new Set(
            sucursales.map((s) => s.nroSupermercado)
          );
          this.filteredSupermercados = this.supermercados.filter((s) =>
            supermercadosIds.has(s.nroSupermercado)
          );
        },
        complete: () => {
          this.isLoading = false;
        },
      });
  }

  filterSupermercados(): void {
    if (!this.searchTerm.trim()) {
      this.updateSucursales();
      return;
    }

    const searchLower = this.searchTerm.toLowerCase();
    this.filteredSupermercados = this.supermercados.filter((s) =>
      s.razonSocial.toLowerCase().includes(searchLower)
    );
  }

  selectSupermercado(supermercado: Supermercado): void {
    this.selectedSupermercado = supermercado;

    const params: Record<string, string | number> = {
      supermercadoId: supermercado.nroSupermercado,
    };

    if (this.selectedProvincia) {
      params['provinciaId'] = this.selectedProvincia;
    }

    if (this.selectedLocalidad) {
      params['localidadId'] = this.selectedLocalidad;
    }

    this.isLoading = true;
    this.indecService
      .getSucursales(params)
      .pipe(
        takeUntil(this.destroy$),
        catchError((error) => {
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

  private showNotification(
    type: 'success' | 'error' | 'info' | 'warning',
    title: string,
    message: string,
    duration: number = 5000
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
