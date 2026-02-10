package ar.edu.ubp.das.api.batch;

import ar.edu.ubp.das.api.batch.beans.ProductoSucursalBean;
import ar.edu.ubp.das.api.batch.beans.SucursalSupermercadoBean;

import java.util.List;

public interface  SupermercadoService {

    List<SucursalSupermercadoBean> obtenerSucursales(String endpoint, String user, String pass);

    List<ProductoSucursalBean> obtenerProductos(String endpoint, String user, String pass, int nroSucursal);
}

