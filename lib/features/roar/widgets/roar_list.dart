import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esfotalk_app/common/common.dart';
import 'package:esfotalk_app/features/roar/controller/roar_controller.dart';
import 'package:esfotalk_app/features/roar/widgets/roar_card.dart';

class RoarList extends ConsumerWidget {
  const RoarList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(getRoarsProvider)
        .when(
          data: (roars) {
            // Verificar si roars es null o está vacío
            if (roars == null || roars.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay rugidos todavía',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '¡Sé el primero en rugir! Usa el botón + para publicar tu primer rugido.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
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
        );
  }
}
