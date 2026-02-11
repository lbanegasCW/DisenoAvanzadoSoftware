package ar.edu.ubp.das.api.resources;

import ar.edu.ubp.das.api.beans.*;
import ar.edu.ubp.das.api.repositories.IndecRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
@RequestMapping("/")
@CrossOrigin(origins = "http://localhost:4200", maxAge = 3600)
public class IndecResource {

    @Autowired
    private IndecRepository indecRepository;

    @GetMapping("/provincias")
    public ResponseEntity<List<ProvinciaBean>> getAllProvincias() {
        return ResponseEntity.ok(indecRepository.getAllProvincias());
    }

    @GetMapping("/provincias/{cod_provincia}/localidades")
    public ResponseEntity<List<LocalidadBean>> getLocalidadesByProvincia(
            @PathVariable("cod_provincia") String codProvincia,
            @RequestParam String codPais) {
        return ResponseEntity.ok(indecRepository.getLocalidadesByProvincia(codProvincia, codPais));
    }

    @GetMapping("/supermercados")
    public ResponseEntity<List<SupermercadoBean>> getAllSupermercados() {
        return ResponseEntity.ok(indecRepository.getAllSupermercados());
    }

    @GetMapping("/sucursales")
    public ResponseEntity<List<SucursalBean>> getSucursales(
            @RequestParam(required = false) Integer supermercadoId,
            @RequestParam(required = false) Integer localidadId,
            @RequestParam(required = false) String provinciaId,
            @RequestParam(required = false) String paisId) {
        return ResponseEntity.ok(indecRepository.getSucursales(supermercadoId, localidadId, provinciaId, paisId));
    }

    @GetMapping(value = "/productos", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<Map<String, Object>>> getProductos(
            @RequestParam(name = "lang", required = false, defaultValue = "es") String lang
    ) {
        var rows = indecRepository.getProductos(normalizeLang(lang));
        return ResponseEntity.ok(rows);
    }

    @PostMapping(
            path = "/productosPrecios",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public ResponseEntity<List<Map<String, Object>>> getProductosPrecios(
            @RequestBody Map<String, Object> body
    ) {
        // 1) Extraer nroLocalidad
        Object locObj = body.get("nroLocalidad");
        if (locObj == null) {
            return ResponseEntity.badRequest().build();
        }
        int nroLocalidad = (locObj instanceof Number)
                ? ((Number) locObj).intValue()
                : Integer.parseInt(locObj.toString());

        String lang = normalizeLang(Objects.toString(body.get("lang"), null));

        if (nroLocalidad <= 0) {
            return ResponseEntity.badRequest().build();
        }

        // 2) Extraer y normalizar códigos
        @SuppressWarnings("unchecked")
        List<Object> raw = (List<Object>) body.get("codigos");
        if (raw == null || raw.isEmpty()) {
            return ResponseEntity.ok(List.of());
        }

        List<String> codigos = raw.stream()
                .filter(Objects::nonNull)
                .map(Object::toString)
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toList();

        if (codigos.isEmpty()) {
            return ResponseEntity.ok(List.of());
        }

        // 3) Llamar al repo (tu SP)
        List<Map<String, Object>> rows = indecRepository.getProductosPrecios(nroLocalidad, codigos, lang);

        return ResponseEntity.ok(rows);
    }

    private String normalizeLang(String lang) {
        if (lang == null || lang.isBlank()) {
            return "es";
        }

        String normalized = lang.trim().toLowerCase();
        if (normalized.length() > 2) {
            normalized = normalized.substring(0, 2);
        }

        return switch (normalized) {
            case "en" -> "en";
            default -> "es";
        };
    }

}
