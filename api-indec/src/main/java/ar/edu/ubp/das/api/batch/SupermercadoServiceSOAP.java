package ar.edu.ubp.das.api.batch;

import ar.edu.ubp.das.api.batch.soapResponses.*;
import ar.edu.ubp.das.api.utils.SOAPClient;
import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.Marshaller;

import java.io.StringWriter;

public class SupermercadoServiceSOAP implements SupermercadoService {
    final String SERVICIO_SUCURSALES = "sucursales.wsdl";
    final String SERVICIO_PRODUCTOS = "productos.wsdl";

    private enum NsByUser {
        CARREFOUR("http://services.super1.das.ubp.edu.ar/"),
        LIBERTAD("http://services.super3.das.ubp.edu.ar/");

        final String ns;
        NsByUser(String ns) { this.ns = ns; }

        static String of(String user) {
            return valueOf(user.trim().toUpperCase()).ns;
        }
    }

    private static String ns(String user) {
        return NsByUser.of(user);
    }

    @Override
    public String obtenerSucursales(String endpoint, String user, String pass) {
        String resolvedEndpoint = SupermercadoEndpointResolver.resolve(endpoint);
        String wsdl = resolvedEndpoint + SERVICIO_SUCURSALES;
        try {
            SOAPClient client = new SOAPClient.SOAPClientBuilder()
                    .wsdlUrl(wsdl)
                    .namespace(ns(user))
                    .serviceName("SucursalesPortService")
                    .portName("SucursalesPortSoap12")
                    .operationName("obtenerSucursales")
                    .username(user)
                    .password(pass)
                    .build();

            SucursalesResponse resp =
                    client.callServiceForObject(SucursalesResponse.class, "obtenerSucursalesResponse");

            return marshalToXml(resp);
        } catch (Exception e) {
            throw new SupermercadoServiceException(
                    "obtenerSucursales(SOAP)", wsdl,
                    "Error llamando servicio SOAP de sucursales", e
            );
        }
    }

    @Override
    public String obtenerProductos(String endpoint, String user, String pass) {
        String resolvedEndpoint = SupermercadoEndpointResolver.resolve(endpoint);
        String wsdl = resolvedEndpoint + SERVICIO_PRODUCTOS;
        try {
            SOAPClient client = new SOAPClient.SOAPClientBuilder()
                    .wsdlUrl(wsdl)
                    .namespace(ns(user))
                    .serviceName("ProductosPortService")
                    .portName("ProductosPortSoap12")
                    .operationName("obtenerProductos")
                    .username(user)
                    .password(pass)
                    .build();

            ProductosResponse resp =
                    client.callServiceForObject(ProductosResponse.class, "obtenerProductosResponse");

            return marshalToXml(resp);
        } catch (Exception e) {
            throw new SupermercadoServiceException(
                    "obtenerProductos(SOAP)", wsdl,
                    "Error llamando servicio SOAP de productos", e
            );
        }
    }

    private static String marshalToXml(Object obj) {
        try {
            JAXBContext ctx = JAXBContext.newInstance(obj.getClass());
            Marshaller marshaller = ctx.createMarshaller();
            marshaller.setProperty(Marshaller.JAXB_FRAGMENT, true);

            StringWriter sw = new StringWriter();
            marshaller.marshal(obj, sw);
            return sw.toString();
        } catch (Exception e) {
            throw new RuntimeException("Error marshalling XML", e);
        }
    }

}
