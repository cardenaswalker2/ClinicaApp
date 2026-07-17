package com.clinicaapp.controller;

import com.clinicaapp.dto.CitaDisplayDTO;
import com.clinicaapp.dto.RegistroClinicaDTO;
import com.clinicaapp.dto.VisitaDTO;
import com.clinicaapp.dto.UsuarioRegistroDTO;
import com.clinicaapp.model.enums.Role;
import com.clinicaapp.model.Cita;
import com.clinicaapp.model.Clinica;
import com.clinicaapp.model.Mascota;
import com.clinicaapp.model.Servicio;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.model.Visita;
import com.clinicaapp.model.enums.EstadoClinica;
import com.clinicaapp.model.Producto;
import com.clinicaapp.model.ExamenLaboratorio;
import com.clinicaapp.repository.ClinicaRepository;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.repository.VisitaRepository;
import com.clinicaapp.repository.MascotaRepository;
import com.clinicaapp.repository.CitaRepository;
import com.clinicaapp.repository.ProductoRepository;
import com.clinicaapp.repository.ExamenLaboratorioRepository;
import com.clinicaapp.service.ICitaService;
import com.clinicaapp.service.IMascotaService;
import com.clinicaapp.service.IVisitaService;
import com.clinicaapp.service.IPdfService;
import com.clinicaapp.service.IClinicaService;
import com.clinicaapp.service.IUsuarioService;
import com.clinicaapp.service.IServicioService;
import com.clinicaapp.service.IEmailService;
import com.clinicaapp.service.INotificacionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.multipart.MultipartFile;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.ByteArrayInputStream;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.TextStyle;
import java.util.*;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/clinica")
public class ClinicaController {

    private static final Logger log = LoggerFactory.getLogger(ClinicaController.class);

    @Autowired
    private ClinicaRepository clinicaRepository;
    @Autowired
    private UsuarioRepository usuarioRepository;
    @Autowired
    private VisitaRepository visitaRepository;
    @Autowired
    private MascotaRepository mascotaRepository;
    @Autowired
    private CitaRepository citaRepository;
    @Autowired
    private ProductoRepository productoRepository;
    @Autowired
    private ExamenLaboratorioRepository examenLaboratorioRepository;
    @Autowired
    private ICitaService citaService;
    @Autowired
    private IMascotaService mascotaService;
    @Autowired
    private IVisitaService visitaService;
    @Autowired
    private IPdfService pdfService;
    @Autowired
    private IClinicaService clinicaService;
    @Autowired
    private IUsuarioService usuarioService;
    @Autowired
    private IServicioService servicioService;
    @Autowired
    private IEmailService emailService;
    @Autowired
    private INotificacionService notificacionService;

    // --- MÉTODO AUXILIAR PARA OBTENER LA CLÍNICA CORRECTA ---
    private Clinica obtenerClinicaLogueada(Authentication auth) {
        if (auth == null)
            return null;
        Usuario usuario = usuarioRepository.findByEmail(auth.getName());
        if (usuario == null)
            return null;
        if (usuario.getClinicaId() != null && !usuario.getClinicaId().isEmpty()) {
            return clinicaRepository.findById(usuario.getClinicaId()).orElse(null);
        }
        return clinicaRepository.findByUsuarioAdminId(usuario.getId());
    }

    // 1. DASHBOARD
    @GetMapping("/dashboard")
    public String dashboard(Authentication authentication, Model model) {
        Clinica clinica = obtenerClinicaLogueada(authentication);
        if (clinica == null)
            return "redirect:/login?error=no_clinica";

        if (clinica.getEstado() != EstadoClinica.APROBADA) {
            return "redirect:/login?error=pendiente";
        }

        List<CitaDisplayDTO> todas = citaService.getCitasByClinicaEmail(clinica.getEmail());
        List<CitaDisplayDTO> salaDeEspera = todas.stream()
                .filter(c -> "En Espera".equalsIgnoreCase(c.getEstado()))
                .collect(Collectors.toList());

        double ingresosTotales = todas.stream()
                .filter(c -> "PAGADO".equalsIgnoreCase(c.getEstadoPago()))
                .mapToDouble(c -> c.getCosto() != null ? c.getCosto() : 0.0)
                .sum();

        model.addAttribute("clinica", clinica);
        model.addAttribute("salaDeEspera", salaDeEspera);
        model.addAttribute("totalCitas", todas.size());
        model.addAttribute("totalIngresos", ingresosTotales);

        // --- 1. DATOS PARA GRÁFICO DE ESTADOS DE CITAS ---
        Map<String, Long> statsEstados = todas.stream()
                .filter(c -> c.getEstado() != null)
                .collect(Collectors.groupingBy(c -> {
                    String est = c.getEstado();
                    if (est.contains("Pendiente")) return "Pendiente";
                    return est;
                }, Collectors.counting()));
        
        List<String> labelsEstados = Arrays.asList("En Espera", "Pendiente", "Confirmada", "Completada", "Cancelada");
        List<Long> dataEstados = labelsEstados.stream()
                .map(e -> statsEstados.getOrDefault(e, 0L))
                .collect(Collectors.toList());
        
        model.addAttribute("labelsEstadosJson", toJson(labelsEstados));
        model.addAttribute("dataEstadosJson", toJson(dataEstados));

        // --- 2. DATOS PARA GRÁFICO DE INGRESOS SEMANALES ---
        List<String> diasSemana = new ArrayList<>();
        List<Double> ingresosSemana = new ArrayList<>();
        LocalDate hoy = LocalDate.now();
        
        for (int i = 6; i >= 0; i--) {
            LocalDate d = hoy.minusDays(i);
            diasSemana.add(d.getDayOfWeek().getDisplayName(TextStyle.SHORT, new Locale("es", "ES")));
            
            double sum = todas.stream()
                .filter(c -> c.getFechaHoraIso() != null && LocalDateTime.parse(c.getFechaHoraIso()).toLocalDate().equals(d))
                .filter(c -> "PAGADO".equalsIgnoreCase(c.getEstadoPago()))
                .mapToDouble(c -> c.getCosto() != null ? c.getCosto() : 0.0)
                .sum();
            ingresosSemana.add(sum);
        }
        
        model.addAttribute("labelsIngresosJson", toJson(diasSemana));
        model.addAttribute("dataIngresosJson", toJson(ingresosSemana));

        // --- 3. DATOS PARA SERVICIOS POPULARES ---
        Map<String, Long> countServicios = todas.stream()
                .filter(c -> c.getNombreServicio() != null)
                .collect(Collectors.groupingBy(CitaDisplayDTO::getNombreServicio, Collectors.counting()));
        
        List<Map.Entry<String, Long>> topServicios = countServicios.entrySet().stream()
                .sorted(Map.Entry.comparingByValue(Comparator.reverseOrder()))
                .limit(5)
                .collect(Collectors.toList());

        model.addAttribute("labelsTopServiciosJson", toJson(topServicios.stream().map(Map.Entry::getKey).collect(Collectors.toList())));
        model.addAttribute("dataTopServiciosJson", toJson(topServicios.stream().map(Map.Entry::getValue).collect(Collectors.toList())));

        // KPIs adicionales para SaaS
        long vetsActivos = usuarioRepository.findByClinicaIdAndRole(clinica.getId(), Role.ROLE_VETERINARIO).stream()
                .filter(u -> "Activo".equalsIgnoreCase(u.getEstadoEmpleado())).count();
        long receptionists = usuarioRepository.findByClinicaIdAndRole(clinica.getId(), Role.ROLE_RECEPCIONISTA).stream()
                .filter(u -> "Activo".equalsIgnoreCase(u.getEstadoEmpleado())).count();
        
        long totalMascotas = todas.stream()
                .map(CitaDisplayDTO::getMascotaId)
                .filter(Objects::nonNull)
                .distinct()
                .count();
        long totalClientes = todas.stream()
                .map(CitaDisplayDTO::getEmailUsuario)
                .filter(Objects::nonNull)
                .distinct()
                .count();

        // Productos con bajo stock
        List<Producto> bajoStock = productoRepository.findByClinicaId(clinica.getId()).stream()
                .filter(p -> p.getStock() <= (p.getStockMinimo() != null ? p.getStockMinimo() : 5))
                .collect(Collectors.toList());

        // Citas de hoy
        LocalDate today = LocalDate.now();
        long citasHoy = todas.stream()
                .filter(c -> c.getFechaHoraIso() != null && LocalDateTime.parse(c.getFechaHoraIso()).toLocalDate().equals(today))
                .count();

        // Ingresos de hoy
        double ingresosHoy = todas.stream()
                .filter(c -> c.getFechaHoraIso() != null && LocalDateTime.parse(c.getFechaHoraIso()).toLocalDate().equals(today))
                .filter(c -> "PAGADO".equalsIgnoreCase(c.getEstadoPago()))
                .mapToDouble(c -> c.getCosto() != null ? c.getCosto() : 0.0)
                .sum();

        model.addAttribute("vetsActivos", vetsActivos);
        model.addAttribute("receptionists", receptionists);
        model.addAttribute("totalMascotasSede", totalMascotas);
        model.addAttribute("totalClientesSede", totalClientes);
        model.addAttribute("bajoStock", bajoStock);
        model.addAttribute("citasHoy", citasHoy);
        model.addAttribute("ingresosHoy", ingresosHoy);

        return "clinica/dashboard";
    }

