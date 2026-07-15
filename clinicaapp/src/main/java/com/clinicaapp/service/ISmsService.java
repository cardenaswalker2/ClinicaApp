package com.clinicaapp.service;

public interface ISmsService {
    // Envía un SMS a un número de teléfono
    void sendSms(String toPhoneNumber, String message);
    
    // Envía un mensaje de WhatsApp a un número de teléfono
    void sendWhatsApp(String toPhoneNumber, String message);
}