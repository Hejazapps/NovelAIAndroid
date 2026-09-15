import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService shared = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _permissionRequested = false;

  Future<void> prepare() async {
    if (!_initialized) {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings);
      _initialized = true;
    }

    if (!_permissionRequested) {
      _permissionRequested = true;
      if (Platform.isAndroid) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } else if (Platform.isIOS) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }
    }
  }

  Future<void> showBookCompleted(String title, int chapterCount) async {
    await prepare();
    await _show(
      id: 4101,
      title: 'Book Completed',
      body: '$title — all $chapterCount chapters are ready.',
    );
  }

  Future<void> showScreenplayCompleted(String title, int episodeCount) async {
    await prepare();
    await _show(
      id: 4102,
      title: 'Screenplay Completed',
      body: '$title — all $episodeCount episodes are ready.',
    );
  }

  Future<void> _show({
    required int id,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'generation_complete',
        'Generation Complete',
        channelDescription: 'Book and screenplay completion notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _plugin.show(id, title, body, details);
  }
}