    private String toJson(Object object) {
        try {
            return new ObjectMapper().writeValueAsString(object);
        } catch (JsonProcessingException e) {
            return "[]";
        }
    }

    // 2. LISTADO DE CITAS
    @GetMapping("/citas")
    public String verCitas(Authentication authentication, Model model) {
        Clinica clinica = obtenerClinicaLogueada(authentication);
        if (clinica == null)
            return "redirect:/login";
        model.addAttribute("citas", citaService.getCitasByClinicaEmail(clinica.getEmail()));
        model.addAttribute("clinica", clinica);
        
        List<Usuario> veterinarios = usuarioService.findByClinicaIdAndRole(clinica.getId(), Role.ROLE_VETERINARIO);
        List<Usuario> estilistas = usuarioService.findByClinicaIdAndRole(clinica.getId(), Role.ROLE_ESTILISTA);
        model.addAttribute("veterinarios", veterinarios);
        model.addAttribute("estilistas", estilistas);
        
        return "clinica/citas";
    }

    // 3. REGISTRAR ATENCIÓN MÉDICA (FORMULARIO)
    @GetMapping("/atender/{citaId}")
    public String formAtenderPaciente(@PathVariable String citaId, Model model, Authentication auth) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        Optional<Cita> citaOpt = citaService.findById(citaId);

        if (citaOpt.isEmpty() || clinica == null)
            return "redirect:/clinica/citas";

        Cita cita = citaOpt.get();
        VisitaDTO visitaDTO = new VisitaDTO();
        visitaDTO.setCitaId(cita.getId());
        visitaDTO.setMascotaId(cita.getMascotaId());
        visitaDTO.setClinicaId(clinica.getId());
        visitaDTO.setFechaVisita(LocalDateTime.now());
        visitaDTO.setCostoTotal(0.0);

        model.addAttribute("nombreMascota", mascotaService.findById(cita.getMascotaId())
                .map(Mascota::getNombre).orElse("Paciente"));

        List<String> nombresServicios = new ArrayList<>();
        if (cita.getServiciosIds() != null) {
            for (String sId : cita.getServiciosIds()) {
                servicioService.findById(sId).ifPresent(s -> nombresServicios.add(s.getNombre()));
            }
        }
        model.addAttribute("serviciosSolicitados", String.join(", ", nombresServicios));

