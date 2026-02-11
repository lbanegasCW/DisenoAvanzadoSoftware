
package ar.edu.ubp.das.api.batch;

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
            System.out.println("\nEjecutando actualización diaria para supermercado: " + supermercado.getRazonSocial());

            SupermercadoService servicioSuper = SupermercadoServiceFactory.obtenerServicio(supermercado.getTipoServicio());

            String[] token;
            try {
                token = supermercado.getTokenServicio().split("\\.");
                if (token.length < 2) throw new IllegalArgumentException("Token inválido (se esperaba user.pass)");
            } catch (Exception e) {
                System.out.println("ERROR: token inválido para supermercado " + supermercado.getNroSupermercado()
                        + " - " + supermercado.getRazonSocial() + " - token=" + supermercado.getTokenServicio());
                continue;
            }

            try {
                String sucursalesResponse = servicioSuper.obtenerSucursales(
                        supermercado.getUrlServicio(), token[0], token[1]);

                indecRepository.upsertSucursales(
                        supermercado.getNroSupermercado(), supermercado.getTipoServicio(), sucursalesResponse);

            } catch (SupermercadoServiceException e) {
                System.out.println("ERROR en " + supermercado.getRazonSocial()
                        + " | op=" + e.getOperation()
                        + " | endpoint=" + e.getEndpoint()
                        + " | msg=" + e.getMessage());

            } catch (Exception e) {
                System.out.println("ERROR inesperado actualizando sucursales para "
                        + supermercado.getRazonSocial() + ": " + e.getMessage());
            }

            try {
                String productosResponse = servicioSuper.obtenerProductos(
                        supermercado.getUrlServicio(), token[0], token[1]);

                indecRepository.upsertProductos(
                        supermercado.getNroSupermercado(), supermercado.getTipoServicio(), productosResponse);

            } catch (SupermercadoServiceException e) {
                System.out.println("ERROR en " + supermercado.getRazonSocial()
                        + " | op=" + e.getOperation()
                        + " | endpoint=" + e.getEndpoint()
                        + " | msg=" + e.getMessage());
            } catch (Exception e) {
                System.out.println("ERROR inesperado actualizando productos para "
                        + supermercado.getRazonSocial() + ": " + e.getMessage());
            }
        }
    }

}