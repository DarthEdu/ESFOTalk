import 'package:esfotalk_app/common/common.dart';
import 'package:esfotalk_app/constants/appwrite_constants.dart';
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
            child: ref
                .watch(getRepliesToRoarsProvider(roar.id))
                .when(
                  data: (roars) {
                    final mutableRoars = List.from(roars);
                    return ref
                        .watch(getLatestRoarProvider)
                        .when(
                          data: (data) {
                            final latestRoar = Roar.fromMap(data.payload);

                            bool isRoarAlreadyPresent = false;

                            for (final roarModel in roars) {
                              if (roarModel.id == latestRoar.id) {
                                isRoarAlreadyPresent = true;
                                break;
                              }
                            }

                            if (!isRoarAlreadyPresent && latestRoar.repliedTo == roar.id) {
                              if (data.events.contains(
                                'databases.*.collections.${AppwriteConstants.roarTable}.documents.*.create',
                              )) {
                                mutableRoars.insert(
                                  0,
                                  Roar.fromMap(data.payload),
                                );
                              } else if (data.events.contains(
                                'databases.*.collections.${AppwriteConstants.roarTable}.documents.*.update',
                              )) {
                                final startingPoint = data.events[0]
                                    .lastIndexOf('documents.');
                                final endingPoint = data.events[0].lastIndexOf(
                                  '.update',
                                );
                                final roarId = data.events[0]
                                    .substring(startingPoint + 10, endingPoint)
                                    .toString();

                                final matchingRoars = mutableRoars.where(
                                  (element) => element.id == roarId,
                                );

                                if (matchingRoars.isNotEmpty) {
                                  final roar = matchingRoars.first;
                                  final roarIndex = mutableRoars.indexOf(roar);
                                  mutableRoars.removeWhere(
                                    (element) => element.id == roarId,
                                  );
                                  final updatedRoar = Roar.fromMap(
                                    data.payload,
                                  );
                                  mutableRoars.insert(roarIndex, updatedRoar);
                                }
                              }
                            }
                            return Expanded(
                              child: ListView.builder(
                                itemCount: mutableRoars.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final roar = mutableRoars[index];
                                  return RoarCard(roar: roar);
                                },
                              ),
                            );
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () {
                            return Expanded(
                              child: ListView.builder(
                                itemCount: roars.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final roar = roars[index];
                                  return RoarCard(roar: roar);
                                },
                              ),
                            );
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
