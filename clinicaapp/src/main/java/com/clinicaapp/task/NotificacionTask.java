package com.clinicaapp.task;

import com.clinicaapp.model.*;
import com.clinicaapp.repository.*;
import com.clinicaapp.service.IEmailService;
import com.clinicaapp.service.IRecordatorioService;
import com.clinicaapp.service.ISmsService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Component
public class NotificacionTask {

    private static final Logger log = LoggerFactory.getLogger(NotificacionTask.class);

    @Autowired private CitaRepository citaRepository;
    @Autowired private UsuarioRepository usuarioRepository;
    @Autowired private ClinicaRepository clinicaRepository;
    @Autowired private IEmailService emailService;
    @Autowired private ISmsService smsService;
    @Autowired private IRecordatorioService recordatorioService;

    // Se ejecuta todos los días a las 8:00 AM para citas automáticas
    @Scheduled(cron = "0 0 8 * * ?") 
    public void enviarRecordatoriosCitas() {
        log.info("Iniciando tarea programada: Envío de recordatorios automáticos de citas...");

        // Recordatorios para Mañana (1 día) y Pasado Mañana (2 días)
        procesarCitasParaFecha(LocalDate.now().plusDays(1), "Mañana");
        procesarCitasParaFecha(LocalDate.now().plusDays(2), "En 2 días");
    }

    // Se ejecuta cada 15 minutos para procesar recordatorios personalizados
    @Scheduled(cron = "0 0/15 * * * ?")
    public void procesarRecordatoriosPersonalizados() {
        log.info("Procesando recordatorios personalizados pendientes...");
        recordatorioService.procesarRecordatoriosPendientes();
    }

    private void procesarCitasParaFecha(LocalDate fechaInteres, String etiqueta) {
        LocalDateTime inicio = fechaInteres.atStartOfDay();
        LocalDateTime fin = fechaInteres.atTime(LocalTime.MAX);

        List<Cita> citas = citaRepository.findByFechaHoraBetweenAndEstadoAndEstadoPago(
                inicio, fin, "Confirmada", "PAGADO"
        );

        log.info("Se encontraron {} citas para {}.", citas.size(), etiqueta);

        for (Cita cita : citas) {
            try {
                Usuario usuario = usuarioRepository.findById(cita.getUsuarioId()).orElse(null);
                Clinica clinica = clinicaRepository.findById(cita.getClinicaId()).orElse(null);

                if (usuario != null && clinica != null) {
                    enviarEmailRecordatorioCita(usuario, clinica, cita, etiqueta);
                    enviarSmsRecordatorioCita(usuario, clinica, cita, etiqueta);
                    log.info("Recordatorios (Email/SMS) enviados para cita {} a {}", cita.getId(), usuario.getEmail());
                }
            } catch (Exception e) {
                log.error("Error enviando recordatorio para la cita {}: {}", cita.getId(), e.getMessage());
            }
        }
    }

    private void enviarEmailRecordatorioCita(Usuario u, Clinica c, Cita cita, String etiqueta) {
        String hora = cita.getFechaHora().format(DateTimeFormatter.ofPattern("HH:mm"));
        String fecha = cita.getFechaHora().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));

        String subject = "⏰ Recordatorio: " + etiqueta + " tienes una cita en " + c.getNombre();
        
        String body = String.format("""
            <!DOCTYPE html>
            <html>
            <body style="margin: 0; padding: 0; background-color: #f0f9ff; font-family: 'Segoe UI', sans-serif;">
                <table align="center" border="0" cellpadding="0" cellspacing="0" width="600" style="background-color: #ffffff; border-radius: 20px; margin-top: 50px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.1);">
                    <tr>
                        <td style="padding: 40px; background: linear-gradient(135deg, #0ea5e9 0%%, #6366f1 100%%); text-align: center;">
                            <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: 800;">¡Hola %%s!</h1>
                            <p style="color: rgba(255,255,255,0.9); margin-top: 10px;">Tu cita está cada vez más cerca</p>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 40px;">
                            <p style="font-size: 16px; color: #475569;">Te recordamos que para <strong>%%s</strong> tienes programada la siguiente cita:</p>
                            
                            <table width="100%%" style="background-color: #f8fafc; border-radius: 12px; margin-top: 20px;">
                                <tr>
                                    <td style="padding: 20px;">
                                        <div style="color: #0ea5e9; font-weight: 700; font-size: 13px; text-transform: uppercase;">Establecimiento</div>
                                        <div style="font-size: 18px; font-weight: 700; color: #1e293b; margin-bottom: 15px;">%%s</div>
                                        
                                        <div style="color: #0ea5e9; font-weight: 700; font-size: 13px; text-transform: uppercase;">Ubicación</div>
                                        <div style="font-size: 15px; color: #475569; margin-bottom: 15px;">%%s</div>
                                        
                                        <table width="100%%">
                                            <tr>
                                                <td>
                                                    <div style="color: #0ea5e9; font-weight: 700; font-size: 13px; text-transform: uppercase;">Fecha</div>
                                                    <div style="font-size: 15px; color: #1e293b; font-weight: 600;">%%s</div>
                                                </td>
                                                <td>
                                                    <div style="color: #0ea5e9; font-weight: 700; font-size: 13px; text-transform: uppercase;">Hora</div>
                                                    <div style="font-size: 15px; color: #1e293b; font-weight: 600;">%%s</div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                            
                            <p style="margin-top: 30px; font-size: 14px; color: #64748b; text-align: center;">
                                Por favor, llega 10 minutos antes de la hora acordada.
                            </p>
                        </td>
                    </tr>
                </table>
            </body>
            </html>
            """, u.getNombre(), etiqueta.toLowerCase(), c.getNombre(), c.getDireccion(), fecha, hora);

        emailService.sendSimpleMessage(u.getEmail(), subject, body);
    }

    private void enviarSmsRecordatorioCita(Usuario u, Clinica c, Cita cita, String etiqueta) {
        if (u.getTelefono() == null || u.getTelefono().isEmpty()) return;

        String hora = cita.getFechaHora().format(DateTimeFormatter.ofPattern("HH:mm"));
        String fecha = cita.getFechaHora().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));

        String mensaje = String.format("Recordatorio: Hola %%s, %%s tienes una cita en %%s (%%s). Fecha: %%s a las %%s.", 
            u.getNombre(), etiqueta.toLowerCase(), c.getNombre(), c.getDireccion(), fecha, hora);

        smsService.sendSms(u.getTelefono(), mensaje);
    }
}