package ar.edu.ubp.das.api.beans;

public class SupermercadoBean {
    private Integer nroSupermercado;
    private String razonSocial;
    private String urlServicio;
    private String tipoServicio;
    private String tokenServicio;
    private Boolean estadoServicio;

    public Integer getNroSupermercado() {
        return nroSupermercado;
    }

    public void setNroSupermercado(Integer nroSupermercado) {
        this.nroSupermercado = nroSupermercado;
    }

    public String getRazonSocial() {
        return razonSocial;
    }

    public void setRazonSocial(String razonSocial) {
        this.razonSocial = razonSocial;
    }

    public String getUrlServicio() {
        return urlServicio;
    }

    public void setUrlServicio(String urlServicio) {
        this.urlServicio = urlServicio;
    }

    public String getTipoServicio() {
        return tipoServicio;
    }

    public void setTipoServicio(String tipoServicio) {
        this.tipoServicio = tipoServicio;
    }

    public String getTokenServicio() { return tokenServicio; }

    public void setTokenServicio(String tokenServicio) { this.tokenServicio = tokenServicio; }

    public Boolean getEstadoServicio() {
        return estadoServicio;
    }

    public void setEstadoServicio(Boolean estadoServicio) {
        this.estadoServicio = estadoServicio;
    }
}