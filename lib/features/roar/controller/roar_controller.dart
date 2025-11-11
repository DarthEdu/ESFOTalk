import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:esfotalk_app/apis/roar_api.dart';
import 'package:esfotalk_app/apis/storage_api.dart';
import 'package:esfotalk_app/core/enums/notification_type_enum.dart';
import 'package:esfotalk_app/core/enums/roar_type_enum.dart';
import 'package:esfotalk_app/core/utils.dart';
import 'package:esfotalk_app/features/auth/controller/auth_controller.dart';
import 'package:esfotalk_app/features/notifications/controller/notification_controller.dart';
import 'package:esfotalk_app/models/roar_model.dart';
import 'package:esfotalk_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roarControllerProvider = StateNotifierProvider<RoarController, bool>((
  ref,
) {
  return RoarController(
    ref: ref,
    roarAPI: ref.watch(roarAPIProvider),
    storageAPI: ref.watch(storageAPIProvider),
    notificationController: ref.watch(notificationControllerProvider.notifier),
  );
});

// Proveedor de stream para la lista de todos los roars
final getRoarsProvider = StreamProvider((ref) async* {
  final roarController = ref.watch(roarControllerProvider.notifier);
  // 1. Carga inicial de roars
  final initialRoars = await roarController.getRoars();
  yield initialRoars;

  // 2. Escucha los cambios en tiempo real y vuelve a cargar la lista
  final stream = ref.watch(roarAPIProvider).getLatestRoars();
  // ignore: unused_local_variable
  await for (final event in stream) {
    final updatedRoars = await roarController.getRoars();
    yield updatedRoars;
  }
});

// Proveedor de stream para las respuestas a un roar específico
final getRepliesToRoarsProvider = StreamProvider.family<List<Roar>, String>((
  ref,
  roarId,
) async* {
  final roarController = ref.watch(roarControllerProvider.notifier);
  // 1. Carga inicial de respuestas
  final initialReplies = await roarController.getRepliesToRoar(roarId);
  yield initialReplies;

  // 2. Escucha los cambios y vuelve a cargar si son relevantes
  final stream = ref.watch(roarAPIProvider).getLatestRoars();
  await for (final event in stream) {
    // Evita errores si el payload no coincide con el modelo esperado
    try {
      final payload = Roar.fromMap(event.payload);
      // Vuelve a cargar solo si el cambio es una respuesta a este roar
      if (payload.repliedTo == roarId) {
        final updatedReplies = await roarController.getRepliesToRoar(roarId);
        yield updatedReplies;
      }
    } catch (_) {
      // Ignorar eventos que no correspondan a Roar
    }
  }
});

final getLatestRoarProvider = StreamProvider((ref) {
  final roarAPI = ref.watch(roarAPIProvider);
  return roarAPI.getLatestRoars();
});

final getRoarByIdProvider = FutureProvider.family((ref, String id) {
  final roarController = ref.watch(roarControllerProvider.notifier);
  return roarController.getRoarById(id);
});

final getRoarsByHashtagProvider = FutureProvider.family((ref, String hashtag) {
  final roarController = ref.watch(roarControllerProvider.notifier);
  return roarController.getRoarsByHashtag(hashtag);
});

class RoarController extends StateNotifier<bool> {
  final RoarAPI _roarAPI;
  final StorageAPI _storageAPI;
  final NotificationController _notificationController;
  final Ref _ref;

  RoarController({
    required Ref ref,
    required RoarAPI roarAPI,
    required StorageAPI storageAPI,
    required NotificationController notificationController,
  }) : _roarAPI = roarAPI,
       _ref = ref,
       _storageAPI = storageAPI,
       _notificationController = notificationController,
       super(false);

  Future<List<Roar>> getRoars() async {
    final roarList = await _roarAPI.getRoars();
    return roarList
        .map((doc) => Roar.fromMap({...doc.data, 'id': doc.$id}))
        .toList();
  }

  Future<Roar> getRoarById(String id) async {
    final roar = await _roarAPI.getRoarById(id);
    return Roar.fromMap({...roar.data, 'id': roar.$id});
  }

  void likeRoar(Roar roar, UserModel user) async {
    List<String> likes = roar.likes;
    if (likes.contains(user.uid)) {
      likes.remove(user.uid);
    } else {
      likes.add(user.uid);
    }
    roar = roar.copyWith(likes: likes);
    final res = await _roarAPI.likeRoar(roar);
    res.fold((l) => null, (r) {
      _notificationController.createNotification(
        text: '¡${user.name} le gusta tu rugido!',
        postId: roar.id,
        uid: roar.uid,
        notificationType: NotificationType.like,
      );
    });
  }

  void reshareRoar(
    Roar roar,
    UserModel currentUser,
    BuildContext context,
  ) async {
    roar = roar.copyWith(
      reroaredBy: currentUser.name,
      likes: [],
      commentIds: [],
      reshareCount: roar.reshareCount + 1,
    );
    final res = await _roarAPI.updateReshareCount(roar);
    res.fold((l) => showSnackBar(context, l.message), (r) async {
      roar = roar.copyWith(
        id: ID.unique(),
        reshareCount: 0,
        roaredAt: DateTime.now(),
      );
      final res2 = await _roarAPI.shareRoar(roar);
      res2.fold((l) => showSnackBar(context, l.message), (r) {
        _notificationController.createNotification(
          text: '¡${currentUser.name} compartió tu rugido!',
          postId: roar.id,
          uid: roar.uid,
          notificationType: NotificationType.reroar,
        );
        showSnackBar(context, 'Rugido compartido con éxito');
      });
    });
  }

