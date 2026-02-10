import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { IndecService } from '../../services/indec.service';
import { LocalizacionStore } from '../../store/localizacion.store';

interface Provincia { codProvincia: string; nomProvincia: string; codPais: string; }
interface Localidad { nroLocalidad: number; nomLocalidad: string; codProvincia: string; codPais: string; }

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './header.component.html',
  styleUrl: './header.component.css',
})
export class HeaderComponent implements OnInit {
  private indec = inject(IndecService);
  public  locStore = inject(LocalizacionStore); // público para mostrar selección en el navbar (opcional)

  provincias: Provincia[] = [];
  localidades: Localidad[] = [];

  codProvinciaSel: string | null = null;
  nroLocalidadSel: number | null = null;

  ngOnInit(): void {
    // 1) Cargar provincias
    this.indec.getProvincias().subscribe({
      next: (prov: Provincia[]) => {
        this.provincias = prov;

        // 2) Rehidratar selección previa en los combos
        const prev = this.locStore.localidad();

        if (prev.codProvincia) {
          this.codProvinciaSel = prev.codProvincia;

          // 3) Si ya hay provincia guardada, cargar sus localidades
          this.indec.getLocalidades(prev.codProvincia).subscribe({
            next: (locs: Localidad[]) => {
              this.localidades = locs;

              // 4) Si la localidad guardada existe en la lista, preseleccionarla
              if (prev.nroLocalidad && locs.some(l => l.nroLocalidad === prev.nroLocalidad)) {
                this.nroLocalidadSel = prev.nroLocalidad;
              } else {
                // si no existe, limpiar localidad guardada
                this.nroLocalidadSel = null;
                this.locStore.setLocalidad(null, null);
              }
            },
            error: console.error,
          });
        }
      },
      error: console.error,
    });
  }

  // Usuario cambia provincia en el combo
  onProvinciaChange(cod: string | null) {
    this.codProvinciaSel = cod;
    this.locStore.setProvincia(cod);

    this.nroLocalidadSel = null;
    this.localidades = [];

    if (!cod) return;

    this.indec.getLocalidades(cod).subscribe({
      next: (locs: Localidad[]) => { this.localidades = locs; },
      error: console.error,
    });
  }

  // Usuario cambia localidad en el combo
  onLocalidadChange(nro: string | number | null) {
    const id = nro === null || nro === '' ? null : Number(nro);
    this.nroLocalidadSel = id;
    const nombre = id ? (this.localidades.find(l => l.nroLocalidad === id)?.nomLocalidad ?? null) : null;
    this.locStore.setLocalidad(id, nombre);
  }
}
