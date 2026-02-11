package ar.edu.ubp.das.api.batch;

public interface  SupermercadoService {

    String obtenerSucursales(String endpoint, String user, String pass);

    String obtenerProductos(String endpoint, String user, String pass);
}

