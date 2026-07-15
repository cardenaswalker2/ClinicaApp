import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../models/notificacion.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  List<Notificacion> _notifications = [];
  bool _isLoading = true;

  // ─── Luxury Aurora Palette ───
  static const Color _auroraBase = Color(0xFF0EA5E9);
  static const Color _auroraAccent = Color(0xFF22D3EE);
  static const Color _auroraGlow = Color(0xFF38BDF8);
  static const Color _bgDeep = Color(0xFF020617);
  static const Color _surfaceDark = Color(0xFF0F172A);
  static const Color _surfaceElevated = Color(0xFF1E293B);

  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fetchNotifications();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    try {
      final res = await http.get(
        Uri.parse(
            "${AppConfig.baseUrl}/notificaciones/usuario/${AppConfig.userEmail}"),
      );
      if (mounted) {
        setState(() {
          _notifications = (json.decode(res.body) as List)
              .map((e) => Notificacion.fromJson(e))
              .toList();
          _isLoading = false;
        });
        _listController.forward();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await http.post(
          Uri.parse("${AppConfig.baseUrl}/notificaciones/marcar-leida/$id"));
      _fetchNotifications();
    } catch (e) {
      // Error silencioso
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await http.post(
        Uri.parse("${AppConfig.baseUrl}/notificaciones/marcar-todas-leidas"),
      );
      _fetchNotifications();
    } catch (e) {
      // Error silencioso
    }
  }

  // ─── Glassmorphism Decoration ───
  BoxDecoration _glassDecoration({
    required bool isRead,
    bool glow = false,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isRead
            ? [
                Colors.white.withOpacity(0.03),
                Colors.white.withOpacity(0.01),
              ]
            : [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isRead
            ? Colors.white.withOpacity(0.05)
            : _auroraBase.withOpacity(0.4),
        width: isRead ? 1 : 1.5,
      ),
      boxShadow: [
        if (!isRead)
          BoxShadow(
            color: _auroraBase.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDeep,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Notificaciones",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          if (_notifications.any((n) => !n.leida))
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_auroraBase, _auroraAccent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _auroraBase.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _markAllAsRead,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            "Marcar todas",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _auroraBase.withOpacity(0.08),
              _bgDeep,
              _bgDeep,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            color: _auroraBase,
                            strokeWidth: 3,
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : _notifications.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchNotifications,
                      color: _auroraBase,
                      backgroundColor: _surfaceDark,
                      child: AnimatedBuilder(
                        animation: _listController,
                        builder: (context, child) {
                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final delay = index * 0.1;
                              final animationValue = (_listController.value - delay)
                                  .clamp(0.0, 1.0)
                                  .toDouble();
                              final curvedValue = Curves.easeOutQuart
                                  .transform(animationValue);

                              return Opacity(
                                opacity: curvedValue,
                                child: Transform.translate(
                                  offset: Offset(0, 40 * (1 - curvedValue)),
                                  child: _buildNotificationItem(
                                    _notifications[index],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutQuart,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          _auroraBase.withOpacity(0.2),
                          _auroraAccent.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _auroraBase.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_off_outlined,
                      size: 48,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "No tienes notificaciones",
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Te avisaremos cuando haya novedades importantes",
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.25),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(Notificacion n) {
    final bool isRead = n.leida;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _glassDecoration(isRead: isRead),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (!isRead) _markAsRead(n.id);
            },
            splashColor: _auroraBase.withOpacity(0.1),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'notif_${n.id}',
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: isRead
                            ? null
                            : const LinearGradient(
                                colors: [_auroraBase, _auroraAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        color: isRead ? Colors.white.withOpacity(0.05) : null,
                        shape: BoxShape.circle,
                        boxShadow: isRead
                            ? null
                            : [
                                BoxShadow(
                                  color: _auroraBase.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                      ),
                      child: Icon(
                        isRead
                            ? Icons.notifications_outlined
                            : Icons.notifications_active_rounded,
                        color: isRead ? Colors.white.withOpacity(0.3) : Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                n.titulo,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [_auroraBase, _auroraAccent],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _auroraBase.withOpacity(0.6),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          n.mensaje,
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: Colors.white.withOpacity(0.25),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(n.fecha),
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime fecha) {
    final now = DateTime.now();
    final difference = now.difference(fecha);

    if (difference.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Ayer, ${DateFormat('HH:mm').format(fecha)}';
    } else {
      return DateFormat('dd MMM, HH:mm').format(fecha);
    }
  }
}