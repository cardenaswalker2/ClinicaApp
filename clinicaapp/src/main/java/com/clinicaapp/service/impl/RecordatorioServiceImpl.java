package com.clinicaapp.service.impl;

import com.clinicaapp.model.Recordatorio;
import com.clinicaapp.model.Usuario;
import com.clinicaapp.repository.RecordatorioRepository;
import com.clinicaapp.repository.UsuarioRepository;
import com.clinicaapp.service.IEmailService;
import com.clinicaapp.service.IRecordatorioService;
import com.clinicaapp.service.ISmsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class RecordatorioServiceImpl implements IRecordatorioService {

    @Autowired private RecordatorioRepository recordatorioRepository;
    @Autowired private UsuarioRepository usuarioRepository;
    @Autowired private IEmailService emailService;
    @Autowired private ISmsService smsService;

    @Override
    public Recordatorio guardar(Recordatorio recordatorio) {
        if (recordatorio.getEstado() == null) {
            recordatorio.setEstado(Recordatorio.EstadoRecordatorio.PENDIENTE);
        }
        return recordatorioRepository.save(recordatorio);
    }

    @Override
    public List<Recordatorio> listarPorUsuario(String usuarioId) {
        return recordatorioRepository.findByUsuarioIdOrderByFechaHoraAsc(usuarioId);
    }

    @Override
    public void eliminar(String id) {
        recordatorioRepository.deleteById(id);
    }

    @Override
    public void procesarRecordatoriosPendientes() {
        List<Recordatorio> pendientes = recordatorioRepository.findByEstadoAndFechaHoraBefore(
                Recordatorio.EstadoRecordatorio.PENDIENTE, LocalDateTime.now()
        );

        for (Recordatorio r : pendientes) {
            try {
                Usuario u = usuarioRepository.findById(r.getUsuarioId()).orElse(null);
                if (u != null) {
                    enviarNotificacion(u, r);
                    r.setEstado(Recordatorio.EstadoRecordatorio.ENVIADO);
                    recordatorioRepository.save(r);
                }
            } catch (Exception e) {
                System.err.println("Error al procesar recordatorio " + r.getId() + ": " + e.getMessage());
            }
        }
    }

    private void enviarNotificacion(Usuario u, Recordatorio r) {
        String mensaje = "⏰ *Recordatorio:* " + r.getTitulo() + "\n" + r.getDescripcion();

        if (r.getTipo() == Recordatorio.TipoRecordatorio.GMAIL || r.getTipo() == Recordatorio.TipoRecordatorio.AMBOS) {
            String subject = "⏰ Recordatorio: " + r.getTitulo();
            String htmlBody = String.format("""
                <!DOCTYPE html>
                <html>
                <body style="margin: 0; padding: 0; background-color: #f8fafc; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">
                    <table border="0" cellpadding="0" cellspacing="0" width="100%%">
                        <tr>
                            <td style="padding: 40px 0 30px 0;">
                                <table align="center" border="0" cellpadding="0" cellspacing="0" width="600" style="border-collapse: collapse; border: 1px solid #e2e8f0; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
                                    <!-- Header -->
                                    <tr>
                                        <td align="center" style="padding: 40px 0 30px 0; background: linear-gradient(135deg, #6366f1 0%%, #a855f7 100%%);">
                                            <div style="font-size: 40px; color: #ffffff;">⏰</div>
                                            <h1 style="color: #ffffff; margin: 10px 0 0 0; font-size: 24px; font-weight: 800;">Recordatorio Programado</h1>
                                        </td>
                                    </tr>
                                    <!-- Body -->
                                    <tr>
                                        <td style="padding: 40px 30px 40px 30px;">
                                            <table border="0" cellpadding="0" cellspacing="0" width="100%%">
                                                <tr>
                                                    <td style="color: #1e293b; font-size: 18px; font-weight: 600;">
                                                        Hola %s,
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding: 20px 0 30px 0; color: #64748b; font-size: 16px; line-height: 24px;">
                                                        Este es el aviso personalizado que programaste en tu cuenta de Clínica App:
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <table border="0" cellpadding="0" cellspacing="0" width="100%%" style="background-color: #f1f5f9; border-radius: 12px; padding: 25px;">
                                                            <tr>
                                                                <td style="color: #6366f1; font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px;">
                                                                    Título
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td style="color: #1e293b; font-size: 20px; font-weight: 800; padding: 5px 0 15px 0;">
                                                                    %s
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td style="color: #6366f1; font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px;">
                                                                    Detalles
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td style="color: #475569; font-size: 16px; line-height: 24px; padding-top: 5px;">
                                                                    %s
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <!-- Footer -->
                                    <tr>
                                        <td style="padding: 30px 30px 30px 30px; background-color: #f8fafc; border-top: 1px solid #e2e8f0;">
                                            <table border="0" cellpadding="0" cellspacing="0" width="100%%">
                                                <tr>
                                                    <td align="center" style="color: #94a3b8; font-size: 12px; line-height: 18px;">
                                                        &copy; 2026 Clínica App. Todos los derechos reservados.<br/>
                                                        Has recibido este mensaje porque programaste un recordatorio en nuestra plataforma.
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </body>
                </html>
                """, u.getNombre(), r.getTitulo(), r.getDescripcion());
            emailService.sendSimpleMessage(u.getEmail(), subject, htmlBody);
        }

        if (r.getTipo() == Recordatorio.TipoRecordatorio.SMS || r.getTipo() == Recordatorio.TipoRecordatorio.AMBOS) {
            if (u.getTelefono() != null && !u.getTelefono().isEmpty()) {
                smsService.sendSms(u.getTelefono(), mensaje);
            }
        }
    }

    @Override
    public void enviarAhora(String id) {
        Recordatorio r = recordatorioRepository.findById(id).orElse(null);
        if (r != null) {
            Usuario u = usuarioRepository.findById(r.getUsuarioId()).orElse(null);
            if (u != null) {
                enviarNotificacion(u, r);
                r.setEstado(Recordatorio.EstadoRecordatorio.ENVIADO);
                recordatorioRepository.save(r);
            }
        }
    }
}
