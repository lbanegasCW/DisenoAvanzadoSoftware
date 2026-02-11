package ar.edu.ubp.das.super3.repositories;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class SupermercadoRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public String getSucursalesXml() {
        return jdbcTemplate.query(
                "EXEC dbo.sp_get_sucursales",
                rs -> rs.next() ? rs.getString(1) : null
        );
    }

    public String getProductosXmlAll() {
        return jdbcTemplate.query(
                "EXEC dbo.sp_get_productos",
                rs -> rs.next() ? rs.getString(1) : null
        );
    }

}
