package com.clinicaapp.service;

import com.clinicaapp.model.MensajeChat;
import com.clinicaapp.model.Mascota;
import com.clinicaapp.model.PublicacionAdopcion;
import com.clinicaapp.model.enums.EstadoPublicacion;
import com.clinicaapp.repository.MensajeChatRepository;
import com.clinicaapp.repository.MascotaRepository;
import com.clinicaapp.repository.PublicacionAdopcionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ComunidadPetService {

    @Autowired
    private PublicacionAdopcionRepository publicacionRepository;

    @Autowired
    private MensajeChatRepository chatRepository;

    @Autowired
    private MascotaRepository mascotaRepository;

    // --- PUBLICACIONES ---

    public List<PublicacionAdopcion> getAllApproved() {
        return publicacionRepository.findByEstado(EstadoPublicacion.DISPONIBLE);
    }

    public List<PublicacionAdopcion> getPendingApproval() {
        return publicacionRepository.findByEstado(EstadoPublicacion.PENDIENTE);
    }

    public List<PublicacionAdopcion> getByPropietarioId(String propietarioId) {
        return publicacionRepository.findByPropietarioId(propietarioId);
    }

    public Optional<PublicacionAdopcion> getById(String id) {
        return publicacionRepository.findById(id);
    }

    public Optional<PublicacionAdopcion> getByIdAndIncrementVistas(String id) {
        Optional<PublicacionAdopcion> opt = publicacionRepository.findById(id);
        if (opt.isPresent()) {
            PublicacionAdopcion pub = opt.get();
            pub.setVistas(pub.getVistas() + 1);
            publicacionRepository.save(pub);
        }
        return opt;
    }

    public PublicacionAdopcion save(PublicacionAdopcion pub) {
        pub.setUltimaActualizacion(LocalDateTime.now());
        return publicacionRepository.save(pub);
    }

    public void delete(String id) {
        publicacionRepository.deleteById(id);
    }

    // Publicar reutilizando mascota existente
    public PublicacionAdopcion publicarMascotaRegistrada(String mascotaId, String propietarioId, String nombrePropietario) {
        Optional<Mascota> optMascota = mascotaRepository.findByIdAndPropietarioId(mascotaId, propietarioId);
        if (!optMascota.isPresent()) {
            throw new IllegalArgumentException("Mascota no encontrada o no pertenece al usuario.");
        }
        Mascota mascota = optMascota.get();

        PublicacionAdopcion pub = new PublicacionAdopcion();
        pub.setNombre(mascota.getNombre());
        pub.setEspecie(mascota.getEspecie() != null ? mascota.getEspecie().name() : "OTRO");
        
        String razaStr = "Desconocida";
        if (mascota.getEspecie() != null) {
            if (mascota.getEspecie() == com.clinicaapp.model.enums.Especie.PERRO && mascota.getRazaPerro() != null) {
                razaStr = mascota.getRazaPerro().name();
            } else if (mascota.getEspecie() == com.clinicaapp.model.enums.Especie.GATO && mascota.getRazaGato() != null) {
                razaStr = mascota.getRazaGato().name();
            }
        }
        if (mascota.getRazaPersonalizada() != null && !mascota.getRazaPersonalizada().isEmpty()) {
            razaStr = mascota.getRazaPersonalizada();
        }
        pub.setRaza(razaStr);

        // Edad calculada de fechaNacimiento
        String edadStr = "Desconocida";
        if (mascota.getFechaNacimiento() != null) {
            int años = java.time.Period.between(mascota.getFechaNacimiento(), java.time.LocalDate.now()).getYears();
            int meses = java.time.Period.between(mascota.getFechaNacimiento(), java.time.LocalDate.now()).getMonths();
            if (años > 0) {
                edadStr = años + " años" + (meses > 0 ? " y " + meses + " meses" : "");
            } else {
                edadStr = meses + " meses";
            }
        }
        pub.setEdad(edadStr);
        pub.setSexo(mascota.getSexo() != null ? mascota.getSexo() : "No especificado");
        pub.setFotoPrincipalUrl(mascota.getFotoUrl() != null ? mascota.getFotoUrl() : "/images/default-pet.png");
        
        if (mascota.getAlbumFotos() != null) {
            pub.setAlbumFotos(new ArrayList<>(mascota.getAlbumFotos()));
        }

        pub.setPropietarioId(propietarioId);
        pub.setNombrePublicador(nombrePropietario);
        pub.setTipoPublicador("USER");
        pub.setMascotaOriginalId(mascota.getId());
        pub.setEstado(EstadoPublicacion.PENDIENTE); // Requiere moderación

        // Intentar deducir si tiene vacunas de la lista de vacunas de la mascota
        if (mascota.getVacunas() != null && !mascota.getVacunas().isEmpty()) {
            pub.setVacunada(true);
        }

        return pub;
    }

    // --- MENSAJERÍA / CHAT ---

    public List<MensajeChat> getMessages(String adopcionId, String userA, String userB) {
        List<MensajeChat> all = chatRepository.findByAdopcionId(adopcionId);
        return all.stream()
                .filter(m -> (m.getEmisorId().equals(userA) && m.getReceptorId().equals(userB))
                          || (m.getEmisorId().equals(userB) && m.getReceptorId().equals(userA)))
                .sorted(Comparator.comparing(MensajeChat::getFechaHora))
                .collect(Collectors.toList());
    }

    public MensajeChat enviarMensaje(String adopcionId, String emisorId, String emisorNombre, 
                                      String receptorId, String receptorNombre, String contenido) {
        
        MensajeChat msg = new MensajeChat();
        msg.setAdopcionId(adopcionId);
        msg.setEmisorId(emisorId);
        msg.setEmisorNombre(emisorNombre);
        msg.setReceptorId(receptorId);
        msg.setReceptorNombre(receptorNombre);
        msg.setContenido(contenido);
        msg.setFechaHora(LocalDateTime.now());
        msg.setLeido(false);

        // Incrementar contador de interesados si es el primer mensaje de este emisor a este receptor en esta publicación
        List<MensajeChat> chatPrevio = chatRepository.findByAdopcionIdAndEmisorIdAndReceptorId(adopcionId, emisorId, receptorId);
        if (chatPrevio.isEmpty()) {
            Optional<PublicacionAdopcion> opt = publicacionRepository.findById(adopcionId);
            if (opt.isPresent()) {
                PublicacionAdopcion pub = opt.get();
                pub.setInteresados(pub.getInteresados() + 1);
                publicacionRepository.save(pub);
            }
        }

        return chatRepository.save(msg);
    }

    // Conversaciones activas de un usuario
    public List<Map<String, Object>> getConversacionesDeUsuario(String userId) {
        List<MensajeChat> todos = chatRepository.findByEmisorIdOrReceptorId(userId, userId);
        
        // Agrupar por adopcionId + el otro participante
        Map<String, List<MensajeChat>> agrupado = todos.stream()
                .collect(Collectors.groupingBy(m -> {
                    String otroId = m.getEmisorId().equals(userId) ? m.getReceptorId() : m.getEmisorId();
                    return m.getAdopcionId() + "_" + otroId;
                }));

        List<Map<String, Object>> result = new ArrayList<>();

        for (Map.Entry<String, List<MensajeChat>> entry : agrupado.entrySet()) {
            List<MensajeChat> msgs = entry.getValue();
            // Ordenar por fecha hora descendente para obtener el último mensaje
            msgs.sort(Comparator.comparing(MensajeChat::getFechaHora).reversed());
            MensajeChat ultimo = msgs.get(0);

            String adopId = ultimo.getAdopcionId();
            String otroId = ultimo.getEmisorId().equals(userId) ? ultimo.getReceptorId() : ultimo.getEmisorId();
            String otroNombre = ultimo.getEmisorId().equals(userId) ? ultimo.getReceptorNombre() : ultimo.getEmisorNombre();

            Optional<PublicacionAdopcion> optPub = publicacionRepository.findById(adopId);
            if (optPub.isPresent()) {
                PublicacionAdopcion pub = optPub.get();
                Map<String, Object> map = new HashMap<>();
                map.put("adopcionId", adopId);
                map.put("mascotaNombre", pub.getNombre());
                map.put("mascotaFoto", pub.getFotoPrincipalUrl());
                map.put("otroParticipanteId", otroId);
                map.put("otroParticipanteNombre", otroNombre);
                map.put("ultimoMensaje", ultimo.getContenido());
                map.put("fechaHora", ultimo.getFechaHora());
                
                long unreadCount = msgs.stream()
                        .filter(m -> !m.isLeido() && m.getReceptorId().equals(userId))
                        .count();
                map.put("noLeido", unreadCount > 0);
                map.put("cantidadNoLeidos", unreadCount);
                
                result.add(map);
            }
        }

        // Ordenar las conversaciones por la fecha del último mensaje
        result.sort((c1, c2) -> ((LocalDateTime) c2.get("fechaHora")).compareTo((LocalDateTime) c1.get("fechaHora")));

        return result;
    }

    public long getUnreadChatMessagesCount(String userId) {
        return chatRepository.countByReceptorIdAndLeido(userId, false);
    }

    public void marcarConversacionComoLeida(String adopcionId, String emisorId, String receptorId) {
        List<MensajeChat> msgs = chatRepository.findByAdopcionIdAndEmisorIdAndReceptorId(adopcionId, emisorId, receptorId);
        for (MensajeChat m : msgs) {
            m.setLeido(true);
        }
        chatRepository.saveAll(msgs);
    }
}
