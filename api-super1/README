# API Super1 (SOAP)

Servicio SOAP del supermercado 1.

## Base URL

- Servicio: `http://localhost:8081/ws`
- WSDL sucursales: `http://localhost:8081/ws/sucursales.wsdl`
- WSDL productos: `http://localhost:8081/ws/productos.wsdl`

## Autenticación

WS-Security UsernameToken:

- Usuario: `carrefour`
- Password: `a5s1d7fg4`

## Ejemplo: obtener sucursales

```xml
<soapenv:Envelope
    xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope"
    xmlns:web="http://services.super1.das.ubp.edu.ar/"
    xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
    <soapenv:Header>
        <wsse:Security>
            <wsse:UsernameToken>
                <wsse:Username>carrefour</wsse:Username>
                <wsse:Password>a5s1d7fg4</wsse:Password>
            </wsse:UsernameToken>
        </wsse:Security>
    </soapenv:Header>
    <soapenv:Body>
        <web:obtenerSucursales/>
    </soapenv:Body>
</soapenv:Envelope>
```

## Ejemplo: obtener productos

```xml
<soapenv:Envelope
    xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope"
    xmlns:web="http://services.super1.das.ubp.edu.ar/"
    xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
    <soapenv:Header>
        <wsse:Security>
            <wsse:UsernameToken>
                <wsse:Username>carrefour</wsse:Username>
                <wsse:Password>a5s1d7fg4</wsse:Password>
            </wsse:UsernameToken>
        </wsse:Security>
    </soapenv:Header>
    <soapenv:Body>
        <web:obtenerProductos/>
    </soapenv:Body>
</soapenv:Envelope>
```
