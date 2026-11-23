package com.clinicaapp.controller.rest;

import com.clinicaapp.model.Producto;
import com.clinicaapp.service.IProductoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/productos")
@CrossOrigin(origins = "*")
public class ApiProductoController {

    @Autowired
    private IProductoService productoService;

    @Autowired
    private com.clinicaapp.repository.ProductoRepository productoRepository;

    @Autowired
    private com.clinicaapp.repository.UsuarioRepository usuarioRepository;

    @Autowired
    private com.clinicaapp.repository.NotificacionRepository notificacionRepository;

    @GetMapping
    public List<Producto> getAll() {
        return productoService.findAll();
    }

    @GetMapping("/categoria/{categoria}")
    public List<Producto> getByCategoria(@PathVariable String categoria) {
        return productoService.findByCategoria(categoria);
    }

    @PostMapping
    public Producto save(@RequestBody Producto producto) {
        return productoService.save(producto);
    }

    @PostMapping("/pedido")
    public ResponseEntity<?> crearPedido(@RequestBody java.util.Map<String, Object> payload) {
        String email = payload.get("email") != null ? payload.get("email").toString() : "";
        String direccion = payload.get("direccion") != null ? payload.get("direccion").toString() : "Entrega estándar";
        @SuppressWarnings("unchecked")
        List<java.util.Map<String, Object>> items = (List<java.util.Map<String, Object>>) payload.get("items");

        if (items == null || items.isEmpty()) {
            return ResponseEntity.badRequest().body(java.util.Map.of("success", false, "message", "El carrito está vacío"));
        }

        double total = 0.0;
        int totalItems = 0;
        StringBuilder resumen = new StringBuilder();

        for (java.util.Map<String, Object> item : items) {
            String prodId = item.get("productoId") != null ? item.get("productoId").toString() : "";
            int cant = 1;
            try { cant = Integer.parseInt(item.get("cantidad").toString()); } catch (Exception ignored) {}
            if (cant <= 0) cant = 1;

            Producto p = productoRepository.findById(prodId).orElse(null);
            if (p != null) {
                int stockActual = p.getStock() != null ? p.getStock() : 0;
                if (stockActual > 0) {
                    p.setStock(Math.max(0, stockActual - cant));
                    productoService.save(p);
                }
                double sub = (p.getPrecio() != null ? p.getPrecio() : 0.0) * cant;
                total += sub;
                totalItems += cant;
                resumen.append(p.getNombre()).append(" x").append(cant).append(", ");
            }
        }

        String pedidoId = "PED-" + java.util.UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        com.clinicaapp.model.Usuario usuario = usuarioRepository.findByEmail(email);
        if (usuario != null) {
            notificacionRepository.save(new com.clinicaapp.model.Notificacion(
                    usuario.getId(),
                    "Pedido Confirmado (" + pedidoId + ")",
                    "Tu pedido de " + totalItems + " producto(s) por $" + Math.round(total) + " ha sido registrado para: " + direccion,
                    "/usuario/dashboard"
            ));
        }

        return ResponseEntity.ok(java.util.Map.of(
                "success", true,
                "pedidoId", pedidoId,
                "total", total,
                "totalItems", totalItems,
                "resumen", resumen.toString()
        ));
    }
}
