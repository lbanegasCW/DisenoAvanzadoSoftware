package ar.edu.ubp.das.api.utils;

import com.google.gson.Gson;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import java.lang.reflect.Type;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

public class Httpful {

    private final WebClient.Builder clientBuilder;
    private final Gson gson = new Gson();

    private String path = "";
    private String method = "GET";
    private Object body;
    private String authHeader;
    private final Map<String, String> queryParams = new HashMap<>();

    public Httpful(String baseUrl) {
        this.clientBuilder = WebClient.builder().baseUrl(baseUrl);
    }

    public Httpful path(String path) {
        this.path = path;
        return this;
    }

    public Httpful method(String method) {
        this.method = method.toUpperCase();
        return this;
    }

    public Httpful basicAuth(String username, String password) {
        String token = Base64.getEncoder()
                .encodeToString((username + ":" + password).getBytes(StandardCharsets.UTF_8));
        this.authHeader = "Basic " + token;
        return this;
    }

    public Httpful addQueryParam(String key, String value) {
        this.queryParams.put(key, value);
        return this;
    }

    public Httpful post(Object body) {
        this.method = "POST";
        this.body = body;
        return this;
    }

    public Httpful put(Object body) {
        this.method = "PUT";
        this.body = body;
        return this;
    }

    public <T> T execute(Class<T> responseType) {
        String jsonResponse = sendRequest();
        return gson.fromJson(jsonResponse, responseType);
    }

    public <T> T execute(Type responseType) {
        String jsonResponse = sendRequest();
        return gson.fromJson(jsonResponse, responseType);
    }

    private String sendRequest() {
        WebClient client = clientBuilder.build();

        // construir URI con query params
        StringBuilder uriBuilder = new StringBuilder(this.path);
        if (!queryParams.isEmpty()) {
            uriBuilder.append("?");
            queryParams.forEach((k, v) -> uriBuilder.append(k).append("=").append(v).append("&"));
            uriBuilder.deleteCharAt(uriBuilder.length() - 1); // quitar último "&"
        }
        String finalUri = uriBuilder.toString();

        WebClient.RequestHeadersSpec<?> spec;

        switch (this.method) {
            case "GET":
                spec = client.get().uri(finalUri);
                break;
            case "POST":
                spec = client.post()
                        .uri(finalUri)
                        .contentType(MediaType.APPLICATION_JSON)
                        .body(BodyInserters.fromValue(body));
                break;
            case "PUT":
                spec = client.put()
                        .uri(finalUri)
                        .contentType(MediaType.APPLICATION_JSON)
                        .body(BodyInserters.fromValue(body));
                break;
            case "DELETE":
                spec = client.delete().uri(finalUri);
                break;
            default:
                throw new RuntimeException("Método HTTP no soportado: " + this.method);
        }

        if (this.authHeader != null) {
            spec = spec.header(HttpHeaders.AUTHORIZATION, this.authHeader);
        }

        return spec
                .accept(MediaType.APPLICATION_JSON)
                .retrieve()
                .bodyToMono(String.class)
                .block();
    }
}