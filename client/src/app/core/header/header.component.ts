import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

import { IndecService, Localidad, Provincia } from '../../services/indec.service';
import { LocalizacionStore } from '../../store/localizacion.store';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './header.component.html',
  styleUrl: './header.component.css',
})
export class HeaderComponent implements OnInit {
  private readonly indec = inject(IndecService);
  readonly locStore = inject(LocalizacionStore);

  provincias: Provincia[] = [];
  localidades: Localidad[] = [];

  codProvinciaSel: string | null = null;
  nroLocalidadSel: number | null = null;

  ngOnInit(): void {
    this.indec.getProvincias().subscribe({
      next: (provincias) => {
        this.provincias = provincias;
        this.rehydrateLocation();
      },
      error: console.error,
    });
  }

  onProvinciaChange(codProvincia: string | null): void {
    this.codProvinciaSel = codProvincia;
    this.locStore.setProvincia(codProvincia);

    this.nroLocalidadSel = null;
    this.localidades = [];

    if (!codProvincia) return;

    this.indec.getLocalidades(codProvincia).subscribe({
      next: (localidades) => {
        this.localidades = localidades;
      },
      error: console.error,
    });
  }

  onLocalidadChange(localidadId: string | number | null): void {
    const id = localidadId === null || localidadId === '' ? null : Number(localidadId);
    this.nroLocalidadSel = id;

    const nombre = id
      ? this.localidades.find((localidad) => localidad.nroLocalidad === id)?.nomLocalidad ?? null
      : null;

    this.locStore.setLocalidad(id, nombre);
  }

  private rehydrateLocation(): void {
    const previous = this.locStore.localidad();

    if (!previous.codProvincia) return;

    this.codProvinciaSel = previous.codProvincia;

    this.indec.getLocalidades(previous.codProvincia).subscribe({
      next: (localidades) => {
        this.localidades = localidades;

        const localityExists =
          previous.nroLocalidad &&
          localidades.some((localidad) => localidad.nroLocalidad === previous.nroLocalidad);

        if (localityExists) {
          this.nroLocalidadSel = previous.nroLocalidad;
          return;
        }

        this.nroLocalidadSel = null;
        this.locStore.setLocalidad(null, null);
      },
      error: console.error,
    });
  }
}
