enum RoarType {
  text('text'),
  image('image');

  final String type;
  const RoarType(this.type);
}

extension ConvertRoar on String {
  RoarType toRoarTypeEnum() {
    switch (this) {
      case 'text':
        return RoarType.text;
      case 'image':
        return RoarType.image;
      default:
        return RoarType.text;
    }
  }
}