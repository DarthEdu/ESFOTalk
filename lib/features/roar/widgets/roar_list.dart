import 'package:esfotalk_app/common/common.dart';
import 'package:esfotalk_app/features/roar/controller/roar_controller.dart';
import 'package:esfotalk_app/features/roar/widgets/roar_card.dart';
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
            return ListView.builder(itemCount: roars.length,
              itemBuilder: (BuildContext context, int index) {
                final roar = roars[index];
                return RoarCard(roar: roar);
              },
            );
          }, 
          error: (error, stackTrace) => ErrorText(
            error: error.toString(),),

          loading: () => const Loader());
  }
}
