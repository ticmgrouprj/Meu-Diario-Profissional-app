import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> inicializar() async {
    if (_initialized) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Abrir notificação',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      await _notifications.initialize(initSettings);
      _initialized = true;
    } catch (_) {
      // Ignora falhas em ambientes desktop sem suporte a daemon de notificação
    }
  }

  Future<void> dispararAlertaCritico({
    required String titulo,
    required String mensagem,
  }) async {
    // 1. Resposta háptica imediata no aparelho celular
    HapticFeedback.heavyImpact();

    // 2. Disparo de notificação local
    const androidDetails = AndroidNotificationDetails(
      'canal_alertas_criticos',
      'Alertas Clínicos de Emergência',
      channelDescription: 'Picos de PA e Hipoglicemias severas monitoradas',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      linux: LinuxNotificationDetails(),
    );

    try {
      await _notifications.show(
        DateTime.now().millisecond,
        titulo,
        mensagem,
        notificationDetails,
      );
    } catch (_) {
      // Se não inicializado ou sem permissão em emulador/desktop
    }
  }
}

