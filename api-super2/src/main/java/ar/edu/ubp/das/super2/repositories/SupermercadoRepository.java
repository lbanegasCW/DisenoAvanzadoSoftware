package ar.edu.ubp.das.super2.repositories;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class SupermercadoRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public String getSucursalesJson() {
        return jdbcTemplate.query(
                "EXEC dbo.sp_get_sucursales",
                rs -> rs.next() ? rs.getString(1) : null
        );
    }

    public String getProductosJsonAll() {
        return jdbcTemplate.query(
                "EXEC dbo.sp_get_productos",
                rs -> rs.next() ? rs.getString(1) : null
        );
    }

}
