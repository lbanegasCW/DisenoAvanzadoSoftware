package ar.edu.ubp.das.api.beans;

public class SucursalCriteriaBean {
    private Integer nroLocalidad;
    private Integer nroSupermercado;
    private Boolean soloHabilitadas;

    public Integer getNroLocalidad() {
        return nroLocalidad;
    }

    public void setNroLocalidad(Integer nroLocalidad) {
        this.nroLocalidad = nroLocalidad;
    }

    public Integer getNroSupermercado() {
        return nroSupermercado;
    }

    public void setNroSupermercado(Integer nroSupermercado) {
        this.nroSupermercado = nroSupermercado;
    }

    public Boolean getSoloHabilitadas() {
        return soloHabilitadas;
    }

    public void setSoloHabilitadas(Boolean soloHabilitadas) {
        this.soloHabilitadas = soloHabilitadas;
    }
}