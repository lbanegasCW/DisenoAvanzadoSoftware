package ar.edu.ubp.das.api.beans;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class ProductoPrecioBean {
    private String codBarra;
    private String nomProducto;
    private String descProducto;

    private Integer nroCategoria;
    private String nomCategoria;
    private Integer nroRubro;
    private String nomRubro;

    private Integer nroMarca;
    private String nomMarca;

    private Integer nroTipoProducto;
    private String nomTipoProducto;

    private BigDecimal precio;
    private LocalDateTime fechaUltActualizacion;

    private Integer nroSupermercado;
    private String razonSocial;
    private Integer nroSucursal;
    private String nomSucursal;

    private Integer nroLocalidad;
    private String nomLocalidad;
    private String codProvincia;
    private String nomProvincia;
    private String codPais;
    private String nomPais;

    public String getCodBarra() {
        return codBarra;
    }

    public void setCodBarra(String codBarra) {
        this.codBarra = codBarra;
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

    public Integer getNroCategoria() {
        return nroCategoria;
    }

    public void setNroCategoria(Integer nroCategoria) {
        this.nroCategoria = nroCategoria;
    }

    public String getNomCategoria() {
        return nomCategoria;
    }

    public void setNomCategoria(String nomCategoria) {
        this.nomCategoria = nomCategoria;
    }

    public Integer getNroRubro() {
        return nroRubro;
    }

    public void setNroRubro(Integer nroRubro) {
        this.nroRubro = nroRubro;
    }

    public String getNomRubro() {
        return nomRubro;
    }

    public void setNomRubro(String nomRubro) {
        this.nomRubro = nomRubro;
    }

    public Integer getNroMarca() {
        return nroMarca;
    }

    public void setNroMarca(Integer nroMarca) {
        this.nroMarca = nroMarca;
    }

    public String getNomMarca() {
        return nomMarca;
    }

    public void setNomMarca(String nomMarca) {
        this.nomMarca = nomMarca;
    }

    public Integer getNroTipoProducto() {
        return nroTipoProducto;
    }

    public void setNroTipoProducto(Integer nroTipoProducto) {
        this.nroTipoProducto = nroTipoProducto;
    }

    public String getNomTipoProducto() {
        return nomTipoProducto;
    }

    public void setNomTipoProducto(String nomTipoProducto) {
        this.nomTipoProducto = nomTipoProducto;
    }

    public BigDecimal getPrecio() {
        return precio;
    }

    public void setPrecio(BigDecimal precio) {
        this.precio = precio;
    }

    public LocalDateTime getFechaUltActualizacion() {
        return fechaUltActualizacion;
    }

    public void setFechaUltActualizacion(LocalDateTime fechaUltActualizacion) {
        this.fechaUltActualizacion = fechaUltActualizacion;
    }

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
