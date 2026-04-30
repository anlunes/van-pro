import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Serviço de notificações push (FCM).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _msg = FirebaseMessaging.instance;

  /// Inicializa o serviço de notificações.
  Future<void> inicializar() async {
    // Request permission (iOS)
    final settings = await _msg.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('[NotificationService] Permissão concedida');
    } else {
      debugPrint('[NotificationService] Permissão negada');
    }

    // Handler de mensagens em foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handler quando app é aberto por notificação
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  }

  /// Pega o FCM token do dispositivo.
  Future<String?> getToken() async {
    return await _msg.getToken();
  }

  /// Subscribe a um topic (ex: "van_ABC123").
  Future<void> subscribe(String topic) async {
    await _msg.subscribeToTopic(topic);
  }

  /// Unsubscribe de um topic.
  Future<void> unsubscribe(String topic) async {
    await _msg.unsubscribeFromTopic(topic);
  }

  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('[NotificationService] Foreground: ${message.notification?.title}');
    // TODO: Mostrar in-app notification banner
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('[NotificationService]Opened by: ${message.notification?.title}');
    // TODO: Navegar para a tela correta
  }
}
