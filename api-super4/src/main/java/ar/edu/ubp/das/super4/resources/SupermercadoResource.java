package ar.edu.ubp.das.super4.resources;

import ar.edu.ubp.das.super4.repositories.SupermercadoRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/supermercado")
public class SupermercadoResource {

    @Autowired
    private SupermercadoRepository supermercadoRepository;

    @GetMapping(value = "/sucursales", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> getSucursalesJson() {
        String json = supermercadoRepository.getSucursalesJson();
        if (json == null || json.isBlank() || "null".equalsIgnoreCase(json.trim())) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(json);
    }

    @GetMapping(value = "/productos", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> getProductosJsonAll() {
        String json = supermercadoRepository.getProductosJsonAll();
        if (json == null || json.isBlank() || "null".equalsIgnoreCase(json.trim())) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(json);
    }

}
