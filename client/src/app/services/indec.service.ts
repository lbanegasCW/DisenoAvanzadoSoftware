import { Injectable } from '@angular/core';
import {HttpClient, HttpErrorResponse, HttpParams} from '@angular/common/http';
import {Observable, catchError, throwError, map} from 'rxjs';

const environment = {
  production: false,
  apiUrl: 'http://localhost:8080',
  defaultLanguage: 'es',
  supportedLanguages: ['es', 'en'],
};

export interface Provincia {
  codProvincia: string;
  nomProvincia: string;
  codPais: string;
  nomPais: string;
}

export interface Localidad {
  nroLocalidad: number;
  nomLocalidad: string;
  codProvincia: string;
  nomProvincia: string;
  codPais: string;
  nomPais: string;
}

export interface Supermercado {
  nroSupermercado: number;
  razonSocial: string;
  urlServicio: string;
  tipoServicio: string;
  estadoServicio: boolean;
}

export interface Sucursal {
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

export interface ComparadorOferta {
  nroSupermercado: number;
  precio: number;
}
export interface ComparadorRow {
  codBarra: string;
  nomProducto: string;
  nomCategoria: string;
  fechaUltActualizacion: string;
  ofertas: ComparadorOferta[];
}

export interface Producto {
  codBarra: string;
  nomProducto: string;
  descProducto: string | null;
  imagen?: string | null;
  nomMarca: string | null;
  nroCategoria: number;
  nomCategoria: string;
  nroRubro: number;
  nomRubro: string;
  nomTipoProducto?: string | null;
}

@Injectable({
  providedIn: 'root',
})
export class IndecService {
  private readonly API_URL = environment.apiUrl + '/api/v1';

  constructor(private http: HttpClient) {}

  getProvincias(): Observable<Provincia[]> {
    return this.http
      .get<Provincia[]>(`${this.API_URL}/provincias?codPais=ARG`)
      .pipe(catchError(this.handleError));
  }

  getLocalidades(codProvincia: string): Observable<Localidad[]> {
    return this.http
      .get<Localidad[]>(
        `${this.API_URL}/provincias/${codProvincia}/localidades?codPais=ARG`
      )
      .pipe(catchError(this.handleError));
  }

  getSupermercados(): Observable<Supermercado[]> {
    return this.http
      .get<Supermercado[]>(`${this.API_URL}/supermercados`)
      .pipe(catchError(this.handleError));
  }

  getSucursales(
    params: Record<string, string | number>
  ): Observable<Sucursal[]> {
    return this.http
      .get<Sucursal[]>(`${this.API_URL}/sucursales`, { params })
      .pipe(catchError(this.handleError));
  }

  getProductosCatalogo(params?: Record<string, string | number>) {
    let httpParams = new HttpParams().set('lang', this.getCurrentLanguage());

    for (const [key, value] of Object.entries(params ?? {})) {
      httpParams = httpParams.set(key, String(value));
    }

    return this.http
      .get<Producto[]>(`${this.API_URL}/productos`, { params: httpParams })
      .pipe(catchError(this.handleError));
  }

  private parseOfertas(json: string | null | undefined): ComparadorOferta[] {
    try {
      if (!json) return [];
      const arr = JSON.parse(json);
      if (!Array.isArray(arr)) return [];
      return arr.map((o: any) => ({
        nroSupermercado: Number(o.nroSupermercado),
        precio: Number(o.precio),
      }));
    } catch {
      return [];
    }
  }

  // IndecService
  compareByLocalidad(nroLocalidad: number, codigos: string[]): Observable<ComparadorRow[]> {
    const body = { nroLocalidad, codigos, lang: this.getCurrentLanguage() };

    return this.http.post<any[]>(
      `${this.API_URL}/productosPrecios`,
      body
    ).pipe(
      map(rows => (rows ?? []).map(r => ({
        codBarra: r.codBarra,
        nomProducto: r.nomProducto,
        nomCategoria: r.nomCategoria,
        fechaUltActualizacion: r.fechaUltActualizacion,
        ofertas: this.parseOfertas(r.preciosPorSupermercado),
      } as ComparadorRow))),
      catchError(this.handleError)
    );
  }

  private getCurrentLanguage(): string {
    const language = (document?.documentElement?.lang || environment.defaultLanguage)
      .toLowerCase()
      .trim();

    if (language.startsWith('en')) return 'en';
    return 'es';
  }

  private handleError(error: HttpErrorResponse) {
    let errorMessage = 'Ha ocurrido un error en la aplicación';

    if (error.error instanceof ErrorEvent) {
      errorMessage = `Error: ${error.error.message}`;
    } else {
      errorMessage = `Error ${error.status}: ${
        error.error?.message || 'Error del servidor'
      }`;
    }

    return throwError(() => new Error(errorMessage));
  }

}
