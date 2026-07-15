package com.clinicaapp.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class NetworkDeviceFilter extends OncePerRequestFilter {

    @Autowired
    private NetworkDeviceTracker deviceTracker;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String ip = request.getRemoteAddr();
        String path = request.getRequestURI();

        // 1. Register the device (ignore static assets and system APIs)
        if (!path.startsWith("/css/") && !path.startsWith("/js/") && !path.startsWith("/img/") &&
                !path.startsWith("/webjars/") && !path.startsWith("/api/system") && !path.equals("/error")) {
            
            String userAgent = request.getHeader("User-Agent");
            if (userAgent != null) {
                deviceTracker.registerDevice(ip, userAgent);
            }
        }

        // 2. Enforce Blacklist check (Revoked devices)
        if (deviceTracker.isBlacklisted(ip)) {
            // Safe fallback: never lock out localhost developer
            if (!ip.equals("127.0.0.1") && !ip.equals("0:0:0:0:0:0:0:1") && !ip.equals("localhost")) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().write(
                    "<html><head><title>Access Revoked | ClínicaApp</title>" +
                    "<style>" +
                    "body { background-color: #020617; color: #f1f5f9; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }" +
                    ".card { background: rgba(15, 23, 42, 0.8); border: 1.5px solid rgba(244, 63, 94, 0.4); border-radius: 20px; padding: 40px; text-align: center; max-width: 480px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5), 0 0 30px rgba(244, 63, 94, 0.15); }" +
                    ".icon { font-size: 3.5rem; color: #f43f5e; margin-bottom: 20px; }" +
                    "h1 { font-size: 1.8rem; margin: 0 0 12px 0; color: #f43f5e; font-weight: 700; }" +
                    "p { font-size: 0.95rem; color: #94a3b8; line-height: 1.6; margin: 0 0 24px 0; }" +
                    ".info { font-family: monospace; font-size: 0.8rem; background: rgba(0, 0, 0, 0.3); padding: 8px 14px; border-radius: 8px; color: #e2e8f0; display: inline-block; }" +
                    "</style></head><body>" +
                    "<div class='card'>" +
                    "<div class='icon'>🚫</div>" +
                    "<h1>Dispositivo Revocado</h1>" +
                    "<p>El administrador de la red ha revocado el acceso de este dispositivo a ClínicaApp. Si considera que esto es un error, por favor solicite al administrador que escanee o autorice el acceso nuevamente.</p>" +
                    "<div class='info'>IP Bloqueada: " + ip + "</div>" +
                    "</div>" +
                    "</body></html>"
                );
                return;
            }
        }

        // 3. Enforce PIN Protection check
        if (deviceTracker.isPinRequired()) {
            if (!ip.equals("127.0.0.1") && !ip.equals("0:0:0:0:0:0:0:1") && !ip.equals("localhost") &&
                    !path.startsWith("/css/") && !path.startsWith("/js/") && !path.startsWith("/img/") &&
                    !path.startsWith("/webjars/") && !path.startsWith("/api/system") && !path.equals("/error")) {
                
                if (!deviceTracker.isIpPinVerified(ip)) {
                    response.setContentType("text/html;charset=UTF-8");
                    response.getWriter().write(
                        "<!DOCTYPE html><html><head><title>PIN Gateway | ClínicaApp</title>" +
                        "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
                        "<link rel='stylesheet' href='https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css'>" +
                        "<style>" +
                        ":root { --bg: #020617; --surface: #0f172a; --primary: #00d4ff; --danger: #f43f5e; --success: #10b981; --text: #f1f5f9; --border: rgba(148, 163, 184, 0.15); }" +
                        "body { background-color: var(--bg); color: var(--text); font-family: 'Segoe UI', system-ui, sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; overflow: hidden; }" +
                        "body::before { content: ''; position: absolute; width: 100%; height: 100%; background-image: linear-gradient(rgba(0, 212, 255, 0.02) 1px, transparent 1px), linear-gradient(90deg, rgba(0, 212, 255, 0.02) 1px, transparent 1px); background-size: 40px 40px; z-index: -1; }" +
                        ".gateway-card { background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px); border: 1px solid var(--border); padding: 36px; border-radius: 24px; text-align: center; width: 90%; max-width: 380px; box-shadow: 0 15px 35px rgba(0, 0, 0, 0.5), 0 0 30px rgba(0, 212, 255, 0.1); transition: all 0.3s; }" +
                        ".logo-wrap { width: 54px; height: 54px; background: linear-gradient(135deg, var(--primary), #a855f7); border-radius: 14px; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px; font-size: 1.5rem; color: white; box-shadow: 0 0 20px rgba(0, 212, 255, 0.3); }" +
                        "h1 { font-size: 1.5rem; font-weight: 700; margin: 0 0 8px; letter-spacing: 0.5px; }" +
                        "p { font-size: 0.85rem; color: #94a3b8; margin: 0 0 28px; }" +
                        ".pin-dots { display: flex; justify-content: center; gap: 16px; margin-bottom: 30px; }" +
                        ".dot { width: 16px; height: 16px; border-radius: 50%; border: 2px solid #475569; transition: all 0.2s; }" +
                        ".dot.active { background: var(--primary); border-color: var(--primary); box-shadow: 0 0 10px var(--primary); transform: scale(1.1); }" +
                        ".dot.error { background: var(--danger); border-color: var(--danger); box-shadow: 0 0 10px var(--danger); }" +
                        ".dot.success { background: var(--success); border-color: var(--success); box-shadow: 0 0 10px var(--success); }" +
                        ".keypad { display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; max-width: 260px; margin: 0 auto; }" +
                        ".key { background: rgba(255, 255, 255, 0.03); border: 1px solid var(--border); border-radius: 14px; height: 56px; display: flex; align-items: center; justify-content: center; font-size: 1.25rem; font-weight: 600; cursor: pointer; user-select: none; transition: all 0.2s; }" +
                        ".key:hover { background: rgba(0, 212, 255, 0.1); border-color: var(--primary); color: var(--primary); transform: translateY(-2px); }" +
                        ".key:active { transform: translateY(1px); }" +
                        ".key.action-key { font-size: 1rem; color: #94a3b8; }" +
                        ".key.action-key:hover { color: var(--primary); }" +
                        "@keyframes shake { 0%, 100% { transform: translateX(0); } 20%, 60% { transform: translateX(-10px); } 40%, 80% { transform: translateX(10px); } }" +
                        ".shake { animation: shake 0.4s ease-in-out; }" +
                        "</style></head><body>" +
                        "<div class='gateway-card' id='card'>" +
                        "<div class='logo-wrap'><i class='bi bi-shield-lock-fill'></i></div>" +
                        "<h1>Protección PIN</h1>" +
                        "<p>Introduce el PIN de 4 dígitos para ingresar.</p>" +
                        "<div class='pin-dots'>" +
                        "<div class='dot' id='dot1'></div><div class='dot' id='dot2'></div><div class='dot' id='dot3'></div><div class='dot' id='dot4'></div>" +
                        "</div>" +
                        "<div class='keypad'>" +
                        "<div class='key' onclick='pressNum(\"1\")'>1</div><div class='key' onclick='pressNum(\"2\")'>2</div><div class='key' onclick='pressNum(\"3\")'>3</div>" +
                        "<div class='key' onclick='pressNum(\"4\")'>4</div><div class='key' onclick='pressNum(\"5\")'>5</div><div class='key' onclick='pressNum(\"6\")'>6</div>" +
                        "<div class='key' onclick='pressNum(\"7\")'>7</div><div class='key' onclick='pressNum(\"8\")'>8</div><div class='key' onclick='pressNum(\"9\")'>9</div>" +
                        "<div class='key action-key' onclick='clearPin()'><i class='bi bi-x-lg'></i></div>" +
                        "<div class='key' onclick='pressNum(\"0\")'>0</div>" +
                        "<div class='key action-key' onclick='backspace()'><i class='bi bi-backspace-fill'></i></div>" +
                        "</div></div>" +
                        "<script>" +
                        "let pin = '';" +
                        "const dots = [document.getElementById('dot1'), document.getElementById('dot2'), document.getElementById('dot3'), document.getElementById('dot4')];" +
                        "const card = document.getElementById('card');" +
                        "function updateDots() { dots.forEach((dot, idx) => { if (idx < pin.length) { dot.classList.add('active'); } else { dot.classList.remove('active'); } }); }" +
                        "function pressNum(num) { if (pin.length < 4) { pin += num; updateDots(); playBeep(800, 0.05); if (pin.length === 4) { verifyPin(); } } }" +
                        "function clearPin() { pin = ''; updateDots(); playBeep(400, 0.05); }" +
                        "function backspace() { if (pin.length > 0) { pin = pin.slice(0, -1); updateDots(); playBeep(600, 0.05); } }" +
                        "function verifyPin() { " +
                        "  fetch('/api/system/verify-pin?pin=' + pin, { method: 'POST' })" +
                        "    .then(res => res.json())" +
                        "    .then(data => {" +
                        "      if (data.success) {" +
                        "        dots.forEach(d => { d.className = 'dot success'; });" +
                        "        playBeep(1200, 0.15);" +
                        "        setTimeout(() => { window.location.reload(); }, 500);" +
                        "      } else {" +
                        "        dots.forEach(d => { d.className = 'dot error'; });" +
                        "        card.classList.add('shake');" +
                        "        playErrorBeep();" +
                        "        setTimeout(() => {" +
                        "          card.classList.remove('shake');" +
                        "          pin = '';" +
                        "          dots.forEach((d) => { d.className = 'dot'; });" +
                        "          updateDots();" +
                        "        }, 800);" +
                        "      }" +
                        "    });" +
                        "}" +
                        "const audioCtx = new (window.AudioContext || window.webkitAudioContext)();" +
                        "function playBeep(freq, duration) { try { if (audioCtx.state === 'suspended') audioCtx.resume(); const osc = audioCtx.createOscillator(); const gain = audioCtx.createGain(); osc.connect(gain); gain.connect(audioCtx.destination); osc.frequency.value = freq; gain.gain.setValueAtTime(0.04, audioCtx.currentTime); gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + duration); osc.start(); osc.stop(audioCtx.currentTime + duration); } catch(e){} }" +
                        "function playErrorBeep() { try { if (audioCtx.state === 'suspended') audioCtx.resume(); const osc = audioCtx.createOscillator(); const gain = audioCtx.createGain(); osc.connect(gain); gain.connect(audioCtx.destination); osc.type = 'sawtooth'; osc.frequency.setValueAtTime(150, audioCtx.currentTime); gain.gain.setValueAtTime(0.1, audioCtx.currentTime); gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.35); osc.start(); osc.stop(audioCtx.currentTime + 0.35); } catch(e){} }" +
                        "document.addEventListener('keydown', function(event) { const key = event.key; if (key >= '0' && key <= '9') { pressNum(key); } else if (key === 'Backspace') { backspace(); } else if (key === 'Escape' || key === 'Delete') { clearPin(); } });" +
                        "</script></body></html>"
                    );
                    return;
                }
            }
        }

        filterChain.doFilter(request, response);
    }
}
