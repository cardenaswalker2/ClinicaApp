package com.clinicaapp.service;

import com.clinicaapp.model.UsuarioActividad;
import org.springframework.data.domain.Page;

import java.util.List;
import java.util.Map;

public interface IUsuarioSupervisionService {

    // Registrar actividad de usuario
    void registrarActividad(String usuarioId, String email, String nombre, String tipoEvento, 
                            String seccion, String accion, String url, String ip, 
                            String dispositivo, String navegador, String metadata);

    // Actualizar heartbeat / presencia
    void actualizarHeartbeat(String email, String seccionActual, String urlActual);

    // Obtener estado en tiempo real de un usuario específico
    Map<String, Object> obtenerEstadoUsuario(String usuarioIdOrEmail);

    // Obtener últimos eventos de un usuario
    List<UsuarioActividad> obtenerHistorialUsuario(String usuarioIdOrEmail, int limite);

    // Obtener historial paginado
    Page<UsuarioActividad> obtenerHistorialPaginado(String usuarioIdOrEmail, int pagina, int tamano);

    // Obtener lista de todos los usuarios con su estado online/offline resumido
    List<Map<String, Object>> obtenerListaUsuariosSupervision(String busqueda);

    // --- ACCIONES ADMINISTRATIVAS DE SEGURIDAD ---
    Map<String, Object> cerrarSesionesUsuario(String usuarioIdOrEmail, String adminEmail, String motivo, String ip);

    Map<String, Object> suspenderUsuario(String usuarioIdOrEmail, String adminEmail, String tipoSuspension, 
                                        Integer duracionMinutos, String motivo, String ip);

    Map<String, Object> reactivarUsuario(String usuarioIdOrEmail, String adminEmail, String motivo, String ip);

    Map<String, Object> dispararResetPasswordSeguro(String usuarioIdOrEmail, String adminEmail, String ip);

    // --- SESIÓN DELEGADA DE SOPORTE ADMINISTRATIVO (IMPERSONATION SEGURA) ---
    Map<String, Object> iniciarSesionSoporte(String usuarioIdOrEmail, String adminEmail, String motivo, Integer duracionMinutos, String ip);

    Map<String, Object> finalizarSesionSoporte(String usuarioIdOrEmail, String adminEmail, String ip);

    Map<String, Object> obtenerSesionSoporteActiva(String adminEmail);

    // Obtener historial de auditoría de un usuario
    List<com.clinicaapp.model.AuditoriaSupervision> obtenerAuditoriasUsuario(String usuarioIdOrEmail);
}
