package com.clinicaapp.service;

import com.clinicaapp.model.Recordatorio;
import java.util.List;

public interface IRecordatorioService {
    Recordatorio guardar(Recordatorio recordatorio);
    List<Recordatorio> listarPorUsuario(String usuarioId);
    void eliminar(String id);
    void procesarRecordatoriosPendientes();
    void enviarAhora(String id);
}
