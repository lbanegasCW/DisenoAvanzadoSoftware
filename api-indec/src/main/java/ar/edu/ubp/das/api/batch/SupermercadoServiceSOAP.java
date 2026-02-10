package ar.edu.ubp.das.api.batch;

import ar.edu.ubp.das.api.batch.beans.*;
import ar.edu.ubp.das.api.utils.SOAPClient;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

public class SupermercadoServiceSOAP implements SupermercadoService {
    final String SERVICIO_SUCURSALES = "sucursales.wsdl";
    final String SERVICIO_PRODUCTOS = "productos.wsdl";

    @Override
    public List<SucursalSupermercadoBean> obtenerSucursales(String endpoint, String user, String pass) {
        SOAPClient client = new SOAPClient.SOAPClientBuilder()
                .wsdlUrl(endpoint + SERVICIO_SUCURSALES)
                .namespace("http://services.super1.das.ubp.edu.ar/")
                .serviceName("SucursalesPortService")
                .portName("SucursalesPortSoap12")
                .operationName("obtenerSucursales")
                .username(user)
                .password(pass)
                .build();

        SucursalesAny sucursales = client.callServiceForObject(SucursalesAny.class, "obtenerSucursalesResponse");

        List<SucursalSupermercadoBean> sucursalesBeanList = new ArrayList<>();

        return sucursalesBeanList;
    }

    @Override
    public List<ProductoSucursalBean> obtenerProductos(String endpoint, String user, String pass, int nroSucursal) {
        SOAPClient client = new SOAPClient.SOAPClientBuilder()
                .wsdlUrl(endpoint + SERVICIO_PRODUCTOS)
                .namespace("http://services.super1.das.ubp.edu.ar/")
                .serviceName("ProductosPortService")
                .portName("ProductosPortSoap12")
                .operationName("obtenerProductos")
                .username(user)
                .password(pass)
                .build();

        List<ProductosResponse> productosResponseList =
                client.callServiceForList(
                        ProductosResponse.class,
                        "obtenerProductosResponse",
                        Collections.singletonMap("nroSucursal", nroSucursal)
                );
        List<ProductoSucursalBean> productosBeanList = new ArrayList<>();

        Iterator<ProductosResponse> iterator = productosResponseList.iterator();
        while (iterator.hasNext()) {
            productosBeanList.add(iterator.next());
        }

        return productosBeanList;
    }

}
