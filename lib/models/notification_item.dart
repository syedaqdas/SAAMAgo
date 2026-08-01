import 'package:flutter/material.dart';

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color color;
  final bool isRead;

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      time: time,
      icon: icon,
      color: color,
      isRead: isRead ?? this.isRead,
    );
  }
}
