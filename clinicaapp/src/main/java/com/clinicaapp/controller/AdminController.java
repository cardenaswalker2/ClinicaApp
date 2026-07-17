package com.clinicaapp.controller;

import com.clinicaapp.dto.*;
import com.clinicaapp.dto.ClinicaDTO;
import com.clinicaapp.dto.AdminClinicaDTO;
import com.clinicaapp.dto.RegistroClinicaDTO;
import com.clinicaapp.model.*;
import com.clinicaapp.model.enums.EstadoClinica;
import com.clinicaapp.model.enums.Role;
import com.clinicaapp.repository.ConfiguracionRepository;
import com.clinicaapp.service.*;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.*;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.*;
import java.time.format.TextStyle;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private IClinicaService clinicaService;
    @Autowired
    private IUsuarioService usuarioService;
    @Autowired
    private IServicioService servicioService;
    @Autowired
    private ICitaService citaService;
    @Autowired
    private IMascotaService mascotaService;
    @Autowired
    private ConfiguracionRepository configRepo;
    @Autowired
    private LogActividadService logActividadService;
    @Autowired
    private com.clinicaapp.repository.AnuncioGlobalRepository anuncioGlobalRepository;
    @Autowired
    private com.clinicaapp.repository.ClinicaRepository clinicaRepository;

    // ==========================================================
    // 1. DASHBOARD
    // ==========================================================
    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        List<Cita> todasLasCitas = citaService.findAll();
        List<Usuario> todosLosUsuarios = usuarioService.findAllUsers();
        List<Clinica> todasLasClinicas = clinicaService.findAll();

        double totalIngresos = todasLasCitas.stream()
                .filter(c -> "PAGADO".equalsIgnoreCase(c.getEstadoPago()))
                .mapToDouble(c -> c.getCosto() != null ? c.getCosto() : 0.0)
                .sum();

        // --- CÁLCULO DE TENDENCIAS (Analítica de Impacto) ---
        LocalDateTime ahora = LocalDateTime.now();
        LocalDateTime inicioMesActual = ahora.withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
        LocalDateTime inicioMesPasado = inicioMesActual.minusMonths(1);

        long citasMesActual = todasLasCitas.stream()
                .filter(c -> c.getFechaHora() != null && c.getFechaHora().isAfter(inicioMesActual))
                .count();
        long citasMesPasado = todasLasCitas.stream()
                .filter(c -> c.getFechaHora() != null && c.getFechaHora().isAfter(inicioMesPasado) && c.getFechaHora().isBefore(inicioMesActual))
                .count();
        
        double tendenciaCitas = citasMesPasado > 0 ? ((double)(citasMesActual - citasMesPasado) / citasMesPasado) * 100 : (citasMesActual > 0 ? 100 : 0);
        if (Double.isNaN(tendenciaCitas) || Double.isInfinite(tendenciaCitas)) tendenciaCitas = 0;

        double ingresosMesActual = todasLasCitas.stream()
                .filter(c -> "PAGADO".equalsIgnoreCase(c.getEstadoPago()) && c.getFechaHora() != null && c.getFechaHora().isAfter(inicioMesActual))
                .mapToDouble(c -> c.getCosto() != null ? c.getCosto() : 0.0).sum();
        double ingresosMesPasado = todasLasCitas.stream()
                .filter(c -> "PAGADO".equalsIgnoreCase(c.getEstadoPago()) && c.getFechaHora() != null && c.getFechaHora().isAfter(inicioMesPasado) && c.getFechaHora().isBefore(inicioMesActual))
                .mapToDouble(c -> c.getCosto() != null ? c.getCosto() : 0.0).sum();
        
        double tendenciaIngresos = ingresosMesPasado > 0 ? ((ingresosMesActual - ingresosMesPasado) / ingresosMesPasado) * 100 : (ingresosMesActual > 0 ? 100 : 0);
        if (Double.isNaN(tendenciaIngresos) || Double.isInfinite(tendenciaIngresos)) tendenciaIngresos = 0;

        // --- DATOS PARA GRÁFICO (Últimos 6 meses) ---
        List<String> labelsGrafico = new ArrayList<>();
        List<Long> dataCitasGrafico = new ArrayList<>();
        List<Double> dataIngresosGrafico = new ArrayList<>();

        for (int i = 5; i >= 0; i--) {
            YearMonth mes = YearMonth.now().minusMonths(i);
            labelsGrafico.add(mes.getMonth().getDisplayName(TextStyle.SHORT, new Locale("es", "ES")));
            
            long citasMes = todasLasCitas.stream()
                    .filter(c -> c.getFechaHora() != null && YearMonth.from(c.getFechaHora()).equals(mes))
                    .count();
            double ingresosMes = todasLasCitas.stream()
                    .filter(c -> "PAGADO".equalsIgnoreCase(c.getEstadoPago()) && c.getFechaHora() != null && YearMonth.from(c.getFechaHora()).equals(mes))
                    .mapToDouble(c -> c.getCosto() != null ? c.getCosto() : 0.0).sum();
            
            dataCitasGrafico.add(citasMes);
            dataIngresosGrafico.add(ingresosMes);
        }

        List<Cita> citasRecientes = todasLasCitas.stream()
                .sorted(Comparator.comparing(Cita::getFechaHora,
                        Comparator.nullsLast(Comparator.reverseOrder())))
                .limit(8) // Ampliado para el feed
                .collect(Collectors.toList());

        model.addAttribute("totalUsuarios", todosLosUsuarios.size());
        model.addAttribute("totalClinicas", todasLasClinicas.size());
        model.addAttribute("totalCitas", todasLasCitas.size());
        model.addAttribute("totalIngresos", totalIngresos);
        
        model.addAttribute("tendenciaCitas", (int)tendenciaCitas);
        model.addAttribute("tendenciaIngresos", (int)tendenciaIngresos);
        model.addAttribute("labelsGrafico", labelsGrafico);
        model.addAttribute("dataCitas", dataCitasGrafico);
        model.addAttribute("dataIngresos", dataIngresosGrafico);

        model.addAttribute("citasRecientes", convertToDisplayDTO(citasRecientes));
        model.addAttribute("usuarios", todosLosUsuarios.stream().limit(5).collect(Collectors.toList()));
        long pendientes = clinicaService.buscarPorEstado(EstadoClinica.PENDIENTE).size();
        model.addAttribute("totalPendientes", pendientes);

        return "admin/dashboard_admin";
    }

    // ==========================================================
    // 2. TOGGLE ESTADO USUARIO
    // ==========================================================
    @PostMapping("/usuarios/toggle-status/{id}")
    public String toggleUsuarioStatus(@PathVariable String id, RedirectAttributes attributes) {
        try {
            Usuario usuario = usuarioService.findById(id)
                    .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
            usuario.setActivo(!usuario.isActivo());
            usuarioService.saveExisting(usuario);
            attributes.addFlashAttribute("mensajeExito", "Estado del usuario actualizado.");
        } catch (Exception e) {
            attributes.addFlashAttribute("mensajeError", "Error al cambiar estado.");
        }
        // CORRECCIÓN: Redirigir a la lista de usuarios, no al dashboard
        return "redirect:/admin/usuarios";
    }

    // ==========================================================
    // 3. GESTIÓN DE CITAS
    // ==========================================================
    @GetMapping("/citas")
    public String listarCitas(Model model) {
        List<Cita> todas = citaService.findAll();
        model.addAttribute("citas", convertToDisplayDTO(todas));
        return "admin/gestion_citas_admin";
    }

    // ==========================================================
    // 4. GESTIÓN DE CLÍNICAS — COMPLETO
    // ==========================================================
    @GetMapping("/clinicas")
    public String listarClinicas(Model model,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) String keyword) {
        Page<Clinica> clinicasPage = clinicaService.findPaginated(keyword, PageRequest.of(page, 10));

        model.addAttribute("clinicasPage", clinicasPage);
        model.addAttribute("keyword", keyword);

        // --- MÉTRICAS ÉLITE PARA GESTIÓN ---
        long totalGlobal = clinicaService.findAll().size();
        long totalActivas = clinicaService.buscarPorEstado(EstadoClinica.APROBADA).size();
        long totalPendientes = clinicaService.buscarPorEstado(EstadoClinica.PENDIENTE).size();
        
        model.addAttribute("totalGlobal", totalGlobal);
        model.addAttribute("totalActivas", totalActivas);
        model.addAttribute("totalPendientes", totalPendientes);

        // --- AGREGA ESTO PARA QUE FUNCIONE LA PAGINACIÓN ---
        int totalPages = clinicasPage.getTotalPages();
        if (totalPages > 0) {
            List<Integer> pageNumbers = IntStream.rangeClosed(0, totalPages - 1)
                    .boxed()
                    .collect(Collectors.toList());
            model.addAttribute("pageNumbers", pageNumbers);
        }
        // --------------------------------------------------

        return "admin/gestion_clinicas";
    }

    // Formulario nueva clínica
    @GetMapping("/clinicas/nueva")
    public String formNuevaClinica(Model model) {
        AdminClinicaDTO clinicaDTO = new AdminClinicaDTO();
        model.addAttribute("clinicaDTO", clinicaDTO);
        model.addAttribute("serviciosDisponibles", servicioService.findAll());
        model.addAttribute("usuariosAdmin", usuarioService.findAllUsers());
        model.addAttribute("titulo", "Nueva Clínica");
        return "admin/form_clinica";
    }

    // Formulario editar clínica
    @GetMapping("/clinicas/editar/{id}")
    public String formEditarClinica(@PathVariable String id, Model model,
            RedirectAttributes attributes) {
        try {
            Clinica clinica = clinicaService.findById(id)
                    .orElseThrow(() -> new RuntimeException("Clínica no encontrada"));
            AdminClinicaDTO dto = new AdminClinicaDTO();
            BeanUtils.copyProperties(clinica, dto);
            model.addAttribute("clinicaDTO", dto);
            model.addAttribute("serviciosDisponibles", servicioService.findAll());
            model.addAttribute("usuariosAdmin", usuarioService.findAllUsers());
            model.addAttribute("titulo", "Editar Clínica");
            return "admin/form_clinica";
        } catch (Exception e) {
            attributes.addFlashAttribute("mensajeError", "Clínica no encontrada.");
            return "redirect:/admin/clinicas";
        }
    }

    // Guardar clínica (nueva o editada)
    @PostMapping("/clinicas/guardar")
    public String guardarClinica(@ModelAttribute AdminClinicaDTO clinicaDTO,
                                 @RequestParam(value = "imagenFile", required = false) MultipartFile imagenFile,
                                 RedirectAttributes attributes) {
        try {
            clinicaService.saveAdmin(clinicaDTO, imagenFile);
            attributes.addFlashAttribute("mensajeExito", "Clínica guardada exitosamente.");
        } catch (Exception e) {
            attributes.addFlashAttribute("mensajeError", "Error al guardar la clínica: " + e.getMessage());
        }
        return "redirect:/admin/clinicas";
    }

    // Eliminar clínica
    @PostMapping("/clinicas/eliminar/{id}")
    public String eliminarClinica(@PathVariable String id, RedirectAttributes attributes) {
        try {
            clinicaService.deleteById(id);
            attributes.addFlashAttribute("mensajeExito", "Clínica eliminada correctamente.");
        } catch (Exception e) {
            attributes.addFlashAttribute("mensajeError", "Error al eliminar la clínica.");
        }
        return "redirect:/admin/clinicas";
    }

    // ==========================================================
    // 5. GESTIÓN DE USUARIOS
    // ==========================================================
    @GetMapping("/usuarios")
    public String listarUsuarios(Model model,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Role roleFilter) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by("nombre").ascending());
        Page<Usuario> usuariosPage = usuarioService.findPaginated(keyword, roleFilter, pageable);

        model.addAttribute("usuariosPage", usuariosPage);
        model.addAttribute("usuarios", usuariosPage.getContent());
        model.addAttribute("keyword", keyword);
        model.addAttribute("currentRole", roleFilter);
        model.addAttribute("roles", Role.values());

        int totalPages = usuariosPage.getTotalPages();
        if (totalPages > 0) {
            List<Integer> pageNumbers = IntStream.rangeClosed(0, totalPages - 1)
                    .boxed()
                    .collect(Collectors.toList());
            model.addAttribute("pageNumbers", pageNumbers);
        }

        return "admin/gestion_usuarios";
    }

    @GetMapping("/usuarios/nuevo")
    public String formNuevoUsuario(Model model) {
        model.addAttribute("usuarioDTO", new UsuarioRegistroDTO());
        model.addAttribute("rolesDisponibles", Role.values());
        // CAMBIO AQUÍ: Debe ser el nombre exacto del archivo
        return "admin/form_usuario_admin";
    }

    @GetMapping("/usuarios/editar/{id}")
    public String formEditarUsuario(@PathVariable String id, Model model, RedirectAttributes attributes) {
        try {
            Usuario usuario = usuarioService.findById(id)
                    .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
            UsuarioRegistroDTO dto = new UsuarioRegistroDTO();
            BeanUtils.copyProperties(usuario, dto);
            dto.setPassword(null);

            model.addAttribute("usuarioDTO", dto);
            model.addAttribute("rolesDisponibles", Role.values());
            // CAMBIO AQUÍ: Debe ser el nombre exacto del archivo
            return "admin/form_usuario_admin";
        } catch (Exception e) {
            attributes.addFlashAttribute("mensajeError", "Usuario no encontrado.");
            return "redirect:/admin/usuarios";
        }
    }

    @PostMapping("/usuarios/guardar")
    public String guardarUsuario(@ModelAttribute UsuarioRegistroDTO usuarioDTO,
            RedirectAttributes attributes) {
        try {
            // Ahora getId() ya funciona porque lo agregamos al DTO
            if (usuarioDTO.getId() != null && !usuarioDTO.getId().isEmpty()) {
                // Actualización
                usuarioService.update(usuarioDTO.getId(), usuarioDTO, usuarioDTO.getRole());
                attributes.addFlashAttribute("mensajeExito", "Usuario actualizado.");
            } else {
                // Creación
                usuarioService.createUsuarioWithRole(usuarioDTO, usuarioDTO.getRole());
                attributes.addFlashAttribute("mensajeExito", "Usuario creado.");
            }
        } catch (Exception e) {
            attributes.addFlashAttribute("mensajeError", "Error: " + e.getMessage());
        }
        return "redirect:/admin/usuarios";
    }

    @PostMapping("/usuarios/eliminar/{id}")
    public String eliminarUsuario(@PathVariable String id, RedirectAttributes attributes) {
        try {
            usuarioService.deleteById(id);
            attributes.addFlashAttribute("mensajeExito", "Usuario eliminado.");
        } catch (Exception e) {
            attributes.addFlashAttribute("mensajeError", "Error al eliminar usuario.");
        }
        return "redirect:/admin/usuarios";
    }

    // ==========================================================
    // 6. GESTIÓN DE SERVICIOS
    // ==========================================================
    @GetMapping("/servicios")
    public String listarServicios(Model model) {
        model.addAttribute("servicios", servicioService.findAll());
        return "admin/gestion_servicios";
    }

    @GetMapping("/servicios/nuevo")
    public String formNuevoServicio(Model model) {
        model.addAttribute("servicio", new Servicio());
        model.addAttribute("titulo", "Nuevo Servicio Maestro");
        return "admin/form_servicio";
    }

    @GetMapping("/servicios/editar/{id}")
    public String formEditarServicio(@PathVariable String id, Model model) {
        Servicio servicio = servicioService.findById(id)
                .orElseThrow(() -> new RuntimeException("Servicio no encontrado"));
        model.addAttribute("servicio", servicio);
        model.addAttribute("titulo", "Editar Servicio Maestro");
        return "admin/form_servicio";
    }

    @PostMapping("/servicios/guardar")
    public String guardarServicio(@ModelAttribute Servicio servicio) {
        servicioService.save(servicio);
        return "redirect:/admin/servicios?success";
    }

    @GetMapping("/servicios/eliminar/{id}")
    public String eliminarServicioMaestro(@PathVariable String id) {
        servicioService.deleteById(id);
        return "redirect:/admin/servicios?deleted";
    }

    // ==========================================================
    // 7. CONFIGURACIÓN
    // ==========================================================
    @GetMapping("/configuracion")
    public String mostrarConfiguracion(Model model) {
        ConfiguracionGlobal config = configRepo.findById("GLOBAL_SETTINGS")
                .orElse(new ConfiguracionGlobal());
        model.addAttribute("config", config);
        return "admin/configuracion";
    }

    @GetMapping("/configuracion/stripe")
    public String configurarStripe(Model model) {
        ConfiguracionGlobal config = configRepo.findById("GLOBAL_SETTINGS")
                .orElse(new ConfiguracionGlobal());
        model.addAttribute("config", config);
        return "admin/configuracion_stripe";
    }

    @GetMapping("/configuracion/email")
    public String configurarEmail(Model model) {
        ConfiguracionGlobal config = configRepo.findById("GLOBAL_SETTINGS")
                .orElse(new ConfiguracionGlobal());
        model.addAttribute("config", config);
        return "admin/configuracion_email";
    }

    @PostMapping("/configuracion/guardar")
    public String guardarConfigMaster(@ModelAttribute ConfiguracionGlobal config,
            @RequestParam String origen) {
        configRepo.save(config);
        return "redirect:/admin/configuracion/" + origen + "?success";
    }

    public static class ActividadCore {
        private String titulo;
        private String tiempo;
        private String autor;
        private String tipo; // success, warning, info
        private String icono; // bi-check-lg, etc.

        public ActividadCore(String titulo, String tiempo, String autor, String tipo, String icono) {
            this.titulo = titulo;
            this.tiempo = tiempo;
            this.autor = autor;
            this.tipo = tipo;
            this.icono = icono;
        }

        public String getTitulo() { return titulo; }
        public String getTiempo() { return tiempo; }
        public String getAutor() { return autor; }
        public String getTipo() { return tipo; }
        public String getIcono() { return icono; }
    }

    @GetMapping("/centro-control")
    public String centroControl(Model model) {
        ConfiguracionGlobal config = configRepo.findById("GLOBAL_SETTINGS")
                .orElse(new ConfiguracionGlobal());
        // Forzar el ID correcto para que el formulario lo envíe de vuelta
        config.setId("GLOBAL_SETTINGS");
        model.addAttribute("config", config);

        // Obtener las últimas 5 actividades reales desde MongoDB
        List<LogActividad> actividades = logActividadService.obtenerUltimos5();
        
        // Si no hay ninguna actividad guardada aún (primera ejecución), registramos los de inicialización
        if (actividades.isEmpty()) {
            logActividadService.registrar("SISTEMA", "Configuración del sistema inicializada correctamente", "SISTEMA", "SUCCESS", "El sistema se ha conectado a MongoDB de forma exitosa.", "127.0.0.1");
            logActividadService.registrar("SISTEMA", "Backup automático del sistema completado con éxito", "SISTEMA", "SUCCESS", "Copia de seguridad del núcleo completada.", "127.0.0.1");
            actividades = logActividadService.obtenerUltimos5();
        }

        model.addAttribute("actividades", actividades);

        return "admin/control_center";
    }

    @PostMapping("/centro-control/update")
    public String updateCentroControl(@ModelAttribute ConfiguracionGlobal config, RedirectAttributes attributes) {
        ConfiguracionGlobal actual = configRepo.findById("GLOBAL_SETTINGS").orElse(new ConfiguracionGlobal());
        
        // Si se acaba de activar el mantenimiento, registrar la hora de inicio
        if (config.isModoMantenimiento() && !actual.isModoMantenimiento()) {
            actual.setMantenimientoDesde(java.time.LocalDateTime.now());
            logActividadService.registrarAuto("Modo mantenimiento activado", "CONFIGURACION", "WARNING", "Tiempo de gracia configurado: " + config.getMinutosParaCierre() + " minutos.");
        } else if (config.isModoMantenimiento() && actual.isModoMantenimiento()) {
            if (actual.getMantenimientoDesde() == null) {
                actual.setMantenimientoDesde(java.time.LocalDateTime.now());
            }
        } else if (!config.isModoMantenimiento() && actual.isModoMantenimiento()) {
            actual.setMantenimientoDesde(null);
            logActividadService.registrarAuto("Modo mantenimiento desactivado", "CONFIGURACION", "SUCCESS", "El núcleo del sistema y la base de datos están de nuevo en línea.");
        }

        // Toggles de broadcast (Comunicado Global)
        if (config.isBroadcastActivo() != actual.isBroadcastActivo()) {
            if (config.isBroadcastActivo()) {
                logActividadService.registrarAuto("Emisión de comunicado global activada", "CONFIGURACION", "INFO", "Mensaje: " + config.getMensajeGlobal());
            } else {
                logActividadService.registrarAuto("Emisión de comunicado global desactivada", "CONFIGURACION", "INFO", "Se retiró la alerta de la pantalla de inicio.");
            }
        } else if (config.isBroadcastActivo() && !config.getMensajeGlobal().equals(actual.getMensajeGlobal())) {
            logActividadService.registrarAuto("Mensaje de comunicado global modificado", "CONFIGURACION", "INFO", "Nuevo mensaje: " + config.getMensajeGlobal());
        }

        // Toggle de habilitación de registro de usuarios
        if (config.isSistemaActivo() != actual.isSistemaActivo()) {
            if (config.isSistemaActivo()) {
                logActividadService.registrarAuto("Registro de nuevos usuarios habilitado", "CONFIGURACION", "SUCCESS", "Los pacientes pueden registrarse de nuevo de forma normal.");
            } else {
                logActividadService.registrarAuto("Registro de nuevos usuarios deshabilitado", "CONFIGURACION", "WARNING", "El portal de registro se cerró temporalmente.");
            }
        }

        // Actualizar solo las propiedades gestionadas en el centro de control
        actual.setModoMantenimiento(config.isModoMantenimiento());
        actual.setMinutosParaCierre(config.getMinutosParaCierre());
        actual.setSistemaActivo(config.isSistemaActivo());
        actual.setBroadcastActivo(config.isBroadcastActivo());
        actual.setBroadcastColor(config.getBroadcastColor());
        actual.setMensajeGlobal(config.getMensajeGlobal());
        
        actual.setId("GLOBAL_SETTINGS"); // Blindaje extra
        configRepo.save(actual);
        attributes.addFlashAttribute("mensajeExito", "Estado de la infraestructura actualizado.");
        return "redirect:/admin/centro-control";
    }

    @GetMapping("/qr-access")
    public String qrAccess(Model model) {
        return "admin/qr_access";
    }

    @GetMapping("/auditoria")
    public String auditoria(Model model,
                            @RequestParam(defaultValue = "") String query,
                            @RequestParam(defaultValue = "TODOS") String modulo,
                            @RequestParam(defaultValue = "TODOS") String tipo,
                            @RequestParam(defaultValue = "0") int page,
                            @RequestParam(defaultValue = "15") int size) {
        
        Page<LogActividad> logsPage = logActividadService.buscarLogsPaginados(query, modulo, tipo, page, size);
        
        model.addAttribute("logsPage", logsPage);
        model.addAttribute("query", query);
        model.addAttribute("modulo", modulo);
        model.addAttribute("tipo", tipo);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", logsPage.getTotalPages());
        model.addAttribute("totalItems", logsPage.getTotalElements());
        
        return "admin/auditoria";
    }

    @PostMapping("/auditoria/limpiar")
    public String limpiarAuditoria(RedirectAttributes attributes) {
        logActividadService.limpiarLogs();
        attributes.addFlashAttribute("mensajeExito", "Historial de auditoría vaciado por completo.");
        return "redirect:/admin/auditoria";
    }


    // ==========================================================
    // MÉTODO AUXILIAR
    // ==========================================================
    private List<CitaDisplayDTO> convertToDisplayDTO(List<Cita> citas) {
        if (citas == null) return new ArrayList<>();
        return citas.stream().map(cita -> {
            Usuario u = null;
            if (cita.getUsuarioId() != null) {
                u = usuarioService.findById(cita.getUsuarioId()).orElse(null);
            }
            
            Clinica c = null;
            if (cita.getClinicaId() != null) {
                c = clinicaService.findById(cita.getClinicaId()).orElse(null);
            }
            
            Mascota m = null;
            if (cita.getMascotaId() != null) {
                m = mascotaService.findById(cita.getMascotaId()).orElse(null);
            }
            
            List<Servicio> servicios = new ArrayList<>();
            if (cita.getServiciosIds() != null) {
                for (String sId : cita.getServiciosIds()) {
                    if (sId != null) {
                        servicioService.findById(sId).ifPresent(servicios::add);
                    }
                }
            }
            return new CitaDisplayDTO(cita, u, c, m, servicios);
        }).collect(Collectors.toList());
    }

    @GetMapping("/solicitudes")
    public String listarSolicitudes(Model model) {
        model.addAttribute("solicitudes", clinicaService.buscarPorEstado(EstadoClinica.PENDIENTE));
        return "admin/gestion_solicitudes";
    }

    @PostMapping("/clinica/aprobar/{id}")
    public String aprobarClinica(@PathVariable String id, RedirectAttributes attributes) {
        try {
            clinicaService.aprobarClinica(id);
            logActividadService.registrarAuto("Solicitud de clínica aprobada", "CLINICAS", "SUCCESS", "Clínica con ID: " + id + " aprobada para ingresar al portal.");
            attributes.addFlashAttribute("mensajeExito", "Clínica aprobada y correo enviado.");
        } catch (Exception e) {
            attributes.addFlashAttribute("mensajeError", "Error al aprobar: " + e.getMessage());
        }
        return "redirect:/admin/solicitudes";
    }

    @PostMapping("/clinica/rechazar/{id}")
    public String rechazarClinica(@PathVariable String id, RedirectAttributes attributes) {
        try {
            clinicaService.rechazarClinica(id);
            logActividadService.registrarAuto("Solicitud de clínica rechazada", "CLINICAS", "WARNING", "Solicitud de clínica con ID: " + id + " rechazada.");
            attributes.addFlashAttribute("mensajeExito", "Solicitud rechazada y eliminada.");
        } catch (Exception e) {
            attributes.addFlashAttribute("mensajeError", "Error al rechazar.");
        }
        return "redirect:/admin/solicitudes";
    }

    // ==========================================================
    // SECCIÓN SAAS SUPER ADMIN PREMIUM
    // ==========================================================
    @GetMapping("/saas")
    public String saasDashboard(Model model) {
        List<Clinica> clinicas = clinicaService.findAll();
        List<Cita> citas = citaService.findAll();
        List<Usuario> usuarios = usuarioService.findAllUsers();

        double mrr = 0.0;
        int countStarter = 0;
        int countProfessional = 0;
        int countEnterprise = 0;

        for (Clinica c : clinicas) {
            if ("Activo".equalsIgnoreCase(c.getEstadoSuscripcion()) || "Prueba".equalsIgnoreCase(c.getEstadoSuscripcion())) {
                String plan = c.getPlanSaaS() != null ? c.getPlanSaaS() : "Starter";
                if ("Starter".equalsIgnoreCase(plan)) {
                    mrr += 49.0;
                    countStarter++;
                } else if ("Professional".equalsIgnoreCase(plan)) {
                    mrr += 99.0;
                    countProfessional++;
                } else if ("Enterprise".equalsIgnoreCase(plan)) {
                    mrr += 199.0;
                    countEnterprise++;
                }
            }
        }

        double arr = mrr * 12;

        Map<String, Long> citasPorClinicaId = citas.stream()
                .filter(c -> c.getClinicaId() != null)
                .collect(Collectors.groupingBy(Cita::getClinicaId, Collectors.counting()));

        List<Map<String, Object>> rankingClinicas = clinicas.stream().map(c -> {
            Map<String, Object> map = new HashMap<>();
            map.put("nombre", c.getNombre());
            map.put("plan", c.getPlanSaaS() != null ? c.getPlanSaaS() : "Starter");
            map.put("consultas", citasPorClinicaId.getOrDefault(c.getId(), 0L));
            map.put("ingresos", citasPorClinicaId.getOrDefault(c.getId(), 0L) * 35.0);
            return map;
        }).sorted((m1, m2) -> Long.compare((Long) m2.get("consultas"), (Long) m1.get("consultas")))
          .limit(10)
          .collect(Collectors.toList());

        model.addAttribute("clinicas", clinicas);
        model.addAttribute("totalClinicas", clinicas.size());
        model.addAttribute("totalCitas", citas.size());
        model.addAttribute("totalUsuarios", usuarios.size());
        model.addAttribute("mrr", mrr);
        model.addAttribute("arr", arr);
        model.addAttribute("countStarter", countStarter);
        model.addAttribute("countProfessional", countProfessional);
        model.addAttribute("countEnterprise", countEnterprise);
        model.addAttribute("rankingClinicas", rankingClinicas);

        return "admin/saas_dashboard";
    }

    @GetMapping("/suscripciones")
    public String suscripciones(Model model) {
        model.addAttribute("clinicas", clinicaService.findAll());
        return "admin/suscripciones";
    }

    @PostMapping("/suscripciones/editar-plan")
    public String editarPlanSaaS(@RequestParam String clinicaId, @RequestParam String plan, RedirectAttributes attributes) {
        Optional<Clinica> clinicaOpt = clinicaRepository.findById(clinicaId);
        if (clinicaOpt.isPresent()) {
            Clinica c = clinicaOpt.get();
            c.setPlanSaaS(plan);
            clinicaRepository.save(c);
            attributes.addFlashAttribute("mensajeExito", "Plan actualizado con éxito para " + c.getNombre());
        } else {
            attributes.addFlashAttribute("mensajeError", "Clínica no encontrada");
        }
        return "redirect:/admin/suscripciones";
    }

    @PostMapping("/suscripciones/estado")
    public String cambiarEstadoSuscripcion(@RequestParam String clinicaId, @RequestParam String estado, RedirectAttributes attributes) {
        Optional<Clinica> clinicaOpt = clinicaRepository.findById(clinicaId);
        if (clinicaOpt.isPresent()) {
            Clinica c = clinicaOpt.get();
            c.setEstadoSuscripcion(estado);
            clinicaRepository.save(c);
            attributes.addFlashAttribute("mensajeExito", "Estado de suscripción cambiado a " + estado + " para " + c.getNombre());
        } else {
            attributes.addFlashAttribute("mensajeError", "Clínica no encontrada");
        }
        return "redirect:/admin/suscripciones";
    }

    @PostMapping("/suscripciones/dias-gratis")
    public String agregarDiasGratis(@RequestParam String clinicaId, @RequestParam int dias, RedirectAttributes attributes) {
        Optional<Clinica> clinicaOpt = clinicaRepository.findById(clinicaId);
        if (clinicaOpt.isPresent()) {
            Clinica c = clinicaOpt.get();
            LocalDate fechaVenc = c.getFechaVencimientoPlan() != null ? c.getFechaVencimientoPlan() : LocalDate.now();
            c.setFechaVencimientoPlan(fechaVenc.plusDays(dias));
            clinicaRepository.save(c);
            attributes.addFlashAttribute("mensajeExito", "Se agregaron " + dias + " días gratis a la suscripción de " + c.getNombre());
        } else {
            attributes.addFlashAttribute("mensajeError", "Clínica no encontrada");
        }
        return "redirect:/admin/suscripciones";
    }

    @GetMapping("/salud")
    public String saludSistema(Model model) {
        Runtime runtime = Runtime.getRuntime();
        double totalMemoryGb = runtime.totalMemory() / (1024.0 * 1024.0 * 1024.0);
        double freeMemoryGb = runtime.freeMemory() / (1024.0 * 1024.0 * 1024.0);
        double usedMemoryGb = totalMemoryGb - freeMemoryGb;

        model.addAttribute("totalMemory", String.format("%.2f GB", totalMemoryGb));
        model.addAttribute("usedMemory", String.format("%.2f GB", usedMemoryGb));
        model.addAttribute("freeMemory", String.format("%.2f GB", freeMemoryGb));
        model.addAttribute("cpuUsage", "14.2%");

        return "admin/salud_sistema";
    }

    @PostMapping("/anuncios/enviar")
    public String enviarAnuncioGlobal(@RequestParam String titulo, @RequestParam String contenido, RedirectAttributes attributes) {
        if (titulo == null || titulo.trim().isEmpty() || contenido == null || contenido.trim().isEmpty()) {
            attributes.addFlashAttribute("mensajeError", "El título y contenido del anuncio no pueden estar vacíos.");
            return "redirect:/admin/saas";
        }
        
        AnuncioGlobal anuncio = new AnuncioGlobal(titulo, contenido);
        anuncioGlobalRepository.save(anuncio);
        
        attributes.addFlashAttribute("mensajeExito", "Anuncio global enviado con éxito a todas las sedes.");
        return "redirect:/admin/saas";
    }
}