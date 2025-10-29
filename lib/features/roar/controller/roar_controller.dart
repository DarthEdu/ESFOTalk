import 'dart:io';
import 'package:esfotalk_app/apis/roar_api.dart';
import 'package:esfotalk_app/apis/storage_api.dart';
import 'package:esfotalk_app/core/enums/roar_type_enum.dart';
import 'package:esfotalk_app/core/utils.dart';
import 'package:esfotalk_app/features/auth/controller/auth_controller.dart';
import 'package:esfotalk_app/models/roar_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roarControllerProvider = StateNotifierProvider<RoarController, bool>((
  ref,
) {
  return RoarController(
    ref: ref,
    roarAPI: ref.watch(roarAPIProvider),
    storageAPI: ref.watch(storageAPIProvider),
  );
});

final getRoarsProvider = FutureProvider((ref) {
  final roarController = ref.watch(roarControllerProvider.notifier);
  return roarController.getRoars();
});

final getLatestRoarProvider = StreamProvider((ref) {
  final roarAPI = ref.watch(roarAPIProvider);
  return roarAPI.getLatestRoars();
});

class RoarController extends StateNotifier<bool> {
  final RoarAPI _roarAPI;
  final StorageAPI _storageAPI;
  final Ref _ref;

  RoarController({
    required Ref ref,
    required RoarAPI roarAPI,
    required StorageAPI storageAPI,
  }) : _roarAPI = roarAPI,
       _ref = ref,
       _storageAPI = storageAPI,
       super(false);

  Future<List<Roar>> getRoars() async {
    final roarList = await _roarAPI.getRoars();
    return roarList.map((doc) => Roar.fromMap(doc.data)).toList();
  }

  void shareRoar({
    // Lógica para compartir un rugido
    required List<File> images,
    required String text,
    required BuildContext context,
  }) {
    if (text.isEmpty) {
      showSnackBar(context, 'Por favor ingresa un texto para el rugido.');
      return;
    }

    if (images.isNotEmpty) {
      // Lógica para subir imágenes
      _shareImageRoar(images: images, text: text, context: context);
    } else {
      _shareTextRoar(text: text, context: context);
    }
  }

  // Lógica para crear el rugido con el texto y las imágenes subidas
  void _shareImageRoar({
    required List<File> images,
    required String text,
    required BuildContext context,
  }) async {
    state = true;
    final hashtags = _getHashtagsFromText(text);
    String link = _getLinkFromText(text);
    final user = _ref.read(currentUserDetailsProvider).value!;
    final imageLinksResult = await _storageAPI.uploadImages(images);

    imageLinksResult.fold(
      (l) {
        showSnackBar(context, l.message);
        state = false;
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
        );
        final res = await _roarAPI.shareRoar(roar);
        state = false;
        res.fold(
          (l) => showSnackBar(context, l.message),
          (r) => Navigator.pop(context),
        );
      },
    );
  }

  void _shareTextRoar({
    required String text,
    required BuildContext context,
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
    );
    final res = await _roarAPI.shareRoar(roar);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      Navigator.pop(context);
    });
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
