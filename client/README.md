# Client (Angular)

Frontend de **ComparadorDePrecios** desarrollado con Angular 18.

## Requisitos

- Node.js 18+
- npm

## Instalación

```bash
npm install
```

## Modos de ejecución

### Español (es-AR)

```bash
npm run start:es
```

Disponible en `http://localhost:4200`.

### Inglés (en)

```bash
npm run start:en
```

Disponible en `http://localhost:4201`.

## Scripts útiles

```bash
npm run build        # build estándar
npm run build:i18n   # build con localización
npm run test         # tests unitarios (Karma)
npm run extract-i18n # extraer mensajes para traducción
```

## Integración con backend

En entorno Docker de desarrollo, el frontend consume la API INDEC en `http://localhost:8080/api/v1`.
