
package ar.edu.ubp.das.api.batch;

import ar.edu.ubp.das.api.batch.beans.ProductoSucursalBean;
import ar.edu.ubp.das.api.batch.beans.SucursalSupermercadoBean;
import ar.edu.ubp.das.api.beans.SucursalBean;
import ar.edu.ubp.das.api.beans.SupermercadoBean;
import ar.edu.ubp.das.api.repositories.IndecRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ConsumidorServiciosSupermercados {

    @Autowired
    private IndecRepository indecRepository;

    public void ejecutar() {
        List<SupermercadoBean> supermercados = indecRepository.getAllSupermercados();

        for (SupermercadoBean supermercado : supermercados) {
            System.out.println("\\nEjecutando actualización diaria para supermercado: " + supermercado.getRazonSocial());
            SupermercadoService servicioSuper = SupermercadoServiceFactory.obtenerServicio(supermercado.getTipoServicio());
            String[] token = supermercado.getTokenServicio().split("\\.");

            List<SucursalSupermercadoBean> sucursales = servicioSuper.obtenerSucursales(
                    supermercado.getUrlServicio(), token[0], token[1]);

            for (SucursalSupermercadoBean sucursalSuper : sucursales) {
                SucursalBean sucursal = new SucursalBean(
                        supermercado.getNroSupermercado(),
                        sucursalSuper,
                        SupermercadoFormatter.formatearHorarios(sucursalSuper.getHorarios()),
                        SupermercadoFormatter.formatearServicios(sucursalSuper.getTipoServicioSucursal()));
                indecRepository.insertarSucursal(sucursal);

                List<ProductoSucursalBean> productos = servicioSuper.obtenerProductos(
                        supermercado.getUrlServicio(), token[0], token[1], sucursal.getNroSucursal());

                for (ProductoSucursalBean productoSucursal : productos) {
                    indecRepository.insertarProducto(
                            productoSucursal, sucursal.getNroSupermercado(), sucursal.getNroSucursal());
                }
            }

        }
    }

}