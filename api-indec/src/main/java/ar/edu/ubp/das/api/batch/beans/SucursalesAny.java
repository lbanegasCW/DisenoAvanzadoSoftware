package ar.edu.ubp.das.api.batch.beans;

import jakarta.xml.bind.annotation.*;
import org.w3c.dom.Element;
import java.util.List;

@XmlRootElement(name = "sucursales")
@XmlAccessorType(XmlAccessType.FIELD)
public class SucursalesAny {

    @XmlAnyElement(lax = true)
    private List<Element> any;

    public List<Element> getAny() { return any; }
    public void setAny(List<Element> any) { this.any = any; }
}