        model.addAttribute("visitaDTO", visitaDTO);
        model.addAttribute("clinica", clinica);
        return "clinica/form_visita";
    }

    // 4. GUARDAR ATENCIÓN Y ENVIAR RECETA
    @PostMapping("/visitas/guardar")
    public String guardarAtencion(@ModelAttribute VisitaDTO visitaDTO, Authentication auth) {
        // 1. Guardamos la visita en la BD
        Visita visitaSaved = visitaService.save(visitaDTO);
        // 2. Cerramos la cita
        citaService.completarCita(visitaDTO.getCitaId());

        try {
            Clinica clinica = obtenerClinicaLogueada(auth);
            Mascota mascota = mascotaService.findById(visitaDTO.getMascotaId()).orElseThrow();
            Usuario dueno = usuarioService.findById(mascota.getPropietarioId()).orElseThrow();

            // 2.1 Generar Notificación Interna
            String msgNotif = "Se ha completado la atención de " + mascota.getNombre() + ".";
            if (visitaSaved.getFechaProximaCita() != null) {
                msgNotif += " Tu próxima cita es el " + visitaSaved.getFechaProximaCita().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) + ".";
            }
            notificacionService.crearNotificacion(
                dueno.getId(), 
                "¡Consulta Médica Finalizada!", 
                msgNotif, 
                "/usuario/historial/" + mascota.getId()
            );

            // 3. Generamos el PDF para adjuntarlo
            Map<String, Object> data = new HashMap<>();
            data.put("visita", visitaSaved);
            data.put("clinica", clinica);
            data.put("mascota", mascota);
            data.put("dueno", dueno);

            ByteArrayInputStream bis = pdfService.generatePdfFromTemplate("clinica/pdf_receta", data);
            byte[] pdfBytes = bis.readAllBytes();

            // --- DISEÑO DE EMAIL MÉDICO PREMIUM ---
            String subject = "📄 Receta Médica: " + mascota.getNombre() + " - " + clinica.getNombre();

            String htmlBody = String.format(
                    """
                            <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f1f5f9; padding: 40px 0;">
                                <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 20px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.1);">

                                    <!-- Encabezado con Gradiente Azul Médico -->
                                    <div style="background: linear-gradient(135deg, #0284c7 0%%, #0369a1 100%%); padding: 35px 20px; text-align: center; color: white;">
                                        <div style="background: rgba(255,255,255,0.2); width: 60px; height: 60px; border-radius: 50%%; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 15px;">
                                            <span style="font-size: 30px;">🩺</span>
                                        </div>
                                        <h1 style="margin: 0; font-size: 24px; font-weight: 700; letter-spacing: -0.5px;">Resumen de Consulta Médica</h1>
                                        <p style="margin: 5px 0 0; opacity: 0.8; font-size: 14px;">%s</p>
                                    </div>

                                    <div style="padding: 40px; color: #334155;">
                                        <p style="font-size: 16px;">Hola <strong>%s</strong>,</p>
                                        <p style="line-height: 1.6; font-size: 15px; color: #475569;">
                                            Esperamos que <strong>%s</strong> se encuentre mucho mejor. Te enviamos los detalles de la atención recibida el día de hoy y la receta médica digital adjunta a este correo.
                                        </p>

                                        <!-- Caja de Resumen de la Mascota -->
                                        <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; margin: 25px 0;">
                                            <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                                <span style="color: #64748b; font-size: 13px; font-weight: 600; text-transform: uppercase;">Paciente:</span>
                                                <strong style="color: #0f172a;">%s</strong>
                                            </div>
                                            <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                                <span style="color: #64748b; font-size: 13px; font-weight: 600; text-transform: uppercase;">Servicio:</span>
                                                <strong style="color: #0f172a;">Consulta Veterinaria</strong>
                                            </div>
                                            <div style="border-top: 1px solid #e2e8f0; margin-top: 15px; padding-top: 15px;">
                                                <p style="margin: 0; color: #64748b; font-size: 13px; font-weight: 600;">DIAGNÓSTICO:</p>
                                                <p style="margin: 5px 0 0; color: #334155; font-style: italic;">"%s"</p>
                                            </div>
                                        </div>

                                        <div style="text-align: center; margin: 35px 0;">
                                            <p style="font-size: 14px; color: #64748b; margin-bottom: 15px;">Para ver las instrucciones detalladas y dosis, abre el PDF adjunto.</p>
                                            <div style="background: #f0f9ff; color: #0369a1; display: inline-block; padding: 10px 20px; border-radius: 8px; font-weight: 700; border: 1px dashed #0369a1;">
                                                📎 Archivo adjunto: Receta_%s.pdf
                                            </div>
                                        </div>

                                        <p style="font-size: 14px; line-height: 1.6; color: #64748b; text-align: center;">
                                            Si tienes dudas sobre el tratamiento, comunícate con nosotros al <br>
                                            <strong style="color: #0f172a;">%s</strong>
                                        </p>
                                    </div>

                                    <!-- Footer -->
                                    <div style="background-color: #f8fafc; padding: 25px; text-align: center; border-top: 1px solid #e2e8f0;">
                                        <p style="margin: 0; font-size: 12px; color: #94a3b8;">
                                            Este es un documento médico oficial generado por ClínicaApp.<br>
                                            Consérvalo para el historial de tu mascota.
                                        </p>
                                    </div>
                                </div>
                            </div>
                            """,
                    clinica.getNombre(),
                    dueno.getNombre(),
                    mascota.getNombre(),
                    mascota.getNombre(),
                    visitaSaved.getDiagnostico(), // Asegúrate que tu modelo Visita tenga getDiagnostico()
                    mascota.getNombre(),
                    clinica.getTelefono());

            // 4. Enviamos el correo con el diseño y el adjunto
            emailService.sendMessageWithAttachment(
                    dueno.getEmail(),
                    subject,
                    htmlBody,
                    "Receta_" + mascota.getNombre() + ".pdf",
                    pdfBytes);

            log.info("✅ Receta Premium enviada con éxito a: {}", dueno.getEmail());

        } catch (Exception e) {
            log.error("❌ Error al procesar envío de receta: {}", e.getMessage());
        }
        return "redirect:/clinica/citas?success=atendida";
    }

    // 5. ACCIONES DE CITAS
    @PostMapping("/citas/confirmar/{id}")
    public String confirmarCita(@PathVariable String id) {
        citaService.confirmarCita(id);
        return "redirect:/clinica/citas?success=confirmada";
    }

    @PostMapping("/citas/cancelar/{id}")
    public String cancelarCita(@PathVariable String id) {
        citaService.cancelarCita(id);
        return "redirect:/clinica/citas?success=cancelada";
    }

    // 6. PERFIL DE SEDE
    @GetMapping("/perfil")
    public String mostrarPerfil(Authentication authentication, Model model) {
        Clinica clinica = obtenerClinicaLogueada(authentication);
        if (clinica == null)
            return "redirect:/login";
        model.addAttribute("clinica", clinica);
        return "clinica/perfil";
    }

    @PostMapping("/perfil/actualizar")
    public String actualizarPerfil(@ModelAttribute Clinica clinicaEditada, Authentication authentication) {
        Clinica clinicaOriginal = obtenerClinicaLogueada(authentication);
        if (clinicaOriginal != null) {
            clinicaOriginal.setNombre(clinicaEditada.getNombre());
            clinicaOriginal.setDireccion(clinicaEditada.getDireccion());
            clinicaOriginal.setTelefono(clinicaEditada.getTelefono());
            clinicaOriginal.setDescripcion(clinicaEditada.getDescripcion());
            clinicaRepository.save(clinicaOriginal);
        }
        return "redirect:/clinica/perfil?success";
    }

    // 7. HISTORIAL DE MASCOTA
    @GetMapping("/mascota/{mascotaId}/historial")
    public String verHistorialMascota(@PathVariable String mascotaId, Model model, Authentication auth) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        Optional<Mascota> mascotaOpt = mascotaService.findById(mascotaId);
        if (mascotaOpt.isEmpty() || clinica == null)
            return "redirect:/clinica/citas?error";

        model.addAttribute("mascota", mascotaOpt.get());
        model.addAttribute("historial", visitaService.getHistorialByMascota(mascotaId));
        model.addAttribute("clinica", clinica);
        return "clinica/historial_mascota";
    }

    // 8. DESCARGAR RECETA PDF
    @GetMapping("/descargar-receta/{visitaId}")
    public ResponseEntity<InputStreamResource> descargarReceta(@PathVariable String visitaId, Authentication auth) {
        Optional<Visita> visitaOpt = visitaService.findById(visitaId);
        Clinica clinica = obtenerClinicaLogueada(auth);

        if (visitaOpt.isEmpty() || clinica == null)
            return ResponseEntity.notFound().build();

        Visita visita = visitaOpt.get();
        Mascota mascota = mascotaService.findById(visita.getMascotaId()).orElse(new Mascota());
        Usuario dueno = usuarioService.findById(mascota.getPropietarioId()).orElse(new Usuario());

        Map<String, Object> data = new HashMap<>();
        data.put("visita", visita);
        data.put("clinica", clinica);
        data.put("mascota", mascota);
        data.put("dueno", dueno);

        ByteArrayInputStream bis = pdfService.generatePdfFromTemplate("clinica/pdf_receta", data);
        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "inline; filename=receta_" + mascota.getNombre() + ".pdf");

        return ResponseEntity.ok().headers(headers).contentType(MediaType.APPLICATION_PDF)
                .body(new InputStreamResource(bis));
    }

    // 9. GESTIÓN DE SERVICIOS Y PRECIOS
    @GetMapping("/mis-servicios")
    public String gestionarServicios(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String search,
            Authentication auth, Model model) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";

        Pageable pageable = PageRequest.of(page, size);
        Page<Servicio> serviciosPage;

        if (search != null && !search.trim().isEmpty()) {
            serviciosPage = servicioService.findByNombre(search, pageable);
        } else {
            serviciosPage = servicioService.findAll(pageable);
        }

        model.addAttribute("clinica", clinica);
        model.addAttribute("serviciosPage", serviciosPage);
        model.addAttribute("serviciosMaestros", serviciosPage.getContent());
        model.addAttribute("misPrecios", clinica.getPreciosServicios());
        model.addAttribute("currentPage", page);
        model.addAttribute("search", search);

        return "clinica/gestion_servicios";
    }

    @PostMapping("/mis-servicios/guardar")
    public String guardarServicios(
            @RequestParam Map<String, String> allParams,
            @RequestParam(value = "displayedIds", required = false) List<String> displayedIds,
            Authentication auth) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";

        final Map<String, Double> preciosActuales = (clinica.getPreciosServicios() != null)
                ? clinica.getPreciosServicios()
                : new HashMap<>();

        // Si tenemos la lista de IDs que se mostraron en esta página
        if (displayedIds != null) {
            for (String sId : displayedIds) {
                String ofreceKey = "ofrece_" + sId;
                String precioKey = "precio_" + sId;

                // Si el checkbox de "ofrece" está marcado
                if (allParams.containsKey(ofreceKey)) {
                    String precioStr = allParams.get(precioKey);
                    if (precioStr != null && !precioStr.isEmpty()) {
                        preciosActuales.put(sId, Double.parseDouble(precioStr));
                    }
                } else {
                    // Si no está marcado, lo quitamos de los servicios ofrecidos por esta clínica
                    preciosActuales.remove(sId);
                }
            }
        } else {
            // Fallback: lógica antigua si no hay displayedIds (por seguridad)
            allParams.forEach((key, value) -> {
                if (key.startsWith("precio_") && !value.isEmpty()) {
                    String sId = key.replace("precio_", "");
                    if (allParams.containsKey("ofrece_" + sId)) {
                        preciosActuales.put(sId, Double.parseDouble(value));
                    }
                }
            });
        }

        clinica.setPreciosServicios(preciosActuales);
        clinica.setServiciosOfrecidos(new ArrayList<>(preciosActuales.keySet()));
        clinicaRepository.save(clinica);

        // Redirigir a la misma página que estaba (si podemos obtenerla de allParams o
        // similar)
        String page = allParams.getOrDefault("page", "0");
        return "redirect:/clinica/mis-servicios?success&page=" + page;
    }

    // 10. REPORTE DE VENTAS
    @GetMapping("/reporte-ventas")
    public String reporteVentas(Authentication authentication, Model model) {
        Clinica clinica = obtenerClinicaLogueada(authentication);
        if (clinica == null)
            return "redirect:/login";

        List<CitaDisplayDTO> ventas = citaService.getCitasByClinicaEmail(clinica.getEmail()).stream()
                .filter(c -> "PAGADO".equalsIgnoreCase(c.getEstadoPago()))
                .collect(Collectors.toList());

        double totalRecaudado = ventas.stream().mapToDouble(v -> v.getCosto() != null ? v.getCosto() : 0.0).sum();

        model.addAttribute("clinica", clinica);
        model.addAttribute("ventas", ventas);
        model.addAttribute("totalRecaudado", totalRecaudado);
        model.addAttribute("ticketPromedio", ventas.isEmpty() ? 0.0 : totalRecaudado / ventas.size());

        return "clinica/reporte_ventas";
    }

    // 11. HORARIO LABORAL
    @GetMapping("/horario")
    public String mostrarHorario(Authentication auth, Model model) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";
        model.addAttribute("clinica", clinica);
        return "clinica/horario";
    }

    @PostMapping("/horario/guardar")
    public String guardarHorario(@RequestParam String horaApertura, @RequestParam String horaCierre,
            @RequestParam int duracionTurnoMinutos, Authentication auth) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica != null) {
            clinica.setHoraApertura(horaApertura);
            clinica.setHoraCierre(horaCierre);
            clinica.setDuracionTurnoMinutos(duracionTurnoMinutos);
            clinicaRepository.save(clinica);
        }
        return "redirect:/clinica/dashboard?horarioActualizado";
    }

    // 12. REGISTRO PÚBLICO DE CLÍNICA
    @GetMapping("/registrar-clinica")
    public String mostrarFormularioRegistro(Model model) {
        model.addAttribute("registroDto", new RegistroClinicaDTO());
        return "registro_clinica";
    }

    @PostMapping("/registrar-clinica")
    public String procesarRegistroClinica(@ModelAttribute("registroDto") RegistroClinicaDTO registroDto,
                                          @RequestParam(value = "imagenFile", required = false) MultipartFile imagenFile,
                                          RedirectAttributes flash) {
        try {
            clinicaService.registrarSolicitudClinica(registroDto, imagenFile);
            return "registro_exitoso";
        } catch (Exception e) {
            flash.addFlashAttribute("error", "Hubo un error: " + e.getMessage());
            return "redirect:/clinica/registrar-clinica";
        }
    }

    // 13. GESTIÓN DE PERSONAL DE LA CLÍNICA (SAAS ENTERPRISE)
    @GetMapping("/personal")
    public String listarPersonal(Authentication auth, Model model) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";
        
        List<Usuario> personal = usuarioService.findByClinicaId(clinica.getId());
        model.addAttribute("personal", personal);
        model.addAttribute("clinica", clinica);
        return "clinica/empleados";
    }

    @GetMapping("/personal/nuevo")
    public String nuevoEmpleado(Authentication auth, Model model) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";

        UsuarioRegistroDTO empleadoDto = new UsuarioRegistroDTO();
        model.addAttribute("empleadoDto", empleadoDto);
        model.addAttribute("rolesDisponibles", List.of(
            Role.ROLE_RECEPCIONISTA,
            Role.ROLE_VETERINARIO,
            Role.ROLE_AUXILIAR,
            Role.ROLE_ESTILISTA,
            Role.ROLE_ADMIN_INTERNO
        ));
        model.addAttribute("diasSemana", List.of("LUNES", "MARTES", "MIERCOLES", "JUEVES", "VIERNES", "SABADO", "DOMINGO"));
        model.addAttribute("clinica", clinica);
        return "clinica/form_empleado";
    }

    @GetMapping("/personal/editar/{id}")
    public String editarEmpleado(@PathVariable String id, Authentication auth, Model model, RedirectAttributes redirectAttributes) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";

        Optional<Usuario> empleadoOpt = usuarioService.findById(id);
        if (empleadoOpt.isEmpty() || !clinica.getId().equals(empleadoOpt.get().getClinicaId())) {
            redirectAttributes.addFlashAttribute("mensajeError", "Empleado no encontrado o no pertenece a esta clínica.");
            return "redirect:/clinica/personal";
        }

        Usuario empleado = empleadoOpt.get();
        UsuarioRegistroDTO empleadoDto = new UsuarioRegistroDTO();
        empleadoDto.setId(empleado.getId());
        empleadoDto.setNombre(empleado.getNombre());
        empleadoDto.setApellido(empleado.getApellido());
        empleadoDto.setEmail(empleado.getEmail());
        empleadoDto.setTelefono(empleado.getTelefono());
        empleadoDto.setRole(empleado.getRole());

        model.addAttribute("empleadoDto", empleadoDto);
        model.addAttribute("empleado", empleado);
        model.addAttribute("rolesDisponibles", List.of(
            Role.ROLE_RECEPCIONISTA,
            Role.ROLE_VETERINARIO,
            Role.ROLE_AUXILIAR,
            Role.ROLE_ESTILISTA,
            Role.ROLE_ADMIN_INTERNO
        ));
        model.addAttribute("diasSemana", List.of("LUNES", "MARTES", "MIERCOLES", "JUEVES", "VIERNES", "SABADO", "DOMINGO"));
        model.addAttribute("clinica", clinica);
        return "clinica/form_empleado";
    }

    @PostMapping("/personal/guardar")
    public String guardarEmpleado(
            @ModelAttribute("empleadoDto") UsuarioRegistroDTO empleadoDto,
            @RequestParam(required = false) List<String> diasLaborales,
            @RequestParam(required = false) String horaInicioTrabajo,
            @RequestParam(required = false) String horaFinTrabajo,
            @RequestParam(required = false) String vacacionesStr,
            @RequestParam(value = "fotoFile", required = false) MultipartFile fotoFile,
            @RequestParam(required = false) String documento,
            @RequestParam(required = false) String direccion,
            @RequestParam(required = false) String cargo,
            @RequestParam(required = false) String especialidad,
            @RequestParam(required = false) String nLicencia,
            @RequestParam(required = false) String fechaIngreso,
            @RequestParam(required = false) String estadoEmpleado,
            @RequestParam(required = false) String biografia,
            @RequestParam(required = false) String observacionesInternas,
            @RequestParam(required = false) String horaInicioDescanso,
            @RequestParam(required = false) String horaFinDescanso,
            @RequestParam(required = false) String consultoriosStr,
            @RequestParam(required = false) Double calificacion,
            @RequestParam(required = false) Integer experiencia,
            Authentication auth,
            Model model,
            RedirectAttributes redirectAttributes) {
        
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";

        try {
            Usuario empleado;
            if (empleadoDto.getId() != null && !empleadoDto.getId().isEmpty()) {
                Optional<Usuario> empOpt = usuarioService.findById(empleadoDto.getId());
                if (empOpt.isEmpty() || !clinica.getId().equals(empOpt.get().getClinicaId())) {
                    redirectAttributes.addFlashAttribute("mensajeError", "Empleado no autorizado.");
                    return "redirect:/clinica/personal";
                }
                empleado = usuarioService.update(empleadoDto.getId(), empleadoDto, empleadoDto.getRole());
            } else {
                if (usuarioRepository.findByEmail(empleadoDto.getEmail()) != null) {
                    model.addAttribute("mensajeError", "El correo ingresado ya existe.");
                    model.addAttribute("rolesDisponibles", List.of(
                        Role.ROLE_RECEPCIONISTA,
                        Role.ROLE_VETERINARIO,
                        Role.ROLE_AUXILIAR,
                        Role.ROLE_ESTILISTA,
                        Role.ROLE_ADMIN_INTERNO
                    ));
                    model.addAttribute("diasSemana", List.of("LUNES", "MARTES", "MIERCOLES", "JUEVES", "VIERNES", "SABADO", "DOMINGO"));
                    model.addAttribute("clinica", clinica);
                    return "clinica/form_empleado";
                }
                if (empleadoDto.getTelefono() != null && !empleadoDto.getTelefono().isEmpty()) {
                    if (usuarioRepository.findByTelefono(empleadoDto.getTelefono()) != null) {
                        model.addAttribute("mensajeError", "El teléfono ingresado ya existe.");
                        model.addAttribute("rolesDisponibles", List.of(
                            Role.ROLE_RECEPCIONISTA,
                            Role.ROLE_VETERINARIO,
                            Role.ROLE_AUXILIAR,
                            Role.ROLE_ESTILISTA,
                            Role.ROLE_ADMIN_INTERNO
                        ));
                        model.addAttribute("diasSemana", List.of("LUNES", "MARTES", "MIERCOLES", "JUEVES", "VIERNES", "SABADO", "DOMINGO"));
                        model.addAttribute("clinica", clinica);
                        return "clinica/form_empleado";
                    }
                }
                empleado = usuarioService.createUsuarioWithRole(empleadoDto, empleadoDto.getRole());
                empleado.setClinicaId(clinica.getId());
            }

            if (diasLaborales != null) {
                empleado.setDiasLaborales(diasLaborales);
            }
            if (horaInicioTrabajo != null && !horaInicioTrabajo.isEmpty()) {
                empleado.setHoraInicioTrabajo(horaInicioTrabajo);
            }
            if (horaFinTrabajo != null && !horaFinTrabajo.isEmpty()) {
                empleado.setHoraFinTrabajo(horaFinTrabajo);
            }
            if (vacacionesStr != null) {
                List<String> vacs = Arrays.stream(vacacionesStr.split(","))
                        .map(String::trim)
                        .filter(s -> !s.isEmpty())
                        .collect(Collectors.toList());
                empleado.setDiasLibresVacaciones(vacs);
            }

            if (fotoFile != null && !fotoFile.isEmpty()) {
                String uploadDir = "uploads";
                java.nio.file.Path uploadPath = java.nio.file.Paths.get(uploadDir);
                if (!java.nio.file.Files.exists(uploadPath)) {
                    java.nio.file.Files.createDirectories(uploadPath);
                }
                String fileName = java.util.UUID.randomUUID().toString() + "_" + fotoFile.getOriginalFilename();
                java.nio.file.Path filePath = uploadPath.resolve(fileName);
                java.nio.file.Files.copy(fotoFile.getInputStream(), filePath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                empleado.setFotoPerfilUrl("/uploads/" + fileName);
            }

            if (documento != null) empleado.setDocumento(documento);
            if (direccion != null) empleado.setDireccion(direccion);
            if (cargo != null) empleado.setCargo(cargo);
            if (especialidad != null) empleado.setEspecialidad(especialidad);
            if (nLicencia != null) empleado.setnLicencia(nLicencia);
            if (fechaIngreso != null) empleado.setFechaIngreso(fechaIngreso);
            if (estadoEmpleado != null) empleado.setEstadoEmpleado(estadoEmpleado);
            if (biografia != null) empleado.setBiografia(biografia);
            if (observacionesInternas != null) empleado.setObservacionesInternas(observacionesInternas);
            if (horaInicioDescanso != null) empleado.setHoraInicioDescanso(horaInicioDescanso);
            if (horaFinDescanso != null) empleado.setHoraFinDescanso(horaFinDescanso);
            if (calificacion != null) empleado.setCalificacion(calificacion);
            if (experiencia != null) empleado.setExperiencia(experiencia);

            if (consultoriosStr != null) {
                List<String> cons = Arrays.stream(consultoriosStr.split(","))
                        .map(String::trim)
                        .filter(s -> !s.isEmpty())
                        .collect(Collectors.toList());
                empleado.setConsultoriosDisponibles(cons);
            }

            usuarioRepository.save(empleado);
            redirectAttributes.addFlashAttribute("mensajeExito", "Empleado guardado correctamente.");

        } catch (Exception e) {
            log.error("Error al guardar empleado: {}", e.getMessage());
            redirectAttributes.addFlashAttribute("mensajeError", "Error al guardar: " + e.getMessage());
        }

        return "redirect:/clinica/personal";
    }

    @GetMapping("/personal/perfil/{id}")
    public String perfilEmpleado(@PathVariable String id, Authentication auth, Model model, RedirectAttributes redirectAttributes) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";

        Optional<Usuario> empleadoOpt = usuarioService.findById(id);
        if (empleadoOpt.isEmpty() || !clinica.getId().equals(empleadoOpt.get().getClinicaId())) {
            redirectAttributes.addFlashAttribute("mensajeError", "Empleado no encontrado o no autorizado.");
            return "redirect:/clinica/personal";
        }

        Usuario empleado = empleadoOpt.get();
        List<Cita> citas = citaRepository.findByClinicaId(clinica.getId()).stream()
                .filter(c -> id.equals(c.getVeterinarioId()))
                .sorted(Comparator.comparing(Cita::getFechaHora))
                .collect(Collectors.toList());

        model.addAttribute("empleado", empleado);
        model.addAttribute("citas", citas);
        model.addAttribute("clinica", clinica);
        return "clinica/perfil_veterinario";
    }

    @PostMapping("/personal/toggle-activo/{id}")
    public String toggleActivoEmpleado(@PathVariable String id, Authentication auth, RedirectAttributes redirectAttributes) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";

        Optional<Usuario> empleadoOpt = usuarioService.findById(id);
        if (empleadoOpt.isEmpty() || !clinica.getId().equals(empleadoOpt.get().getClinicaId())) {
            redirectAttributes.addFlashAttribute("mensajeError", "Empleado no encontrado.");
            return "redirect:/clinica/personal";
        }

        Usuario empleado = empleadoOpt.get();
        empleado.setActivo(!empleado.isActivo());
        usuarioRepository.save(empleado);

        String estado = empleado.isActivo() ? "activado" : "desactivado";
        redirectAttributes.addFlashAttribute("mensajeExito", "Empleado " + estado + " con éxito.");
        return "redirect:/clinica/personal";
    }

    @PostMapping("/personal/eliminar/{id}")
    public String eliminarEmpleado(@PathVariable String id, Authentication auth, RedirectAttributes redirectAttributes) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";

        Optional<Usuario> empleadoOpt = usuarioService.findById(id);
        if (empleadoOpt.isEmpty() || !clinica.getId().equals(empleadoOpt.get().getClinicaId())) {
            redirectAttributes.addFlashAttribute("mensajeError", "Empleado no encontrado.");
            return "redirect:/clinica/personal";
        }

        usuarioService.deleteById(id);
        redirectAttributes.addFlashAttribute("mensajeExito", "Empleado eliminado permanentemente.");
        return "redirect:/clinica/personal";
    }

    // 14. EXPEDIENTE CLÍNICO DE MASCOTAS (SAAS ENTERPRISE)
    @PostMapping("/mascota/{mascotaId}/actualizar-clinico")
    public String actualizarClinico(
            @PathVariable String mascotaId,
            @RequestParam(required = false) String alertasMedicas,
            @RequestParam(required = false) String alergias,
            @RequestParam(required = false) String vacunas,
            @RequestParam(required = false) String desparasitaciones,
            @RequestParam(required = false) String historialCirugias,
            @RequestParam(required = false) Double nuevoPeso,
            Authentication auth,
            RedirectAttributes redirectAttributes) {

        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";

        Optional<Mascota> mascotaOpt = mascotaRepository.findById(mascotaId);
        if (mascotaOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("mensajeError", "Mascota no encontrada.");
            return "redirect:/clinica/citas";
        }

        Mascota mascota = mascotaOpt.get();
        mascota.setAlertasMedicas(alertasMedicas);

        if (alergias != null) {
            List<String> list = Arrays.stream(alergias.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .collect(Collectors.toList());
            mascota.setAlergias(list);
        }
        if (vacunas != null) {
            List<String> list = Arrays.stream(vacunas.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .collect(Collectors.toList());
            mascota.setVacunas(list);
        }
        if (desparasitaciones != null) {
            List<String> list = Arrays.stream(desparasitaciones.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .collect(Collectors.toList());
            mascota.setDesparasitaciones(list);
        }
        if (historialCirugias != null) {
            List<String> list = Arrays.stream(historialCirugias.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .collect(Collectors.toList());
            mascota.setHistorialCirugias(list);
        }

        if (nuevoPeso != null && nuevoPeso > 0) {
            String fechaHoy = LocalDate.now().toString();
            mascota.getPesoHistorico().put(fechaHoy, nuevoPeso);
        }

        mascotaRepository.save(mascota);
        redirectAttributes.addFlashAttribute("mensajeExito", "Historial clínico actualizado correctamente.");
        return "redirect:/clinica/mascota/" + mascotaId + "/historial";
    }

    @PostMapping("/mascota/{mascotaId}/subir-adjunto")
    public String subirAdjuntoClinico(
            @PathVariable String mascotaId,
            @RequestParam("adjuntoFile") MultipartFile adjuntoFile,
            Authentication auth,
            RedirectAttributes redirectAttributes) {

        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";

        Optional<Mascota> mascotaOpt = mascotaRepository.findById(mascotaId);
        if (mascotaOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("mensajeError", "Mascota no encontrada.");
            return "redirect:/clinica/citas";
        }

        Mascota mascota = mascotaOpt.get();

        if (adjuntoFile != null && !adjuntoFile.isEmpty()) {
            try {
                String uploadDir = "uploads";
                java.nio.file.Path uploadPath = java.nio.file.Paths.get(uploadDir);

                if (!java.nio.file.Files.exists(uploadPath)) {
                    java.nio.file.Files.createDirectories(uploadPath);
                }

                String fileName = UUID.randomUUID().toString() + "_" + adjuntoFile.getOriginalFilename();
                java.nio.file.Path filePath = uploadPath.resolve(fileName);

                java.nio.file.Files.copy(adjuntoFile.getInputStream(), filePath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);

                String adjuntoUrl = "/uploads/" + fileName;
                mascota.getAdjuntosClinicos().add(adjuntoUrl);
                mascotaRepository.save(mascota);

                redirectAttributes.addFlashAttribute("mensajeExito", "Archivo adjunto subido correctamente.");
            } catch (Exception e) {
                log.error("Error al subir archivo adjunto: {}", e.getMessage());
                redirectAttributes.addFlashAttribute("mensajeError", "No se pudo subir el archivo: " + e.getMessage());
            }
        } else {
            redirectAttributes.addFlashAttribute("mensajeError", "El archivo está vacío o no fue seleccionado.");
        }

        return "redirect:/clinica/mascota/" + mascotaId + "/historial";
    }

    // 15. REST ENDPOINTS PARA LA AGENDA INTELIGENTE
    @GetMapping("/api/citas-eventos")
    @ResponseBody
    public List<Map<String, Object>> getCitasEventos(Authentication auth) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null) return List.of();
        
        List<CitaDisplayDTO> todas = citaService.getCitasByClinicaEmail(clinica.getEmail());
        
        List<Map<String, Object>> eventos = new ArrayList<>();
        for (CitaDisplayDTO c : todas) {
            Map<String, Object> ev = new HashMap<>();
            ev.put("id", c.getId());
            
            ev.put("title", c.getNombreMascota() + " (" + c.getNombreUsuario() + ")");
            ev.put("start", c.getFechaHoraIso());
            
            if (c.getFechaHoraIso() != null) {
                try {
                    LocalDateTime startDt = LocalDateTime.parse(c.getFechaHoraIso());
                    ev.put("end", startDt.plusMinutes(clinica.getDuracionTurnoMinutos() > 0 ? clinica.getDuracionTurnoMinutos() : 30).toString());
                } catch(Exception ex) {
                    // Ignorar
                }
            }
            
            String color = "#4f46e5";
            if ("En Espera".equalsIgnoreCase(c.getEstado())) color = "#f59e0b";
            else if ("Completada".equalsIgnoreCase(c.getEstado())) color = "#10b981";
            else if ("Cancelada".equalsIgnoreCase(c.getEstado())) color = "#ef4444";
            else if ("Confirmada".equalsIgnoreCase(c.getEstado())) color = "#0ea5e9";
            
            ev.put("backgroundColor", color);
            ev.put("borderColor", color);
            ev.put("textColor", "#ffffff");
            
            ev.put("veterinarioId", c.getVeterinarioId());
            ev.put("consultorioId", c.getConsultorioId());
            ev.put("estilistaId", c.getEstilistaId());
            ev.put("motivo", c.getMotivo());
            ev.put("servicio", c.getNombreServicio());
            eventos.add(ev);
        }
        return eventos;
    }

    @PostMapping("/api/citas-reprogramar")
    @ResponseBody
    public ResponseEntity<?> apiReprogramarCita(
            @RequestParam String id,
            @RequestParam String fechaHora,
            Authentication auth) {
        
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null) {
            return ResponseEntity.status(org.springframework.http.HttpStatus.UNAUTHORIZED).body(Map.of("error", "No autorizado"));
        }

        try {
            Optional<Cita> citaOpt = citaService.findById(id);
            if (citaOpt.isEmpty() || !clinica.getId().equals(citaOpt.get().getClinicaId())) {
                return ResponseEntity.status(org.springframework.http.HttpStatus.BAD_REQUEST).body(Map.of("error", "Cita no encontrada."));
            }

            LocalDateTime nuevaFechaHora = LocalDateTime.parse(fechaHora);
            citaService.reprogramarCita(id, nuevaFechaHora);
            return ResponseEntity.ok(Map.of("status", "success", "mensaje", "Cita reprogramada con éxito."));
        } catch (Exception e) {
            return ResponseEntity.status(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/api/citas-asignar")
    @ResponseBody
    public ResponseEntity<?> apiAsignarRecursos(
            @RequestParam String id,
            @RequestParam(required = false) String veterinarioId,
            @RequestParam(required = false) String consultorioId,
            @RequestParam(required = false) String estilistaId,
            Authentication auth) {

        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null) {
            return ResponseEntity.status(org.springframework.http.HttpStatus.UNAUTHORIZED).body(Map.of("error", "No autorizado"));
        }

        try {
            Optional<Cita> citaOpt = citaService.findById(id);
            if (citaOpt.isEmpty() || !clinica.getId().equals(citaOpt.get().getClinicaId())) {
                return ResponseEntity.status(org.springframework.http.HttpStatus.BAD_REQUEST).body(Map.of("error", "Cita no encontrada."));
            }

            Cita cita = citaOpt.get();
            if (veterinarioId != null) {
                cita.setVeterinarioId(veterinarioId.isEmpty() ? null : veterinarioId);
            }
            if (consultorioId != null) {
                cita.setConsultorioId(consultorioId.isEmpty() ? null : consultorioId);
            }
            if (estilistaId != null) {
                cita.setEstilistaId(estilistaId.isEmpty() ? null : estilistaId);
            }

            citaRepository.save(cita);
            return ResponseEntity.ok(Map.of("status", "success", "mensaje", "Recursos asignados con éxito."));
        } catch (Exception e) {
            return ResponseEntity.status(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", e.getMessage()));
        }
    }

    // 16. GESTIÓN DE INVENTARIO (SAAS ENTERPRISE)
    @GetMapping("/inventario")
    public String verInventario(Authentication auth, Model model) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";

        List<Producto> productos = productoRepository.findByClinicaId(clinica.getId());
        model.addAttribute("productos", productos);
        model.addAttribute("clinica", clinica);
        return "clinica/inventario";
    }

    @PostMapping("/inventario/guardar")
    public String guardarProducto(
            @RequestParam(required = false) String id,
            @RequestParam String nombre,
            @RequestParam String descripcion,
            @RequestParam Double precio,
            @RequestParam Integer stock,
            @RequestParam String categoria,
            @RequestParam(required = false) String lote,
            @RequestParam(required = false) String fechaVencimiento,
            @RequestParam Integer stockMinimo,
            Authentication auth,
            RedirectAttributes redirectAttributes) {

        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";

        Producto producto;
        if (id != null && !id.trim().isEmpty()) {
            producto = productoRepository.findById(id).orElse(new Producto());
        } else {
            producto = new Producto();
        }

        producto.setNombre(nombre);
        producto.setDescripcion(descripcion);
        producto.setPrecio(precio);
        producto.setStock(stock);
        producto.setCategoria(categoria);
        producto.setClinicaId(clinica.getId());
        producto.setLote(lote);
        producto.setFechaVencimiento(fechaVencimiento);
        producto.setStockMinimo(stockMinimo);

        productoRepository.save(producto);
        redirectAttributes.addFlashAttribute("mensajeExito", "Producto guardado en inventario correctamente.");
        return "redirect:/clinica/inventario";
    }

    @PostMapping("/inventario/eliminar/{id}")
    public String eliminarProducto(@PathVariable String id, Authentication auth, RedirectAttributes redirectAttributes) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";

        Optional<Producto> prodOpt = productoRepository.findById(id);
        if (prodOpt.isEmpty() || !clinica.getId().equals(prodOpt.get().getClinicaId())) {
            redirectAttributes.addFlashAttribute("mensajeError", "Producto no encontrado.");
            return "redirect:/clinica/inventario";
        }

        productoRepository.deleteById(id);
        redirectAttributes.addFlashAttribute("mensajeExito", "Producto eliminado del inventario.");
        return "redirect:/clinica/inventario";
    }

    // 17. DESCARGAR FACTURA PDF EXPRESS
    @GetMapping("/descargar-factura/{visitaId}")
    public ResponseEntity<InputStreamResource> descargarFactura(@PathVariable String visitaId, Authentication auth) {
        Optional<Visita> visitaOpt = visitaService.findById(visitaId);
        Clinica clinica = obtenerClinicaLogueada(auth);

        if (visitaOpt.isEmpty() || clinica == null)
            return ResponseEntity.notFound().build();

        Visita visita = visitaOpt.get();
        Mascota mascota = mascotaService.findById(visita.getMascotaId()).orElse(new Mascota());
        Usuario dueno = usuarioService.findById(mascota.getPropietarioId()).orElse(new Usuario());

        Double subtotal = visita.getCostoTotal() > 0 ? visita.getCostoTotal() : (visita.getPeso() != null ? 35.0 : 25.0);
        Double igv = subtotal * 0.18;
        Double total = subtotal + igv;

        Map<String, Object> data = new HashMap<>();
        data.put("visita", visita);
        data.put("clinica", clinica);
        data.put("mascota", mascota);
        data.put("dueno", dueno);
        data.put("subtotal", subtotal);
        data.put("igv", igv);
        data.put("total", total);

        ByteArrayInputStream bis = pdfService.generatePdfFromTemplate("clinica/pdf_factura", data);
        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "inline; filename=factura_" + mascota.getNombre() + "_" + visita.getId() + ".pdf");

        return ResponseEntity.ok().headers(headers).contentType(MediaType.APPLICATION_PDF)
                .body(new InputStreamResource(bis));
    }

    // 18. MÓDULO DE LABORATORIO (SAAS ENTERPRISE)
    @GetMapping("/mascota/{mascotaId}/examenes")
    public String verExamenes(@PathVariable String mascotaId, Authentication auth, Model model) {
        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";

        Optional<Mascota> mascotaOpt = mascotaRepository.findById(mascotaId);
        if (mascotaOpt.isEmpty())
            return "redirect:/clinica/citas";

        Mascota mascota = mascotaOpt.get();
        List<ExamenLaboratorio> examenes = examenLaboratorioRepository.findByMascotaId(mascotaId);

        model.addAttribute("mascota", mascota);
        model.addAttribute("examenes", examenes);
        model.addAttribute("clinica", clinica);
        return "clinica/examenes";
    }

    @PostMapping("/mascota/{mascotaId}/examenes/guardar")
    public String guardarExamen(
            @PathVariable String mascotaId,
            @RequestParam String tipoExamen,
            @RequestParam String conclusiones,
            @RequestParam List<String> parametro,
            @RequestParam List<String> valor,
            @RequestParam List<String> rango,
            Authentication auth,
            RedirectAttributes redirectAttributes) {

        Clinica clinica = obtenerClinicaLogueada(auth);
        if (clinica == null)
            return "redirect:/login";

        ExamenLaboratorio examen = new ExamenLaboratorio();
        examen.setMascotaId(mascotaId);
        examen.setClinicaId(clinica.getId());
        examen.setTipoExamen(tipoExamen);
        examen.setFechaExamen(LocalDateTime.now());
        examen.setConclusiones(conclusiones);

        for (int i = 0; i < parametro.size(); i++) {
            if (i < valor.size() && i < rango.size()) {
                String p = parametro.get(i).trim();
                String v = valor.get(i).trim();
                String r = rango.get(i).trim();
                if (!p.isEmpty()) {
                    examen.getResultados().put(p, v);
                    examen.getRangosReferencia().put(p, r);
                }
            }
        }

        examenLaboratorioRepository.save(examen);
        redirectAttributes.addFlashAttribute("mensajeExito", "Examen de laboratorio registrado con éxito.");
        return "redirect:/clinica/mascota/" + mascotaId + "/examenes";
    }

    @GetMapping("/descargar-examen/{examenId}")
    public ResponseEntity<InputStreamResource> descargarExamen(@PathVariable String examenId, Authentication auth) {
        Optional<ExamenLaboratorio> examenOpt = examenLaboratorioRepository.findById(examenId);
        Clinica clinica = obtenerClinicaLogueada(auth);

        if (examenOpt.isEmpty() || clinica == null)
            return ResponseEntity.notFound().build();

        ExamenLaboratorio examen = examenOpt.get();
        Mascota mascota = mascotaService.findById(examen.getMascotaId()).orElse(new Mascota());
        Usuario dueno = usuarioService.findById(mascota.getPropietarioId()).orElse(new Usuario());

        Map<String, Object> data = new HashMap<>();
        data.put("examen", examen);
        data.put("clinica", clinica);
        data.put("mascota", mascota);
        data.put("dueno", dueno);

        ByteArrayInputStream bis = pdfService.generatePdfFromTemplate("clinica/pdf_examen", data);
        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "inline; filename=reporte_laboratorio_" + mascota.getNombre() + "_" + examen.getTipoExamen() + ".pdf");

        return ResponseEntity.ok().headers(headers).contentType(MediaType.APPLICATION_PDF)
                .body(new InputStreamResource(bis));
    }
}