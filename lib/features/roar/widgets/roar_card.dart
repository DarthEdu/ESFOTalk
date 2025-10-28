import 'package:esfotalk_app/common/error_page.dart';
import 'package:esfotalk_app/common/loading_page.dart';
import 'package:esfotalk_app/features/auth/controller/auth_controller.dart';
import 'package:esfotalk_app/models/roar_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoarCard extends ConsumerWidget {
  final Roar roar;
  const RoarCard({super.key, required this.roar});
  
  @override
  
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userDetailsProvider(roar.uid)).when(data: (user) {
      return Column(
      children: [
        Row(children: [
          Container(
            margin: const EdgeInsets.all(10),
            child: CircleAvatar(
              backgroundImage: NetworkImage(user.profilePic),
              radius: 35,
            ),
          ),
          Column(
            //reroar
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),  
                  ),
                  Text(
                    '@${user.name}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
        ),
      ],
    );
    }, error: (error, stackTrace) => ErrorText(
            error: error.toString(),),loading: () => const Loader());
  }
  
}