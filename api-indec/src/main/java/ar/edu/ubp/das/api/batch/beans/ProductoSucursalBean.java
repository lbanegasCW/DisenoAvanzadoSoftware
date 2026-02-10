package ar.edu.ubp.das.api.batch.beans;

import jakarta.xml.bind.annotation.XmlRootElement;
import jakarta.xml.bind.annotation.XmlSeeAlso;

@XmlRootElement(name = "return")
@XmlSeeAlso({ProductosResponse.class, ProductoSucursalResponse.class})
public class ProductoSucursalBean {
    private int nroRubro;
    private String nomRubro;
    private int nroCategoria;
    private String nomCategoria;
    private String cod_barra;
    private String nomProducto;
    private String descProducto;
    private String imagen;
    private int nroMarca;
    private String nomMarca;
    private int nroTipoProducto;
    private String nomTipoProducto;
    private double precio;

    public ProductoSucursalBean() {
    }

    public int getNroRubro() {
        return nroRubro;
    }

    public void setNroRubro(int nroRubro) {
        this.nroRubro = nroRubro;
    }

    public String getNomRubro() {
        return nomRubro;
    }

    public void setNomRubro(String nomRubro) {
        this.nomRubro = nomRubro;
    }

    public int getNroCategoria() {
        return nroCategoria;
    }

    public void setNroCategoria(int nroCategoria) {
        this.nroCategoria = nroCategoria;
    }

    public String getNomCategoria() {
        return nomCategoria;
    }

    public void setNomCategoria(String nomCategoria) {
        this.nomCategoria = nomCategoria;
    }

    public String getCod_barra() {
        return cod_barra;
    }

    public void setCod_barra(String cod_barra) {
        this.cod_barra = cod_barra;
    }

    public String getNomProducto() {
        return nomProducto;
    }

    public void setNomProducto(String nomProducto) {
        this.nomProducto = nomProducto;
    }

    public String getDescProducto() {
        return descProducto;
    }

    public void setDescProducto(String descProducto) {
        this.descProducto = descProducto;
    }

    public String getImagen() {
        return imagen;
    }

    public void setImagen(String imagen) {
        this.imagen = imagen;
    }

    public int getNroMarca() {
        return nroMarca;
    }

    public void setNroMarca(int nroMarca) {
        this.nroMarca = nroMarca;
    }

    public String getNomMarca() {
        return nomMarca;
    }

    public void setNomMarca(String nomMarca) {
        this.nomMarca = nomMarca;
    }

    public int getNroTipoProducto() {
        return nroTipoProducto;
    }

    public void setNroTipoProducto(int nroTipoProducto) {
        this.nroTipoProducto = nroTipoProducto;
    }

    public String getNomTipoProducto() {
        return nomTipoProducto;
    }

    public void setNomTipoProducto(String nomTipoProducto) {
        this.nomTipoProducto = nomTipoProducto;
    }

    public double getPrecio() {
        return precio;
    }

    public void setPrecio(double precio) {
        this.precio = precio;
    }

}
