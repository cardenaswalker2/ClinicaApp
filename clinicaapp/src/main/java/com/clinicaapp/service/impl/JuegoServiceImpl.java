package com.clinicaapp.service.impl;

import com.clinicaapp.model.MascotaVirtual;
import com.clinicaapp.repository.MascotaVirtualRepository;
import com.clinicaapp.service.IJuegoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;

@Service
public class JuegoServiceImpl implements IJuegoService {

    @Autowired
    private MascotaVirtualRepository repo;

    @Override
    public MascotaVirtual obtenerMascotaUsuario(String usuarioId) {
        MascotaVirtual mv = repo.findByUsuarioId(usuarioId)
                .orElseGet(() -> {
                    MascotaVirtual nueva = new MascotaVirtual(usuarioId, "Nova-Pet");
                    return repo.save(nueva);
                });
        
        sincronizarEstado(mv);
        actualizarRachaYExp(mv);
        return repo.save(mv);
    }

    @Override
    public void sincronizarEstado(MascotaVirtual mv) {
        LocalDateTime ahora = LocalDateTime.now();
        long minutosTranscurridos = Duration.between(mv.getUltimaActualizacion(), ahora).toMinutes();
        
        if (minutosTranscurridos > 0) {
            // Desgaste natural (ej: 0.1 de hambre por minuto = 6 por hora)
            mv.setHambre(mv.getHambre() + (minutosTranscurridos * 0.1));
            mv.setEnergia(mv.getEnergia() - (minutosTranscurridos * 0.05));
            
            // Penalización por negligencia
            if (mv.getHambre() > 80) {
                mv.setSalud(mv.getSalud() - (minutosTranscurridos * 0.05));
                mv.setFelicidad(mv.getFelicidad() - (minutosTranscurridos * 0.1));
            }
            
            mv.setUltimaActualizacion(ahora);
        }
    }

    @Override
    public MascotaVirtual realizarAccion(String usuarioId, String accion) {
        MascotaVirtual mv = obtenerMascotaUsuario(usuarioId);
        
        // Registrar racha y dar experiencia
        actualizarRachaYExp(mv);
        
        switch (accion.toUpperCase()) {
            case "FEED":
                mv.setHambre(mv.getHambre() - 30);
                mv.setSalud(mv.getSalud() + 5);
                ganarExperiencia(mv, 10);
                mv.setMonedas(mv.getMonedas() + 5);
                break;
            case "PLAY":
                if (mv.getEnergia() > 20) {
                    mv.setFelicidad(mv.getFelicidad() + 25);
                    mv.setEnergia(mv.getEnergia() - 15);
                    mv.setHambre(mv.getHambre() + 10);
                    ganarExperiencia(mv, 20);
                    mv.setMonedas(mv.getMonedas() + 15);
                }
                break;
            case "HEAL":
                mv.setSalud(mv.getSalud() + 40);
                mv.setFelicidad(mv.getFelicidad() - 10);
                ganarExperiencia(mv, 15);
                break;
            case "SLEEP":
                mv.setEnergia(100);
                ganarExperiencia(mv, 5);
                break;
        }
        
        mv.setUltimaActualizacion(LocalDateTime.now());
        mv.setUltimaAccion(LocalDateTime.now());
        return repo.save(mv);
    }

    private void actualizarRachaYExp(MascotaVirtual mv) {
        LocalDateTime ahora = LocalDateTime.now();
        if (mv.getUltimaAccion() == null) {
            mv.setRacha(1);
        } else {
            long horas = Duration.between(mv.getUltimaAccion(), ahora).toHours();
            if (horas >= 24 && horas < 48) {
                mv.setRacha(mv.getRacha() + 1);
                mv.setMonedas(mv.getMonedas() + (mv.getRacha() * 10)); // Bono por racha
            } else if (horas >= 48) {
                mv.setRacha(1);
            }
        }
    }

    private void ganarExperiencia(MascotaVirtual mv, int exp) {
        mv.setExperiencia(mv.getExperiencia() + exp);
        int xpParaNivel = mv.getNivel() * 100;
        if (mv.getExperiencia() >= xpParaNivel) {
            mv.setNivel(mv.getNivel() + 1);
            mv.setExperiencia(mv.getExperiencia() - xpParaNivel);
            mv.setMonedas(mv.getMonedas() + 100); // Premio por nivel
        }
    }
}
