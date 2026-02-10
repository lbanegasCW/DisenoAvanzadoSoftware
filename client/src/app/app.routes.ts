import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () =>
      import('./pages/inicio/inicio.component').then((m) => m.InicioComponent),
  },
  {
    path: 'supermercados',
    loadComponent: () =>
      import('./pages/supermercados/supermercados.component').then(
        (m) => m.SupermercadosComponent
      ),
  },
  {
    path: 'comparador',
    loadComponent: () =>
      import(
        './pages/comparador-de-precios/comparador-de-precios.component'
      ).then((m) => m.ComparadorPreciosComponent),
  },
  {
    path: 'catalogo',
    loadComponent: () =>
      import('./pages/catalogo/catalogo-productos.component')
        .then(m => m.CatalogoProductosComponent)
  }
];
