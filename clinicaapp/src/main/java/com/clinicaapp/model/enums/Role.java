package com.clinicaapp.model.enums;

public enum Role {
    ROLE_ADMIN,          // Superadmin de la plataforma SaaS
    ROLE_USER,           // Cliente / Propietario de mascota
    ROLE_RECEPCIONISTA,  // Recepcionista de clínica
    ROLE_CLINICA,        // Administrador de la clínica (Dueño/Socio)
    ROLE_VETERINARIO,    // Veterinario
    ROLE_AUXILIAR,       // Auxiliar veterinario
    ROLE_ESTILISTA,      // Estilista / Peluquero canino
    ROLE_ADMIN_INTERNO   // Administrador interno o gestor adicional
}