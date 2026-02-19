# API Super4 (REST)

Servicio REST del supermercado 4.

## Base URL

`http://localhost:8084/api/v1`

## Autenticación

Basic Auth:

- Usuario: `disco`
- Password: `n0h2e9f`

## Endpoints

- `GET /supermercado/sucursales`
- `GET /supermercado/productos`

## Llamadas de prueba

```bash
curl -u disco:n0h2e9f http://localhost:8084/api/v1/supermercado/sucursales
curl -u disco:n0h2e9f http://localhost:8084/api/v1/supermercado/productos
```
