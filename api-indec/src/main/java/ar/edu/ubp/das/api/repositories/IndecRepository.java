package ar.edu.ubp.das.api.repositories;

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

        public List<Map<String, Object>> getProductos(String codIdioma) {
                SqlParameterSource params = new MapSqlParameterSource()
                                .addValue("cod_idioma", codIdioma);

                return jdbcCallFactory.executeQueryForList(
                        "sp_get_productos",
                        "dbo",
                        params,
                        "productos"
                );
        }

        public List<Map<String, Object>> getProductosPrecios(int nroLocalidad, List<String> codigos, String codIdioma) {
                String csv = codigos == null ? "" : String.join(",", codigos);
                SqlParameterSource params = new MapSqlParameterSource()
                        .addValue("nro_localidad", nroLocalidad)
                        .addValue("codigos", csv)
                        .addValue("cod_idioma", codIdioma);

                return jdbcCallFactory.executeQueryForList(
                        "sp_get_productos_precios",
                        "dbo",
                        params,
                        "productos"
                );
        }

        public void upsertSucursales(int nroSupermercado, String formato, String payload) {
                SqlParameterSource params = new MapSqlParameterSource()
                        .addValue("nro_supermercado",nroSupermercado)
                        .addValue("formato", formato)
                        .addValue("payload", payload);

                jdbcCallFactory.execute("sp_upsert_sucursales", "dbo", params);
        }

        public void upsertProductos(int nroSupermercado, String formato, String payload) {
                SqlParameterSource params = new MapSqlParameterSource()
                        .addValue("nro_supermercado",nroSupermercado)
                        .addValue("formato", formato)
                        .addValue("payload", payload);

                jdbcCallFactory.execute("sp_upsert_productos", "dbo", params);
        }

}