package ar.edu.ubp.das.api.batch.beans;

import jakarta.xml.bind.annotation.XmlRootElement;
import jakarta.xml.bind.annotation.XmlSeeAlso;

import java.util.List;

@XmlRootElement(name = "return")
@XmlSeeAlso({ObtenerSucursalesResponse.class, SucursalSupermercadoResponse.class})
public class SucursalSupermercadoBean {
    private int nroSucursal;
    private String nomSucursal;
    private String calle;
    private int nroCalle;
    private String telefonos;
    private Double coordLatitud;
    private Double coordLongitud;
    private boolean habilitada;
    private int nroLocalidad;
    private String nomLocalidad;
    private String codProvincia;
    private String nomProvincia;
    private String codPais;
    private String nomPais;
    private List<TipoServicioSucursalBean> tipoServicioSucursal;
    private List<HorarioSucursalBean> horarios;

    public SucursalSupermercadoBean() {
    }

    public int getNroSucursal() {
        return nroSucursal;
    }

    public void setNroSucursal(int nroSucursal) {
        this.nroSucursal = nroSucursal;
    }

    public String getNomSucursal() {
        return nomSucursal;
    }

    public void setNomSucursal(String nomSucursal) {
        this.nomSucursal = nomSucursal;
    }

    public String getCalle() {
        return calle;
    }

    public void setCalle(String calle) {
        this.calle = calle;
    }

    public int getNroCalle() {
        return nroCalle;
    }

    public void setNroCalle(int nroCalle) {
        this.nroCalle = nroCalle;
    }

    public String getTelefonos() {
        return telefonos;
    }

    public void setTelefonos(String telefonos) {
        this.telefonos = telefonos;
    }

    public Double getCoordLatitud() {
        return coordLatitud;
    }

    public void setCoordLatitud(Double coordLatitud) {
        this.coordLatitud = coordLatitud;
    }

    public Double getCoordLongitud() {
        return coordLongitud;
    }

    public void setCoordLongitud(Double coordLongitud) {
        this.coordLongitud = coordLongitud;
    }

    public boolean isHabilitada() {
        return habilitada;
    }

    public void setHabilitada(boolean habilitada) {
        this.habilitada = habilitada;
    }

    public int getNroLocalidad() {
        return nroLocalidad;
    }

    public void setNroLocalidad(int nroLocalidad) {
        this.nroLocalidad = nroLocalidad;
    }

    public String getNomLocalidad() {
        return nomLocalidad;
    }

    public void setNomLocalidad(String nomLocalidad) {
        this.nomLocalidad = nomLocalidad;
    }

    public String getCodProvincia() {
        return codProvincia;
    }

    public void setCodProvincia(String codProvincia) {
        this.codProvincia = codProvincia;
    }

    public String getNomProvincia() {
        return nomProvincia;
    }

    public void setNomProvincia(String nomProvincia) {
        this.nomProvincia = nomProvincia;
    }

    public String getCodPais() {
        return codPais;
    }

    public void setCodPais(String codPais) {
        this.codPais = codPais;
    }

    public String getNomPais() {
        return nomPais;
    }

    public void setNomPais(String nomPais) {
        this.nomPais = nomPais;
    }

    public List<TipoServicioSucursalBean> getTipoServicioSucursal() {
        return tipoServicioSucursal;
    }

    public void setTipoServicioSucursal(List<TipoServicioSucursalBean> tipoServicioSucursal) {
        this.tipoServicioSucursal = tipoServicioSucursal;
    }

    public List<HorarioSucursalBean> getHorarios() {
        return horarios;
    }

    public void setHorarios(List<HorarioSucursalBean> horarios) {
        this.horarios = horarios;
    }
}
