package ar.edu.ubp.das.api.batch.soapResponses;

import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlAnyElement;
import jakarta.xml.bind.annotation.XmlRootElement;
import org.w3c.dom.Element;

import java.util.List;

@XmlRootElement(name = "productosSucursales")
@XmlAccessorType(XmlAccessType.FIELD)
public class ProductosResponse {

    @XmlAnyElement(lax = true)
    private List<Element> any;

    public List<Element> getAny() { return any; }
    public void setAny(List<Element> any) { this.any = any; }
}