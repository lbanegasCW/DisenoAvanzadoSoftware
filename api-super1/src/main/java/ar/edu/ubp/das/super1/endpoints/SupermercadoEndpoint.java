package ar.edu.ubp.das.super1.endpoints;

import ar.edu.ubp.das.super1.services.SupermercadoService;
import ar.edu.ubp.das.super1.services.jaxws.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ws.server.endpoint.annotation.Endpoint;
import org.springframework.ws.server.endpoint.annotation.PayloadRoot;
import org.springframework.ws.server.endpoint.annotation.RequestPayload;
import org.springframework.ws.server.endpoint.annotation.ResponsePayload;

@Endpoint
public class SupermercadoEndpoint {
    private static final String NAMESPACE_URI = "http://services.super1.das.ubp.edu.ar/";

    @Autowired
    private SupermercadoService service;

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "obtenerSucursales")
    @ResponsePayload
    public ObtenerSucursalesResponse getSucursales(@RequestPayload ObtenerSucursales request) throws Exception {
        String sucursales = service.getSucursalesXml();

        var f = javax.xml.parsers.DocumentBuilderFactory.newInstance();
        f.setNamespaceAware(true);
        f.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
        f.setFeature("http://xml.org/sax/features/external-general-entities", false);
        f.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
        var b = f.newDocumentBuilder();
        var doc = b.parse(new org.xml.sax.InputSource(new java.io.StringReader(sucursales)));
        org.w3c.dom.Element root = doc.getDocumentElement();
        org.w3c.dom.NodeList children = root.getChildNodes();
        java.util.List<org.w3c.dom.Element> elements = new java.util.ArrayList<>();
        for (int i = 0; i < children.getLength(); i++) {
            if (children.item(i) instanceof org.w3c.dom.Element el) {
                elements.add(el);
            }
        }

        var resp = new ObtenerSucursalesResponse();
        resp.setAny(elements);
        return resp;
    }

    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "obtenerProductos")
    @ResponsePayload
    public ObtenerProductosResponse getProductos(@RequestPayload ObtenerProductos request) throws Exception {
        String productos = service.getProductosXmlAll();

        var f = javax.xml.parsers.DocumentBuilderFactory.newInstance();
        f.setNamespaceAware(true);
        f.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
        f.setFeature("http://xml.org/sax/features/external-general-entities", false);
        f.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
        var b = f.newDocumentBuilder();
        var doc = b.parse(new org.xml.sax.InputSource(new java.io.StringReader(productos)));
        org.w3c.dom.Element root = doc.getDocumentElement();
        org.w3c.dom.NodeList children = root.getChildNodes();
        java.util.List<org.w3c.dom.Element> elements = new java.util.ArrayList<>();
        for (int i = 0; i < children.getLength(); i++) {
            if (children.item(i) instanceof org.w3c.dom.Element el) {
                elements.add(el);
            }
        }

        var resp = new ObtenerProductosResponse();
        resp.setAny(elements);
        return resp;
    }

}