package com.clinicaapp.controller.rest;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/health")
public class ApiHealthController {

    @GetMapping
    public Map<String, Object> getHealth() {
        Map<String, Object> status = new HashMap<>();
        status.put("status", "UP");
        return status;
    }
}
