enum NotificationKind { order, promo, wallet, system }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final NotificationKind kind;
  final bool read;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.kind = NotificationKind.system,
    this.read = false,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    title: title,
    body: body,
    date: date,
    kind: kind,
    read: read ?? this.read,
  );
}
