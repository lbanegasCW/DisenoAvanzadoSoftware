# Información útil para el proyecto

## Prerequisitos

-   Docker y Docker Compose

Docker se encarga de proveer los demás requisitos en contenedores aislados:

-   Java 17 o superior
-   Maven
-   Node.js y npm para el frontend
-   SQL Server 2019 o superior

## Comandos útiles para desarrollo

### Construcción de proyectos dentro de contenedores

```bash
# Construir api-indec
docker-compose exec api-indec ./mvnw clean install

# Construir api-super1
docker-compose exec api-super1 ./mvnw clean install

# Construir api-super2
docker-compose exec api-super2 ./mvnw clean install

# Instalar dependencias del cliente Angular
docker-compose exec client npm install
```

### Operaciones con Docker Compose

```bash
# Levantar todos los servicios
docker-compose up -d

# Levantar un servicio específico
docker-compose up -d api-indec
docker-compose up -d api-super1
docker-compose up -d api-super2
docker-compose up -d client
docker-compose up -d sqlserver

# Detener los servicios
docker-compose down

# Ver logs
docker-compose logs -f api-indec
docker-compose logs -f api-super1
docker-compose logs -f api-super2
docker-compose logs -f client
docker-compose logs -f sqlserver

# Reconstruir servicios
docker-compose build api-indec
docker-compose build api-super1
docker-compose build api-super2
docker-compose build client
```

## Puertos de los servicios

-   API INDEC: http://localhost:8080
-   API Super1 (SOAP): http://localhost:8081
-   API Super2 (REST): http://localhost:8082
-   Cliente Angular: http://localhost:4200
-   SQL Server: localhost:1433

## Debugging

Los servicios Java tienen habilitado el debugging remoto en los siguientes puertos:

-   api-indec: 5005
-   api-super1: 5006
-   api-super2: 5007

### Configurar debug en IDE

Para Visual Studio Code, agregar esta configuración en launch.json:

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

### Credenciales por defecto

-   Usuario: sa
-   Password: Admin123!
-   Base de datos:
    -   indec
    -   supermercado1
    -   supermercado2

### Restaurar la base de datos

Los scripts de inicialización se ejecutan automáticamente al levantar el contenedor de SQL Server por primera vez.

## Servicios disponibles

### API INDEC

-   Gestión de países, provincias y localidades
-   Gestión de supermercados y sucursales
-   Gestión de productos y precios
-   Actualización automática de servicios

### API Super1 (SOAP)

-   Gestión de sucursales
-   Web Services en http://localhost:8081/ws/supermercado.wsdl
-   Autenticación mediante credenciales: carrefour/a5s1d7fg4

### API Super2 (REST)

-   Gestión de sucursales
-   API REST en http://localhost:8082/api/v1
-   Autenticación mediante credenciales: changoMas/c1h2s4f

## Estructura de carpetas

```
.
├── api-indec/          # API principal INDEC
├── api-super1/         # API SOAP Supermercado 1
├── api-super2/         # API REST Supermercado 2
├── client/            # Frontend Angular
├── db/                # Scripts y config de BD
└── docker/           # Configuración Docker
```

## Problemas comunes y soluciones

1. Error al conectar a SQL Server

    - Verificar que el contenedor sqlserver esté corriendo
    - Verificar credenciales en .env
    - Esperar a que la BD termine de inicializarse (~30s)

2. Error al construir los proyectos Java

    - Limpiar carpeta target: `./mvnw clean`
    - Verificar versión de Java (17)
    - Verificar dependencias en pom.xml

3. Error al iniciar el cliente Angular
    - Verificar node_modules: `npm install`
    - Limpiar cache: `npm cache clean --force`
    - Verificar versión de Node.js y npm
