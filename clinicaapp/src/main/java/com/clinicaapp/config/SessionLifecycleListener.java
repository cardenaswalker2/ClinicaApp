package com.clinicaapp.config;

import com.clinicaapp.service.UserSessionTracker;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationListener;
import org.springframework.security.core.session.SessionDestroyedEvent;
import org.springframework.stereotype.Component;

@Component
public class SessionLifecycleListener implements ApplicationListener<SessionDestroyedEvent> {

    @Autowired
    private UserSessionTracker sessionTracker;

    @Override
    public void onApplicationEvent(SessionDestroyedEvent event) {
        sessionTracker.removeSession(event.getId());
    }
}