  void shareRoar({
    required List<File> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) {
    if (text.isEmpty) {
      showSnackBar(context, 'Por favor ingresa un texto para el rugido.');
      return;
    }

    if (images.isNotEmpty) {
      _shareImageRoar(
        images: images,
        text: text,
        context: context,
        repliedTo: repliedTo,
        repliedToUserId: repliedToUserId,
      );
    } else {
      _shareTextRoar(
        text: text,
        context: context,
        repliedTo: repliedTo,
        repliedToUserId: repliedToUserId,
      );
    }
  }

  Future<List<Roar>> getRepliesToRoar(String roarId) async {
    final documents = await _roarAPI.getRepliesToRoar(roarId);
    return documents
        .map((doc) => Roar.fromMap({...doc.data, 'id': doc.$id}))
        .toList();
  }

  Future<List<Roar>> getRoarsByHashtag(String hashtag) async {
    final documents = await _roarAPI.getRoarsByHashtag(hashtag);
    return documents
        .map((doc) => Roar.fromMap({...doc.data, 'id': doc.$id}))
        .toList();
  }

  void _shareImageRoar({
    required List<File> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    state = true;
    var hashtags = _normalizeHashtags(_getHashtagsFromText(text));
    // Fallback: garantizar que se guarde aunque no haya hashtags
    if (hashtags.isEmpty) {
      hashtags = ['#esfotalk'];
    }
    String link = _getLinkFromText(text);
    // Asegurar que el usuario esté disponible
    final userAsync = _ref.read(currentUserDetailsProvider);
    final user = userAsync.value;
    if (user == null) {
      showSnackBar(context, 'No se pudo obtener tu usuario. Intenta de nuevo.');
      state = false;
      return;
    }
    final imageLinks = await _storageAPI.uploadImage(images);
    if (imageLinks.isEmpty) {
      showSnackBar(context, 'No se pudo subir la imagen. Intenta de nuevo.');
      state = false;
      return;
    }

    Roar roar = Roar(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: imageLinks,
      uid: user.uid,
      roarType: RoarType.image,
      roaredAt: DateTime.now(),
      likes: [],
      commentIds: [],
      id: '', // se asignará tras creación
      reshareCount: 0,
      reroaredBy: '',
      repliedTo: repliedTo,
    );
    final res = await _roarAPI.shareRoar(roar);

    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (repliedTo.isNotEmpty) {
        _notificationController.createNotification(
          text: '¡${user.name} ha contestado tu rugido!',
          postId: r.$id,
          uid: repliedToUserId,
          notificationType: NotificationType.reply,
        );
      }
      if (repliedTo.isEmpty) {
        showSnackBar(context, '¡Rugido publicado!');
      }
    });
    state = false;
  }

  void _shareTextRoar({
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    state = true;
    var hashtags = _normalizeHashtags(_getHashtagsFromText(text));
    // Fallback: garantizar que se guarde aunque no haya hashtags
    if (hashtags.isEmpty) {
      hashtags = ['#esfotalk'];
    }

    String link = _getLinkFromText(text);
    // Asegurar que el usuario esté disponible
    final userAsync = _ref.read(currentUserDetailsProvider);
    final user = userAsync.value;
    if (user == null) {
      showSnackBar(context, 'No se pudo obtener tu usuario. Intenta de nuevo.');
      state = false;
      return;
    }
    Roar roar = Roar(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: [],
      uid: user.uid,
      roarType: RoarType.text,
      roaredAt: DateTime.now(),
      likes: [],
      commentIds: [],
      id: '', // se asignará tras creación
      reshareCount: 0,
      reroaredBy: '',
      repliedTo: repliedTo,
    );
    final res = await _roarAPI.shareRoar(roar);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (repliedTo.isNotEmpty) {
        _notificationController.createNotification(
          text: '¡${user.name} ha contestado tu rugido!',
          postId: r.$id,
          uid: repliedToUserId,
          notificationType: NotificationType.reply,
        );
      }
      if (repliedTo.isEmpty) {
        showSnackBar(context, '¡Rugido publicado!');
      }
    });
    state = false;
  }

  String _getLinkFromText(String text) {
    String link = '';
    List<String> wordInSentence = text.split(' ');
    for (String word in wordInSentence) {
      if (word.startsWith('https://') || word.startsWith('www.')) {
        link = word;
      }
    }
    return link;
  }

  List<String> _getHashtagsFromText(String text) {
    final words = text.split(RegExp(r"\s+"));
    final tags = <String>[];
    for (var word in words) {
      if (word.startsWith('#')) {
        tags.add(word);
      }
    }
    return tags;
  }

  // Normaliza hashtags: quita espacios, evita vacíos/duplicados y agrega # si falta
  List<String> _normalizeHashtags(List<String> tags) {
    final cleaned = tags
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .map((t) => t.startsWith('#') ? t : '#$t')
        .toSet()
        .toList();
    return cleaned;
  }
}
