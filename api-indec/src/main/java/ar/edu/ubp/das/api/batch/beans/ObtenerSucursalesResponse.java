package ar.edu.ubp.das.api.batch.beans;

import jakarta.xml.bind.annotation.*;
import org.w3c.dom.Element;
import java.util.List;

@XmlRootElement(name = "obtenerSucursalesResponse", namespace = "http://services.super1.das.ubp.edu.ar/")
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "obtenerSucursalesResponse", namespace = "http://services.super1.das.ubp.edu.ar/")
public class ObtenerSucursalesResponse {

    @XmlAnyElement(lax = true)
    private List<Element> any;

    public List<Element> getAny() { return any; }
    public void setAny(List<Element> any) { this.any = any; }
}
