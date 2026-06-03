import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'prayer_time_service.dart';
import '../models/city.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Android Initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization settings
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    try {
      // Initialize timezone database for zoned notifications
      tz.initializeTimeZones();
      debugPrint("[Notification Diagnostics] Timezone database initialized successfully.");

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint("[Notification Diagnostics] Notification clicked with payload: ${details.payload}");
        },
      );

      // Create Android Notification Channels
      await _createNotificationChannels();
    } catch (e) {
      debugPrint("Error initializing notifications: $e");
    }
  }

  Future<void> _createNotificationChannels() async {
    // 1. Fard Prayer Adhan channel
    const AndroidNotificationChannel fardChannel = AndroidNotificationChannel(
      'fard_prayers', // id
      'Fard Salah Adhan Alarms', // name
      description: 'Plays the beautiful Adhan call to prayer at Salah times.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    // 2. 15-minute warning channel
    const AndroidNotificationChannel warningChannel = AndroidNotificationChannel(
      'prayer_warnings',
      'Salah Preparation Reminders',
      description: 'Reminders 15 minutes before Salah times.',
      importance: Importance.high,
      playSound: true,
    );

    // 3. Sunnah alarms channel
    const AndroidNotificationChannel sunnahChannel = AndroidNotificationChannel(
      'sunnah_prayers',
      'Sunnah Reminders',
      description: 'Reminders for Tahajjud, Duha, and Witr prayers.',
      importance: Importance.defaultImportance,
      playSound: false, // No sound as requested
    );

    // 4. Daily reminders
    const AndroidNotificationChannel dailyChannel = AndroidNotificationChannel(
      'daily_reminders',
      'Spiritual Reminders & Adhkar',
      description: 'Daily morning/evening adhkar and Friday Surah Al-Kahf reminders.',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(fardChannel);
      await androidImplementation.createNotificationChannel(warningChannel);
      await androidImplementation.createNotificationChannel(sunnahChannel);
      await androidImplementation.createNotificationChannel(dailyChannel);
      debugPrint("[Notification Diagnostics] Android notification channels created.");
    }
  }

  Future<void> requestPermissions() async {
    try {
      // For Android 13+
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      // For iOS
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      debugPrint("[Notification Diagnostics] Permissions requested successfully.");
    } catch (e) {
      debugPrint("Error requesting notification permissions: $e");
    }
  }

  // Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint("[Notification Diagnostics] Cancelled all scheduled notifications.");
  }

  // Show a standard instant notification (e.g. preview)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminders',
      'Spiritual Reminders & Adhkar',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(id, title, body, details, payload: payload);
  }

  // Schedule notifications for prayer times
  Future<void> syncPrayerNotifications(City city, Map<String, DateTime> prayerTimes) async {
    await cancelAllNotifications(); // Clear old notifications to avoid overlap

    final now = DateTime.now();
    int idCounter = 100;
    final prefs = await SharedPreferences.getInstance();

    debugPrint("[Notification Diagnostics] Syncing notifications for ${city.name} at ${now.toIso8601String()}");

    // Setup Fard Prayer Notifications
    for (var entry in prayerTimes.entries) {
      final name = entry.key;
      final time = entry.value;

      // Skip Sunrise for obligatory prayer notifications
      if (name == 'Sunrise') continue;

      if (time.isAfter(now)) {
        // 1. Alarm exactly at prayer time with adhan sound
        final alarmEnabled = prefs.getBool('alarm_$name') ?? (name != "Dhuhr");
        if (alarmEnabled) {
          final service = PrayerTimeService();
          final selectedStyle = service.selectedAdhanStyle;
          final adhanUrl = service.adhanUrls[selectedStyle] ?? 'https://www.islamcan.com/audio/adhan/azan2.mp3';

          await _schedulePrayerAlarm(
            id: idCounter++,
            title: "Time for $name Salah",
            body: "The call to worship has commenced. Let us rise and pray.",
            time: time,
            channelId: 'fard_prayers',
            soundUrl: adhanUrl,
            silent: false,
          );
        }

        // 2. Alarm 15 minutes before prayer (silent warning)
        final warningEnabled = prefs.getBool('warning_15_mins_$name') ?? true;
        if (warningEnabled) {
          final warningTime = time.subtract(const Duration(minutes: 15));
          if (warningTime.isAfter(now)) {
            await _schedulePrayerAlarm(
              id: idCounter++,
              title: "15 mins to $name",
              body: "Prepare for your meeting with the Creator. Make wudu now.",
              time: warningTime,
              channelId: 'prayer_warnings',
              silent: true,
            );
          }
        }
      }
    }

    // Schedule Sunnah Alarms for today
    await _syncSunnahAlarms(prayerTimes, idCounter);

    // Schedule Friday/Jumu'ah weekly reminder
    await _scheduleFridayReminder(idCounter + 50);
  }

  Future<void> _syncSunnahAlarms(Map<String, DateTime> todayTimes, int startId) async {
    final now = DateTime.now();
    int id = startId;
    final prefs = await SharedPreferences.getInstance();

    final fajr = todayTimes['Fajr'];
    final sunrise = todayTimes['Sunrise'];
    final dhuhr = todayTimes['Dhuhr'];
    final isha = todayTimes['Isha'];

    debugPrint("[Notification Diagnostics] Syncing Sunnah reminders...");

    // 1. Before Fajr Sunnah (20 minutes before Fajr)
    if (fajr != null) {
      final alarmEnabled = prefs.getBool('sunnah_alarm_beforeFajr') ?? true;
      if (alarmEnabled) {
        final time = fajr.subtract(const Duration(minutes: 20));
        if (time.isAfter(now)) {
          await _schedulePrayerAlarm(
            id: id++,
            title: "Before Fajr Sunnah",
            body: "Time for Fajr Sunnah prayer. Two Rak'ahs are better than this world and its contents.",
            time: time,
            channelId: 'sunnah_prayers',
            silent: true,
          );
        }
      }
    }

    // 2. Duha Alarm (1.5 hours after Sunrise)
    if (sunrise != null) {
      final alarmEnabled = prefs.getBool('sunnah_alarm_duha') ?? false;
      if (alarmEnabled) {
        final time = sunrise.add(const Duration(hours: 1, minutes: 30));
        if (time.isAfter(now)) {
          await _schedulePrayerAlarm(
            id: id++,
            title: "Duha Prayer Time",
            body: "Perform Duha prayer to fulfill the daily charity for all your joints.",
            time: time,
            channelId: 'sunnah_prayers',
            silent: true,
          );
        }
      }
    }

    // 3. Before Dhuhr Sunnah (20 minutes before Dhuhr)
    if (dhuhr != null) {
      final alarmEnabled = prefs.getBool('sunnah_alarm_beforeDhuhr') ?? false;
      if (alarmEnabled) {
        final time = dhuhr.subtract(const Duration(minutes: 20));
        if (time.isAfter(now)) {
          await _schedulePrayerAlarm(
            id: id++,
            title: "Before Dhuhr Sunnah",
            body: "Prepare to establish the voluntary 4 Rak'ahs before Dhuhr Salah.",
            time: time,
            channelId: 'sunnah_prayers',
            silent: true,
          );
        }
      }
    }

    // 4. Tahajjud Alarm (1 hour before Fajr)
    if (fajr != null) {
      final alarmEnabled = prefs.getBool('sunnah_alarm_tahajjud') ?? true;
      if (alarmEnabled) {
        final time = fajr.subtract(const Duration(hours: 1));
        if (time.isAfter(now)) {
          await _schedulePrayerAlarm(
            id: id++,
            title: "Blessed Tahajjud Time",
            body: "Rise for Tahajjud. Pray in the silent third of the night.",
            time: time,
            channelId: 'sunnah_prayers',
            silent: true,
          );
        }
      }
    }

    // 5. Witr Reminder (1 hour after Isha)
    if (isha != null) {
      final alarmEnabled = prefs.getBool('sunnah_alarm_witr') ?? true;
      if (alarmEnabled) {
        final time = isha.add(const Duration(hours: 1));
        if (time.isAfter(now)) {
          await _schedulePrayerAlarm(
            id: id++,
            title: "Witr Prayer Reminder",
            body: "Do not sleep before establishing your odd-numbered Witr prayer.",
            time: time,
            channelId: 'sunnah_prayers',
            silent: true,
          );
        }
      }
    }
  }

  Future<void> _scheduleFridayReminder(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('friday_jumuah_reminder') ?? true;
    if (!enabled) return;

    try {
      final now = DateTime.now();
      int daysUntilFriday = (DateTime.friday - now.weekday + 7) % 7;
      if (daysUntilFriday == 0 && (now.hour > 11 || (now.hour == 11 && now.minute >= 30))) {
        daysUntilFriday = 7;
      }
      final fridayDate = now.add(Duration(days: daysUntilFriday));
      final fridayTime = DateTime(fridayDate.year, fridayDate.month, fridayDate.day, 11, 30);
      final scheduledTime = tz.TZDateTime.from(fridayTime, tz.local);

      final androidDetails = const AndroidNotificationDetails(
        'daily_reminders',
        'Spiritual Reminders & Adhkar',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(),
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        "Blessed Friday Reminder",
        "Read Surah Al-Kahf and send abundance of Salawat upon the Prophet (PBUH).",
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      debugPrint("[Notification Diagnostics] Scheduled weekly Friday Jumu'ah reminder for $scheduledTime");
    } catch (e) {
      debugPrint("Error scheduling Friday reminder: $e");
    }
  }

  Future<void> _schedulePrayerAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required String channelId,
    String? soundUrl,
    bool silent = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'fard_prayers' ? 'Fard Salah Alarms' : 'Salah Reminders',
      importance: silent ? Importance.low : Importance.max,
      priority: silent ? Priority.low : Priority.high,
      playSound: !silent,
      sound: (!silent && channelId == 'fard_prayers' && soundUrl != null)
          ? UriAndroidNotificationSound(soundUrl)
          : null,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: !silent,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      final scheduledTime = tz.TZDateTime.from(time, tz.local);
      if (scheduledTime.isBefore(DateTime.now())) {
        debugPrint("[Notification Diagnostics] Skipping past time notification $id at $scheduledTime");
        return;
      }

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint("[Notification Diagnostics] Zoned alarm $id scheduled successfully for $scheduledTime. Silent: $silent");
    } catch (e) {
      debugPrint("[Notification Diagnostics] Failed scheduling zoned alarm $id: $e");
    }
  }
}
