package com.clinicaapp.service;

import com.clinicaapp.model.LogActividad;
import org.springframework.data.domain.Page;
import java.util.List;

public interface LogActividadService {

    // Registro manual completo
    void registrar(String usuario, String accion, String modulo, String tipo, String detalles, String ip);

    // Registro automático (obtiene dinámicamente el usuario autenticado y la dirección IP de la petición HTTP)
    void registrarAuto(String accion, String modulo, String tipo, String detalles);

    // Obtener los últimos 5 logs para el panel principal del Control Core
    List<LogActividad> obtenerUltimos5();

    // Obtener logs paginados con filtros de texto, módulo y criticidad
    Page<LogActividad> buscarLogsPaginados(String query, String modulo, String tipo, int pagina, int tamano);

    // Vaciar historial de logs (protegido)
    void limpiarLogs();
}
