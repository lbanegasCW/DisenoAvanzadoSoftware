package ar.edu.ubp.das.super1.services;

import ar.edu.ubp.das.super1.repositories.SupermercadoRepository;
import jakarta.jws.WebMethod;
import jakarta.jws.WebService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
@WebService(serviceName = "SupermercadoService", targetNamespace = "http://services.super1.das.ubp.edu.ar/")
public class SupermercadoService {

    @Autowired
    private SupermercadoRepository supermercadoRepository;

    @WebMethod(operationName = "getSucursalesXml")
    public String getSucursalesXml() {
        return supermercadoRepository.getSucursalesXml();
    }

    @WebMethod(operationName = "getProductosXmlAll")
    public String getProductosXmlAll() {
        return supermercadoRepository.getProductosXmlAll();
    }

}