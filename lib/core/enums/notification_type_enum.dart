enum NotificationType {
  like('like'),
  reply('reply'),
  follow('follow'),
  reroar('reroar');

  final String type;
  const NotificationType(this.type);
}

extension ConvertRoar on String {
  NotificationType toNotificationTypeEnum() {
    switch (this) {
      case 'reroar':
        return NotificationType.reroar;
      case 'follow':
        return NotificationType.follow;
      case 'reply':
        return NotificationType.reply;
      default:
        return NotificationType.like;
    }
  }
}
