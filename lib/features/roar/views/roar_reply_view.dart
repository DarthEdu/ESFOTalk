import 'package:esfotalk_app/common/common.dart';
import 'package:esfotalk_app/features/roar/controller/roar_controller.dart';
import 'package:esfotalk_app/features/roar/widgets/roar_card.dart';
import 'package:esfotalk_app/models/roar_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoarReplyScreen extends ConsumerWidget {
  static route(Roar roar) =>
      MaterialPageRoute(builder: (context) => RoarReplyScreen(roar: roar));

  final Roar roar;
  const RoarReplyScreen({super.key, required this.roar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responde al Rugido')),
      body: Column(
        children: [
          RoarCard(roar: roar),
          Expanded(
            child: ref.watch(getRepliesToRoarsProvider(roar.id)).when(
                  data: (roars) {
                    return ListView.builder(
                      itemCount: roars.length,
                      itemBuilder: (BuildContext context, int index) {
                        final roar = roars[index];
                        return RoarCard(roar: roar);
                      },
                    );
                  },
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
          ),
        ],
      ),
      bottomNavigationBar: TextField(
        onSubmitted: (value) {
          ref
              .read(roarControllerProvider.notifier)
              .shareRoar(
                images: [],
                text: value,
                context: context,
                repliedTo: roar.id,
                repliedToUserId: roar.uid,
              );
        },
        decoration: InputDecoration(hintText: 'Ruge tu respuesta...'),
      ),
    );
  }
}
