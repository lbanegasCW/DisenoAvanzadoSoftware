package ar.edu.ubp.das.api.errors;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
public class ApiErrorController implements ErrorController {

    @RequestMapping("/error")
    public ResponseEntity<Map<String,Object>> error(HttpServletRequest request) {
        Object statusObj = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        int status = (statusObj instanceof Integer) ? (Integer) statusObj : 500;

        String path = String.valueOf(request.getAttribute(RequestDispatcher.ERROR_REQUEST_URI));
        String message = String.valueOf(request.getAttribute(RequestDispatcher.ERROR_MESSAGE));
        if (message == null || "null".equals(message)) message = "Unexpected error";

        return ResponseEntity.status(status).body(Map.of(
                "path", path, "status", status, "message", message
        ));
    }
}
