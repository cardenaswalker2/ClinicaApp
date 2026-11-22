import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/notificacion.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_widgets.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Notificacion> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final res = await http.get(
        Uri.parse("${AppConfig.baseUrl}/notificaciones/usuario/${AppConfig.userEmail}"),
      );
      if (mounted) {
        setState(() {
          if (res.statusCode == 200) {
            _notifications = (json.decode(res.body) as List).map((e) => Notificacion.fromJson(e)).toList();
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await http.post(Uri.parse("${AppConfig.baseUrl}/notificaciones/marcar-leida/$id"));
      _fetchNotifications();
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    try {
      await http.post(Uri.parse("${AppConfig.baseUrl}/notificaciones/marcar-todas-leidas"));
      _fetchNotifications();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleTheme.bg,
      appBar: AppBar(
        title: const Text("Notificaciones"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              "Leer todas",
              style: GoogleFonts.plusJakartaSans(color: AppleTheme.blue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppleTheme.blue))
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              color: AppleTheme.blue,
              child: _notifications.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 60),
                        AppleCard(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              const AppleIconBox(icon: Icons.notifications_none_rounded, color: AppleTheme.blue, size: 58, iconSize: 28),
                              const SizedBox(height: 14),
                              Text(
                                "Todo al día",
                                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppleTheme.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "No tienes notificaciones nuevas.",
                                style: GoogleFonts.plusJakartaSans(color: AppleTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                      itemCount: _notifications.length,
                      itemBuilder: (context, idx) {
                        final n = _notifications[idx];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppleCard(
                            onTap: () {
                              if (!n.leida) _markAsRead(n.id);
                            },
                            padding: const EdgeInsets.all(16),
                            border: n.leida
                                ? null
                                : Border.all(color: AppleTheme.blue.withValues(alpha: 0.4), width: 1.2),
                            child: Row(
                              children: [
                                AppleIconBox(
                                  icon: n.leida ? Icons.notifications_outlined : Icons.notifications_active_rounded,
                                  color: n.leida ? AppleTheme.textSecondary : AppleTheme.blue,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n.titulo,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: n.leida ? FontWeight.w600 : FontWeight.w700,
                                          color: AppleTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        n.mensaje,
                                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppleTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!n.leida)
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: const BoxDecoration(color: AppleTheme.blue, shape: BoxShape.circle),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
