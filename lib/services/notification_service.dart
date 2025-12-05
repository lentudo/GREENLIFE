import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/timezone.dart' as tz;

// --- MANEJADOR DE SEGUNDO PLANO ---
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Manejo de mensaje FCM en segundo plano: ${message.messageId}");
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- INICIALIZACIÓN ---
  Future<void> initialize() async {
    // 1. Configuración Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notificación local tocada: ${response.payload}");
      },
    );

    // 2. Permisos FCM
    await _fcm.requestPermission();

   
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _saveDeviceToken();
      }
    });

    if (_auth.currentUser != null) {
      await _saveDeviceToken();
    }

    _setupFCMListeners();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // --- GUARDAR TOKEN EN FIRESTORE ---

  Future<void> _saveDeviceToken() async {
    try {
      String? token = await _fcm.getToken();
      final userId = _auth.currentUser?.uid;

      if (userId != null && token != null) {
        await _db.collection('users').doc(userId).update({
          'tokenNotificacion': token,
        }); 

        print('✅ Token guardado en campo tokenNotificacion para: $userId');
      }
    } catch (e) {
      print("Error guardando token: $e");
    }
  }

  

  void _setupFCMListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación FCM recibida en primer plano');
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App abierta desde notificación FCM');
    });
  }

  void _showLocalNotification(RemoteMessage message) {
    _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'greenlife_channel',
          'Notificaciones Generales',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: message.data.toString(),
    );
  }

// --- LÓGICA DE RECORDATORIOS (CUIDADO DE PLANTAS) ---

  Future<void> schedulePlantReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduleTime,
  }) async {

    

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      scheduleTime.toUtc(),
      tz.UTC,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'plant_care_channel_v99', 
          'Recordatorios de Riego', 
          channelDescription: 'Canal para recordatorios de cuidado de plantas',
          importance: Importance.max, 
          priority: Priority.high,   
          playSound: true,            
        ),
      ),

      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("🌱 Recordatorio programado en UTC para: $scheduledDate");
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
  // --- FUNCIÓN DE PRUEBA INMEDIATA ---
  Future<void> showInstantNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'test_channel_id', // ID diferente para probar
      'Canal de Prueba',
      channelDescription: 'Este canal es para probar que las alertas funcionan',
      importance: Importance.max, 
      priority: Priority.high,   
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      888, // ID fijo para pruebas
      '🔔 ¡Ding Dong!',
      '¡El sistema de notificaciones está funcionando!',
      notificationDetails,
    );
  }
}