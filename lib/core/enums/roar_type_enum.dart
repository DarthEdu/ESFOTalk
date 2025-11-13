enum RoarType {
  text('text'),
  image('image');

  final String type;
  const RoarType(this.type);

  static RoarType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'image':
        return RoarType.image;
      case 'text':
      default:
        return RoarType.text;
    }
  }
}

extension RoarTypeParsing on String {
  RoarType toRoarTypeEnum() => RoarType.fromString(this);
}
