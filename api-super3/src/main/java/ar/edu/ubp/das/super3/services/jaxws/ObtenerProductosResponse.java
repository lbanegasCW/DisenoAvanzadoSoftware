package ar.edu.ubp.das.super3.services.jaxws;

import org.w3c.dom.Element;
import jakarta.xml.bind.annotation.*;

import java.util.List;

@XmlRootElement(name = "obtenerProductosResponse", namespace = "http://services.super3.das.ubp.edu.ar/")
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "obtenerProductosResponse", namespace = "http://services.super3.das.ubp.edu.ar/")
public class ObtenerProductosResponse {

    @XmlAnyElement(lax = true)
    private List<Element> any;

    public List<Element> getAny() { return any; }
    public void setAny(List<Element> any) { this.any = any; }
}
