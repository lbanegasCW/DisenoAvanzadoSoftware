# API INDEC (REST)

API principal del sistema. Consolida información geográfica y de supermercados, y expone endpoints para consulta de sucursales y productos normalizados.

## Base URL

`http://localhost:8080/api/v1`

## Endpoints principales

### Países, provincias y localidades

- `GET /provincias`
- `GET /provincias/{cod_provincia}/localidades?codPais={cod_pais}`

### Supermercados y sucursales

- `GET /supermercados`
- `GET /sucursales`
  - Filtros opcionales: `supermercadoId`, `localidadId`, `provinciaId`, `paisId`
- `GET /productos`
  - Filtros opcionales: `lang`
- `POST /productosPrecios`

### Sincronización con APIs de supermercados

- Se debe ejecutar batch Consumidor.java

Actualiza estado de servicios y refresca datos de sucursales/productos desde Super1, Super2, Super3 y Super4.

## Notas

- Context path configurado: `/api/v1`.
- Base de datos por defecto: SQL Server (`indec`).
- El proyecto se integra con servicios SOAP y REST de supermercados externos.
