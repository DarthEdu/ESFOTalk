enum NotificationType {
  like('like'),
  reply('reply'),
  follow('follow'),
  reroar('reroar');

  final String type;
  const NotificationType(this.type);

  static NotificationType fromString(String value) {
    switch (value) {
      case 'retweet': // alias del repo de referencia: mapear al dominio "reroar"
        return NotificationType.reroar;
      case 'reroar':
        return NotificationType.reroar;
      case 'follow':
        return NotificationType.follow;
      case 'reply':
        return NotificationType.reply;
      case 'like':
      default:
        return NotificationType.like;
    }
  }
}

extension NotificationTypeParsing on String {
  NotificationType toNotificationTypeEnum() =>
      NotificationType.fromString(toLowerCase());
}
