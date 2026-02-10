package ar.edu.ubp.das.api.batch;

import ar.edu.ubp.das.api.batch.beans.ProductoSucursalBean;
import ar.edu.ubp.das.api.batch.beans.SucursalSupermercadoBean;
import ar.edu.ubp.das.api.batch.beans.SucursalesRestResponse;
import ar.edu.ubp.das.api.utils.Httpful;
import com.google.gson.reflect.TypeToken;
import jakarta.ws.rs.HttpMethod;

import java.util.List;

public class SupermercadoServiceREST implements SupermercadoService {
    final String SERVICIO_SUCURSALES = "/sucursales";
    final String SERVICIO_PRODUCTOS = "/productos";

    @Override
    public List<SucursalSupermercadoBean> obtenerSucursales(String endpoint, String user, String pass) {
        SucursalesRestResponse resp = new Httpful(endpoint)
                .path(SERVICIO_SUCURSALES)
                .method(HttpMethod.GET)
                .basicAuth(user, pass)
                .execute(new TypeToken<SucursalesRestResponse>() {}.getType());

        return (resp != null && resp.getSucursales() != null) ? resp.getSucursales() : List.of();
    }

    @Override
    public List<ProductoSucursalBean> obtenerProductos(String endpoint, String user, String pass, int nroSucursal) {
        return new Httpful(endpoint)
                .path(SERVICIO_PRODUCTOS + "/" + nroSucursal)
                .method(HttpMethod.GET)
                .basicAuth(user, pass)
                .execute(new TypeToken<List<ProductoSucursalBean>>() {}.getType());
    }

}
