import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Menginisialisasi notifikasi lokal dan meminta izin pengiriman notifikasi
  static Future<void> initialize() async {
    if (kIsWeb) return; // Notifikasi lokal tidak dijalankan di web browser biasa

    // Pengaturan inisialisasi untuk Android menggunakan ikon aplikasi bawaan
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Pengaturan inisialisasi untuk iOS (Darwin)
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Inisialisasi plugin
    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Logika saat notifikasi diklik (jika ingin diarahkan ke halaman tertentu)
      },
    );

    // Meminta izin notifikasi secara proaktif
    await requestPermissions();
  }

  /// Meminta izin notifikasi secara dinamis di Android (13+) dan iOS
  static Future<void> requestPermissions() async {
    if (kIsWeb) return;

    try {
      if (Platform.isAndroid) {
        await _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } else if (Platform.isIOS) {
        await _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
    } catch (e) {
      // Abaikan jika platform tidak mendukung API spesifik ini
    }
  }

  /// Menampilkan notifikasi lokal instan
  static Future<void> showNotification(String title, String body) async {
    if (kIsWeb) return;

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'mothra_scan_channel_id',
      'Mothra Scan Notifications',
      channelDescription: 'Notifications for Mothra App butterfly scan results',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotificationsPlugin.show(
      DateTime.now().millisecond, // ID unik berdasarkan milidetik agar notifikasi tidak saling menimpa
      title,
      body,
      notificationDetails,
    );
  }
}
