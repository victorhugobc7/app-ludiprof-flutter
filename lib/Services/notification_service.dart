import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:app_ludiprof/Services/card_repository.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    // Request permissions for Android 13+
    _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
        
    _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();

    _initialized = true;
  }

  Future<void> scheduleNextReviewNotification(CardRepository cardRepo) async {
    if (!_initialized) return;

    final allCards = cardRepo.getAllCards();
    if (allCards.isEmpty) return;

    DateTime? earliestDueDate;

    for (final card in allCards) {
      if (card.fsrsData.isNotEmpty) {
        final dueString = card.fsrsData['due'];
        if (dueString != null) {
          final dueDate = DateTime.parse(dueString);
          if (dueDate.isAfter(DateTime.now())) {
            if (earliestDueDate == null || dueDate.isBefore(earliestDueDate)) {
              earliestDueDate = dueDate;
            }
          }
        }
      }
    }

    // Cancel existing scheduled notifications before creating a new one
    await _flutterLocalNotificationsPlugin.cancelAll();

    if (earliestDueDate != null) {
      debugPrint('Scheduling notification for $earliestDueDate');
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'ludiprof_reviews',
        'Revisões Pendentes',
        channelDescription: 'Notificações para cards que precisam de revisão',
        importance: Importance.max,
        priority: Priority.high,
      );
      
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 0,
        title: 'Hora de Estudar!',
        body: 'Você tem Decks pendentes de revisão. Mantenha sua ofensiva!',
        scheduledDate: tz.TZDateTime.from(earliestDueDate, tz.local),
        notificationDetails: platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }
}
