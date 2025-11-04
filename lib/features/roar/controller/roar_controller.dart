import 'dart:io' as io;
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

final getRoarsProvider = FutureProvider((ref) {
  final roarController = ref.watch(roarControllerProvider.notifier);
  return roarController.getRoars();
});

final getRepliesToRoarsProvider = FutureProvider.family((ref, String roarId) {
  final roarController = ref.watch(roarControllerProvider.notifier);
  return roarController.getRepliesToRoar(roarId);
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
    return roarList.map((doc) => Roar.fromMap(doc.data)).toList();
  }

  Future<Roar> getRoarById(String id) async {
    final roar = await _roarAPI.getRoarById(id);
    return Roar.fromMap((roar).data);
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
    // Lógica para compartir un rugido
    required List<io.File> images,
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
      // Lógica para subir imágenes
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
    return documents.map((roar) => Roar.fromMap(roar.data)).toList();
  }

   Future<List<Roar>> getRoarsByHashtag(String hashtag) async {
    final documents = await _roarAPI.getRoarsByHashtag(hashtag);
    return documents.map((roar) => Roar.fromMap(roar.data)).toList();
  }


  // Lógica para crear el rugido con el texto y las imágenes subidas
  void _shareImageRoar({
    required List<io.File> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    state = true;
    final hashtags = _getHashtagsFromText(text);
    String link = _getLinkFromText(text);
    final user = _ref.read(currentUserDetailsProvider).value!;
    final imageLinksResult = await _storageAPI.uploadImages(images);

    imageLinksResult.fold(
      (l) {
        showSnackBar(context, l.message);
      },
      (imageLinks) async {
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
          id: '',
          reshareCount: 0,
          reroaredBy: '',
          repliedTo: repliedTo,
        );
        final res = await _roarAPI.shareRoar(roar);
        state = false;
        res.fold((l) => showSnackBar(context, l.message), (r) {
          if (repliedTo.isNotEmpty) {
            _notificationController.createNotification(
              text: '¡${user.name} ha compartido tu rugido!',
              postId: r.$id,
              uid: repliedToUserId,
              notificationType: NotificationType.reply,
            );
          }
        });
      },
    );
    state = false;
  }

  void _shareTextRoar({
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    state = true;
    final hashtags = _getHashtagsFromText(text);
    String link = _getLinkFromText(text);
    final user = _ref.read(currentUserDetailsProvider).value!;
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
      id: '',
      reshareCount: 0,
      reroaredBy: '',
      repliedTo: repliedTo,
    );
    final res = await _roarAPI.shareRoar(roar);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (repliedTo.isNotEmpty) {
        _notificationController.createNotification(
          text: '¡${user.name} ha compartido tu rugido!',
          postId: r.$id,
          uid: repliedToUserId,
          notificationType: NotificationType.reply,
        );
      }
    });
    state = false;
  }

  String _getLinkFromText(String text) {
    // Lógica para extraer enlaces del texto
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
    // Lógica para extraer hashtags del texto
    List<String> hashtags = [];
    List<String> wordInSentence = text.split(' ');
    for (String word in wordInSentence) {
      if (word.startsWith('#')) {
        hashtags.add(word);
      }
    }
    return hashtags;
  }
}
