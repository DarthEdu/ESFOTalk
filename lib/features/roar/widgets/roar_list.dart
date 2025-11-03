import 'package:esfotalk_app/common/common.dart';
import 'package:esfotalk_app/constants/appwrite_constants.dart';
import 'package:esfotalk_app/features/roar/controller/roar_controller.dart';
import 'package:esfotalk_app/features/roar/widgets/roar_card.dart';
import 'package:esfotalk_app/models/roar_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoarList extends ConsumerWidget {
  const RoarList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(getRoarsProvider)
        .when(
          data: (roars) {
            return ref
                .watch(getLatestRoarProvider)
                .when(
                  data: (data) {
                    if (data.events.contains(
                      'databases.*.collections.${AppwriteConstants.roarTable}.documents.*.create',
                    )) {
                      roars.insert(0, Roar.fromMap(data.payload));
                    } else if (data.events.contains(
                      'databases.*.collections.${AppwriteConstants.roarTable}.documents.*.update',
                    )) {
                      final startingPoint = data.events[0].lastIndexOf(
                        'documents.',
                      );
                      final endingPoint = data.events[0].lastIndexOf('.update');
                      final roarId = data.events[0]
                          .substring(
                            startingPoint + 10,
                            endingPoint,
                          )
                          .toString();

                      var roar = roars
                          .where((element) => element.id == roarId)
                          .first;

                      final roarIndex = roars.indexOf(roar);
                      roars.removeWhere((element) => element.id == roarId);
                      roar = Roar.fromMap(data.payload);
                      roars.insert(roarIndex, roar);
                    }
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
                  loading: () {
                    return ListView.builder(
                      itemCount: roars.length,
                      itemBuilder: (BuildContext context, int index) {
                        final roar = roars[index];
                        return RoarCard(roar: roar);
                      },
                    );
                  },
                );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),

          loading: () => const Loader(),
        );
  }
}
