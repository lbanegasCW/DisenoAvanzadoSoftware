package ar.edu.ubp.das.api.batch;

import java.net.URI;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

final class SupermercadoEndpointResolver {

    private static final boolean RUNNING_IN_DOCKER = Files.exists(Path.of("/.dockerenv"));
    private static final Map<Integer, String> SERVICE_BY_PORT = Map.of(
            8081, "api-super1",
            8082, "api-super2",
            8083, "api-super3",
            8084, "api-super4"
    );

    private SupermercadoEndpointResolver() {
    }

    static String resolve(String endpoint) {
        if (!RUNNING_IN_DOCKER || endpoint == null || endpoint.isBlank()) {
            return endpoint;
        }

        try {
            URI uri = URI.create(endpoint);
            String host = uri.getHost();

            if (host == null || (!"localhost".equalsIgnoreCase(host) && !"127.0.0.1".equals(host))) {
                return endpoint;
            }

            String dockerHost = SERVICE_BY_PORT.get(uri.getPort());
            if (dockerHost == null) {
                return endpoint;
            }

            URI resolved = new URI(
                    uri.getScheme(),
                    uri.getUserInfo(),
                    dockerHost,
                    uri.getPort(),
                    uri.getPath(),
                    uri.getQuery(),
                    uri.getFragment()
            );

            return resolved.toString();
        } catch (Exception ignored) {
            return endpoint;
        }
    }
}
