import 'package:esfotalk_app/common/error_page.dart';
import 'package:esfotalk_app/common/loading_page.dart';
import 'package:esfotalk_app/features/roar/controller/roar_controller.dart';
import 'package:esfotalk_app/features/roar/widgets/roar_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HashtagView extends ConsumerWidget {
  static route(String hashtag) =>
      MaterialPageRoute(builder: (context) => HashtagView(hashtag: hashtag));

  final String hashtag;
  const HashtagView({super.key, required this.hashtag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(hashtag)),
      body: ref
          .watch(getRoarsByHashtagProvider(hashtag))
          .when(
            data: (roars) {
              return ListView.builder(
                itemCount: roars.length,
                itemBuilder: (BuildContext context, int index) {
                  final roar = roars[index];
                  return RoarCard(roar: roar);
                },
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
