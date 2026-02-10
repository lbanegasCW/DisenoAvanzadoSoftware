package ar.edu.ubp.das.api.batch;

import ar.edu.ubp.das.api.ApiApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.context.ApplicationContext;


public class Consumidor {

    public static void main(String[] args) {
        ApplicationContext context = new SpringApplicationBuilder(ApiApplication.class)
                .web(WebApplicationType.NONE)
                .run(args);

        ConsumidorServiciosSupermercados tarea = context.getBean(ConsumidorServiciosSupermercados.class);
        tarea.ejecutar();
    }
}
