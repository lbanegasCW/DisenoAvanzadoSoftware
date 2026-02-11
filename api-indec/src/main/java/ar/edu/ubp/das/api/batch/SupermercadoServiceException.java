package ar.edu.ubp.das.api.batch;

public class SupermercadoServiceException extends RuntimeException {
    private final String operation;
    private final String endpoint;

    public SupermercadoServiceException(String operation, String endpoint, String message, Throwable cause) {
        super(message, cause);
        this.operation = operation;
        this.endpoint = endpoint;
    }

    public String getOperation() { return operation; }
    public String getEndpoint() { return endpoint; }
}
