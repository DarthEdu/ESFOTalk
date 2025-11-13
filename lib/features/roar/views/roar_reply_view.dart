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
      appBar: AppBar(title: const Text('Rugido')),
      body: Column(
        children: [
          RoarCard(roar: roar),
          ref
              .watch(getRepliesToRoarsProvider(roar.id))
              .when(
                data: (roars) {
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

                          if (!isRoarAlreadyPresent &&
                              latestRoar.repliedTo == roar.id) {
                            if (data.events.contains(
                              'databases.*.collections.${AppwriteConstants.roarTable}.documents.*.create',
                            )) {
                              roars.insert(0, Roar.fromMap(data.payload));
                            } else if (data.events.contains(
                              'databases.*.collections.${AppwriteConstants.roarTable}.documents.*.update',
                            )) {
                              // get id of original roar
                              final startingPoint = data.events[0].lastIndexOf(
                                'documents.',
                              );
                              final endPoint = data.events[0].lastIndexOf(
                                '.update',
                              );
                              final roarId = data.events[0].substring(
                                startingPoint + 10,
                                endPoint,
                              );

                              var roar = roars
                                  .where((element) => element.id == roarId)
                                  .first;

                              final roarIndex = roars.indexOf(roar);
                              roars.removeWhere(
                                (element) => element.id == roarId,
                              );

                              roar = Roar.fromMap(data.payload);
                              roars.insert(roarIndex, roar);
                            }
                          }

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
        decoration: const InputDecoration(hintText: 'Ruge tu respuesta'),
      ),
    );
  }
}
