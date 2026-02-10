package ar.edu.ubp.das.api.batch;

public class SupermercadoServiceFactory {

        public static final String REST = "REST";
        public static final String SOAP = "SOAP";

        public static SupermercadoService obtenerServicio(String tipoServicio) {
            if (REST.equalsIgnoreCase(tipoServicio)) {
                return new SupermercadoServiceREST();
            } else if (SOAP.equalsIgnoreCase(tipoServicio)) {
                return new SupermercadoServiceSOAP();
            }
            throw new IllegalArgumentException("Tipo de servicio no soportado: " + tipoServicio);
        }
}
