package ar.edu.ubp.das.api.beans;

public class CategoriaBean {
    private Integer nroCategoria;
    private String nomCategoria;
    private Integer nroRubro;
    private String nomRubro;
    private Integer cantidadProductos;

    public Integer getNroCategoria() { return nroCategoria; }
    public void setNroCategoria(Integer nroCategoria) { this.nroCategoria = nroCategoria; }

    public String getNomCategoria() { return nomCategoria; }
    public void setNomCategoria(String nomCategoria) { this.nomCategoria = nomCategoria; }

    public Integer getNroRubro() { return nroRubro; }
    public void setNroRubro(Integer nroRubro) { this.nroRubro = nroRubro; }

    public String getNomRubro() { return nomRubro; }
    public void setNomRubro(String nomRubro) { this.nomRubro = nomRubro; }

    public Integer getCantidadProductos() { return cantidadProductos; }
    public void setCantidadProductos(Integer cantidadProductos) { this.cantidadProductos = cantidadProductos; }
}
