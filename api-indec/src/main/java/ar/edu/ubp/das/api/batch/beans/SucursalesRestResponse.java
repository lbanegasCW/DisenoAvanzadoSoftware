package ar.edu.ubp.das.api.batch.beans;

import java.util.List;

public class SucursalesRestResponse {
    private List<SucursalSupermercadoBean> sucursales;
    public List<SucursalSupermercadoBean> getSucursales() { return sucursales; }
    public void setSucursales(List<SucursalSupermercadoBean> sucursales) { this.sucursales = sucursales; }
}