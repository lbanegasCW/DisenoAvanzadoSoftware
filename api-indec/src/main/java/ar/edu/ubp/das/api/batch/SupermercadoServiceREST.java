package ar.edu.ubp.das.api.batch;

import ar.edu.ubp.das.api.utils.Httpful;
import com.google.gson.JsonObject;
import jakarta.ws.rs.HttpMethod;

public class SupermercadoServiceREST implements SupermercadoService {
    final String SERVICIO_SUCURSALES = "/sucursales";
    final String SERVICIO_PRODUCTOS = "/productos";

    @Override
    public String obtenerSucursales(String endpoint, String user, String pass) {
        String resolvedEndpoint = SupermercadoEndpointResolver.resolve(endpoint);
        try {
            return new Httpful(resolvedEndpoint)
                    .path(SERVICIO_SUCURSALES)
                    .method(HttpMethod.GET)
                    .basicAuth(user, pass)
                    .execute(JsonObject.class)
                    .toString();
        } catch (Exception e) {
            throw new SupermercadoServiceException(
                    "obtenerSucursales(REST)", resolvedEndpoint + SERVICIO_SUCURSALES,
                    "Error llamando servicio REST de sucursales", e
            );
        }
    }

    @Override
    public String obtenerProductos(String endpoint, String user, String pass) {
        String resolvedEndpoint = SupermercadoEndpointResolver.resolve(endpoint);
        try {
            return new Httpful(resolvedEndpoint)
                    .path(SERVICIO_PRODUCTOS)
                    .method(HttpMethod.GET)
                    .basicAuth(user, pass)
                    .execute(JsonObject.class)
                    .toString();
        } catch (Exception e) {
            throw new SupermercadoServiceException(
                    "obtenerProductos(REST)", resolvedEndpoint + SERVICIO_PRODUCTOS,
                    "Error llamando servicio REST de productos", e
            );
        }
    }


}
