import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static const auth = 'auth_box';
  static const employees = 'employees_box';
  static const attendance = 'attendance_box';
  static const events = 'events_box';
  static const offlineQueue = 'offline_queue_box';
  static const settings = 'settings_box';

  static Future<void> init() async {
    await Hive.openBox(auth);
    await Hive.openBox(employees);
    await Hive.openBox(attendance);
    await Hive.openBox(events);
    await Hive.openBox(offlineQueue);
    await Hive.openBox(settings);
  }

  static Box get authBox => Hive.box(auth);
  static Box get employeesBox => Hive.box(employees);
  static Box get attendanceBox => Hive.box(attendance);
  static Box get eventsBox => Hive.box(events);
  static Box get offlineBox => Hive.box(offlineQueue);
  static Box get settingsBox => Hive.box(settings);
}
