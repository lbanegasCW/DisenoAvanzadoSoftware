package ar.edu.ubp.das.api.beans;

import ar.edu.ubp.das.api.batch.beans.SucursalSupermercadoBean;

public class SucursalBean {
    private Integer nroSupermercado;
    private Integer nroSucursal;
    private String nomSucursal;
    private String calle;
    private String nroCalle;
    private String telefonos;
    private Double coordLatitud;
    private Double coordLongitud;
    private String horarioSucursal;
    private String serviciosDisponibles;
    private Boolean habilitada;
    private String razonSocial;
    private Integer nroLocalidad;
    private String nomLocalidad;
    private String codProvincia;
    private String nomProvincia;
    private String codPais;
    private String nomPais;

    public SucursalBean() {
    }

    public SucursalBean(int nroSupermercado,
                        SucursalSupermercadoBean sucursal,
                        String horarioSucursal, String serviciosDisponibles) {
        this.nroSupermercado = nroSupermercado;
        this.nroSucursal = sucursal.getNroSucursal();
        this.nomSucursal = sucursal.getNomSucursal();
        this.calle = sucursal.getCalle();
        this.nroCalle = sucursal.getCalle();
        this.telefonos = sucursal.getTelefonos();
        this.coordLatitud = sucursal.getCoordLatitud();
        this.coordLongitud = sucursal.getCoordLongitud();
        this.horarioSucursal = horarioSucursal;
        this.serviciosDisponibles = serviciosDisponibles;
        this.habilitada = sucursal.isHabilitada();
        this.razonSocial = sucursal.getCalle();
        this.nroLocalidad = sucursal.getNroLocalidad();
        this.nomLocalidad = sucursal.getNomLocalidad();
        this.codProvincia = sucursal.getCodProvincia();
        this.nomProvincia = sucursal.getNomProvincia();
        this.codPais = sucursal.getCodPais();
        this.nomPais = sucursal.getNomPais();
    }

    // Getters y Setters
    public Integer getNroSupermercado() {
        return nroSupermercado;
    }

    public void setNroSupermercado(Integer nroSupermercado) {
        this.nroSupermercado = nroSupermercado;
    }

    public Integer getNroSucursal() {
        return nroSucursal;
    }

    public void setNroSucursal(Integer nroSucursal) {
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

    public String getNroCalle() {
        return nroCalle;
    }

    public void setNroCalle(String nroCalle) {
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

    public String getHorarioSucursal() {
        return horarioSucursal;
    }

    public void setHorarioSucursal(String horarioSucursal) {
        this.horarioSucursal = horarioSucursal;
    }

    public String getServiciosDisponibles() {
        return serviciosDisponibles;
    }

    public void setServiciosDisponibles(String serviciosDisponibles) {
        this.serviciosDisponibles = serviciosDisponibles;
    }

    public Boolean getHabilitada() {
        return habilitada;
    }

    public void setHabilitada(Boolean habilitada) {
        this.habilitada = habilitada;
    }

    public String getRazonSocial() {
        return razonSocial;
    }

    public void setRazonSocial(String razonSocial) {
        this.razonSocial = razonSocial;
    }

    public Integer getNroLocalidad() {
        return nroLocalidad;
    }

    public void setNroLocalidad(Integer nroLocalidad) {
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
}