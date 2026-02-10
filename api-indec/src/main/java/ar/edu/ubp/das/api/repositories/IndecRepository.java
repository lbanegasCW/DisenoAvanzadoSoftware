package ar.edu.ubp.das.api.repositories;

import ar.edu.ubp.das.api.batch.beans.ProductoSucursalBean;
import ar.edu.ubp.das.api.beans.*;
import ar.edu.ubp.das.api.components.SimpleJdbcCallFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class IndecRepository {

        @Autowired
        private SimpleJdbcCallFactory jdbcCallFactory;

        public List<ProvinciaBean> getAllProvincias() {
                return jdbcCallFactory.executeQuery("sp_get_all_provincias", "dbo", "provincias", ProvinciaBean.class);
        }

        public List<LocalidadBean> getLocalidadesByProvincia(String codProvincia, String codPais) {
                SqlParameterSource params = new MapSqlParameterSource()
                                .addValue("cod_provincia", codProvincia)
                                .addValue("cod_pais", codPais);
                return jdbcCallFactory.executeQuery(
                                "sp_get_localidades_by_provincia", "dbo", params, "localidades", LocalidadBean.class);
        }

        public List<SupermercadoBean> getAllSupermercados() {
                return jdbcCallFactory.executeQuery("sp_get_all_supermercados", "dbo", "supermercados",
                                SupermercadoBean.class);
        }

        public List<SucursalBean> getSucursales(Integer nroSupermercado, Integer nroLocalidad,
                        String codProvincia, String codPais) {
                SqlParameterSource params = new MapSqlParameterSource()
                                .addValue("nro_supermercado", nroSupermercado)
                                .addValue("nro_localidad", nroLocalidad)
                                .addValue("cod_provincia", codProvincia)
                                .addValue("cod_pais", codPais);
                return jdbcCallFactory.executeQuery("sp_get_sucursales", "dbo", params, "sucursales",
                                SucursalBean.class);
        }

        public List<Map<String, Object>> getProductos() {
                return jdbcCallFactory.executeQueryForList(
                        "sp_get_productos",
                        "dbo",
                        "productos"
                );
        }

        public List<Map<String, Object>> getProductosPrecios(int nroLocalidad, List<String> codigos) {
                String csv = codigos == null ? "" : String.join(",", codigos);
                SqlParameterSource params = new MapSqlParameterSource()
                        .addValue("nro_localidad", nroLocalidad)
                        .addValue("codigos", csv);

                return jdbcCallFactory.executeQueryForList(
                        "sp_get_productos_precios",
                        "dbo",
                        params,
                        "productos"
                );
        }

        public void insertarSucursal(SucursalBean sucursal) {
                SqlParameterSource params = new MapSqlParameterSource()
                        .addValue("nro_supermercado", sucursal.getNroSupermercado())
                        .addValue("nro_sucursal", sucursal.getNroSucursal())
                        .addValue("nom_sucursal", sucursal.getNomSucursal())
                        .addValue("calle", sucursal.getCalle())
                        .addValue("nro_calle", sucursal.getNroCalle())
                        .addValue("telefonos", sucursal.getTelefonos())
                        .addValue("coord_latitud", sucursal.getCoordLatitud())
                        .addValue("coord_longitud", sucursal.getCoordLongitud())
                        .addValue("horario_sucursal", sucursal.getHorarioSucursal())
                        .addValue("servicios_disponibles", sucursal.getServiciosDisponibles())
                        .addValue("nro_localidad", sucursal.getNroLocalidad())
                        .addValue("habilitada", sucursal.getHabilitada());

                jdbcCallFactory.execute("sp_insertar_sucursal", "dbo", params);
        }

        public void insertarProducto(ProductoSucursalBean producto, int nroSupermercado, int nroSucursal) {
                SqlParameterSource params = new MapSqlParameterSource()
                        .addValue("nro_supermercado", nroSupermercado)
                        .addValue("nro_sucursal", nroSucursal)
                        .addValue("nroRubro", producto.getNroRubro())
                        .addValue("nomRubro", producto.getNomRubro())
                        .addValue("nroCategoria", producto.getNroCategoria())
                        .addValue("nomCategoria", producto.getNomCategoria())
                        .addValue("cod_barra", producto.getCod_barra())
                        .addValue("nomProducto", producto.getNomProducto())
                        .addValue("descProducto", producto.getDescProducto())
                        .addValue("imagen", producto.getImagen())
                        .addValue("nroMarca", producto.getNroMarca())
                        .addValue("nomMarca", producto.getNomMarca())
                        .addValue("nroTipoProducto", producto.getNroTipoProducto())
                        .addValue("nomTipoProducto", producto.getNomTipoProducto())
                        .addValue("precio", producto.getPrecio());

                jdbcCallFactory.execute("sp_insertar_producto", "dbo", params);
        }

}