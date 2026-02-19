# API Super2 (REST)

Servicio REST del supermercado 2.

## Base URL

`http://localhost:8082/api/v1`

## Autenticación

Basic Auth:

- Usuario: `changoMas`
- Password: `c1h2s4f`

## Endpoints

- `GET /supermercado/sucursales`
- `GET /supermercado/productos`

## Llamadas de prueba

```bash
curl -u changoMas:c1h2s4f http://localhost:8082/api/v1/supermercado/sucursales
curl -u changoMas:c1h2s4f http://localhost:8082/api/v1/supermercado/productos
```
