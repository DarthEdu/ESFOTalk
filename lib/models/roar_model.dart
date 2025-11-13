import 'package:flutter/foundation.dart';
import 'package:esfotalk_app/core/enums/roar_type_enum.dart';

@immutable
class Roar {
  final String text;
  final List<String> hashtags;
  final String link;
  final List<String> imageLinks;
  final String uid;
  final RoarType roarType;
  final DateTime roaredAt;
  final List<String> likes;
  final List<String> commentIds;
  final String id;
  final int reshareCount;
  final String reroaredBy;
  final String repliedTo;

  const Roar({
    required this.text,
    required this.hashtags,
    required this.link,
    required this.imageLinks,
    required this.uid,
    required this.roarType,
    required this.roaredAt,
    required this.likes,
    required this.commentIds,
    required this.id,
    required this.reshareCount,
    required this.reroaredBy,
    required this.repliedTo,
  });

  Roar copyWith({
    String? text,
    List<String>? hashtags,
    String? link,
    List<String>? imageLinks,
    String? uid,
    RoarType? roarType,
    DateTime? roaredAt,
    List<String>? likes,
    List<String>? commentIds,
    String? id,
    int? reshareCount,
    String? reroaredBy,
    String? repliedTo,
  }) {
    return Roar(
      text: text ?? this.text,
      hashtags: hashtags ?? this.hashtags,
      link: link ?? this.link,
      imageLinks: imageLinks ?? this.imageLinks,
      uid: uid ?? this.uid,
      roarType: roarType ?? this.roarType,
      roaredAt: roaredAt ?? this.roaredAt,
      likes: likes ?? this.likes,
      commentIds: commentIds ?? this.commentIds,
      id: id ?? this.id,
      reshareCount: reshareCount ?? this.reshareCount,
      reroaredBy: reroaredBy ?? this.reroaredBy,
      repliedTo: repliedTo ?? this.repliedTo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'hashtags': hashtags,
      'link': link,
      'imageLinks': imageLinks,
      'uid': uid,
      // Guardamos sólo el nombre del enum para ser compatibles con schemas tipo enum/string
      'roarType': roarType.name,
      'roaredAt': roaredAt.millisecondsSinceEpoch,
      'likes': likes,
      'commentIds': commentIds,
      'reshareCount': reshareCount,
      'reroaredBy': reroaredBy,
      'repliedTo': repliedTo,
    };
  }

  factory Roar.fromMap(Map<String, dynamic> map) {
    return Roar(
      text: (map['text'] ?? '') as String,
      hashtags: List<String>.from((map['hashtags'] ?? const []) as List),
      link: (map['link'] ?? '') as String,
      imageLinks: List<String>.from((map['imageLinks'] ?? const []) as List),
      uid: (map['uid'] ?? '') as String,
      roarType: _parseType(map['roarType']),
      roaredAt: DateTime.fromMillisecondsSinceEpoch(
        (map['roaredAt'] is int) ? map['roaredAt'] as int : 0,
      ),
      likes: List<String>.from((map['likes'] ?? const []) as List),
      commentIds: List<String>.from((map['commentIds'] ?? const []) as List),
      id: (map['\$id'] ?? '') as String,
      reshareCount: (map['reshareCount'] ?? 0) as int,
      reroaredBy: (map['reroaredBy'] ?? '') as String,
      repliedTo: (map['repliedTo'] ?? '') as String,
    );
  }

  static RoarType _parseType(dynamic value) {
    if (value is String) {
      // Acepta formatos 'RoarType.image' y 'image'
      final normalized = value.contains('.') ? value.split('.').last : value;
      return RoarType.values.firstWhere(
        (e) => e.name == normalized,
        orElse: () => RoarType.text,
      );
    }
    return RoarType.text;
  }

  @override
  String toString() {
    return 'Roar(text: $text, hashtags: $hashtags, link: $link, imageLinks: $imageLinks, uid: $uid, roarType: $roarType, roaredAt: $roaredAt, likes: $likes, commentIds: $commentIds, id: $id, reshareCount: $reshareCount, reroaredBy: $reroaredBy, repliedTo: $repliedTo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Roar &&
        other.text == text &&
        listEquals(other.hashtags, hashtags) &&
        other.link == link &&
        listEquals(other.imageLinks, imageLinks) &&
        other.uid == uid &&
        other.roarType == roarType &&
        other.roaredAt == roaredAt &&
        listEquals(other.likes, likes) &&
        listEquals(other.commentIds, commentIds) &&
        other.id == id &&
        other.reshareCount == reshareCount &&
        other.reroaredBy == reroaredBy &&
        other.repliedTo == repliedTo;
  }

  @override
  int get hashCode {
    return text.hashCode ^
        hashtags.hashCode ^
        link.hashCode ^
        imageLinks.hashCode ^
        uid.hashCode ^
        roarType.hashCode ^
        roaredAt.hashCode ^
        likes.hashCode ^
        commentIds.hashCode ^
        id.hashCode ^
        reshareCount.hashCode ^
        reroaredBy.hashCode ^
        repliedTo.hashCode;
  }
}
