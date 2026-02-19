# ComparadorDePrecios

Monorepo del proyecto **Comparador de Precios**. Incluye:

- `api-indec`: API principal (REST) que consolida países, provincias, localidades, supermercados, sucursales y productos.
- `api-super1` y `api-super3`: servicios SOAP de supermercados.
- `api-super2` y `api-super4`: servicios REST de supermercados.
- `client`: frontend Angular (ES/EN).
- `db`: base SQL Server y scripts de inicialización.
- `docker/dev`: entorno de desarrollo con Docker Compose.

## Requisitos

- Docker
- Docker Compose

> El resto de dependencias (Java 17, Maven, Node.js, SQL Server) se ejecutan dentro de contenedores.

## Levantar el entorno local

Desde la raíz del repo:

```bash
docker compose -f docker/dev/docker-compose.yml up -d --build
```

Para bajar el entorno:

```bash
docker compose -f docker/dev/docker-compose.yml down
```

## Servicios y puertos

- API INDEC: `http://localhost:8080/api/v1`
- API Super1 (SOAP): `http://localhost:8081/ws`
- API Super2 (REST): `http://localhost:8082/api/v1`
- API Super3 (SOAP): `http://localhost:8083/ws`
- API Super4 (REST): `http://localhost:8084/api/v1`
- Client ES: `http://localhost:4200`
- Client EN: `http://localhost:4201`
- SQL Server: `localhost:1433`

## Comandos útiles

### Build dentro de contenedores

```bash
docker compose -f docker/dev/docker-compose.yml exec api-indec ./mvnw clean install
docker compose -f docker/dev/docker-compose.yml exec api-super1 ./mvnw clean install
docker compose -f docker/dev/docker-compose.yml exec api-super2 ./mvnw clean install
docker compose -f docker/dev/docker-compose.yml exec api-super3 ./mvnw clean install
docker compose -f docker/dev/docker-compose.yml exec api-super4 ./mvnw clean install
docker compose -f docker/dev/docker-compose.yml exec client-es npm install
```

### Logs por servicio

```bash
docker compose -f docker/dev/docker-compose.yml logs -f api-indec
docker compose -f docker/dev/docker-compose.yml logs -f api-super1
docker compose -f docker/dev/docker-compose.yml logs -f api-super2
docker compose -f docker/dev/docker-compose.yml logs -f api-super3
docker compose -f docker/dev/docker-compose.yml logs -f api-super4
docker compose -f docker/dev/docker-compose.yml logs -f client-es
docker compose -f docker/dev/docker-compose.yml logs -f client-en
docker compose -f docker/dev/docker-compose.yml logs -f sqlserver
```

## Debug remoto (Java)

- `api-indec`: `5005`
- `api-super1`: `5006`
- `api-super2`: `5007`
- `api-super3`: `5008`
- `api-super4`: `5009`

Ejemplo `launch.json` (VS Code):

```json
{
  "type": "java",
  "name": "Debug api-indec",
  "request": "attach",
  "hostName": "localhost",
  "port": 5005
}
```

## Base de datos

Credenciales por defecto:

- Usuario: `sa`
- Password: `Admin123!`

Bases utilizadas:

- `indec`
- `supermercado1`
- `supermercado2`
- `supermercado3`
- `supermercado4`

Los scripts iniciales se aplican al crear el contenedor de SQL Server por primera vez.

## Estructura

```text
.
├── api-indec/
├── api-super1/
├── api-super2/
├── api-super3/
├── api-super4/
├── client/
├── db/
├── docker/dev/
└── docs/
```

## Readmes por módulo

- `api-indec/README`
- `api-super1/README`
- `api-super2/README.md`
- `api-super3/README`
- `api-super4/README.md`
- `client/README.md`
