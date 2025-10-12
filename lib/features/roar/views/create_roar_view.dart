import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateRoarScreen extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const CreateRoarScreen());
  const CreateRoarScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateRoarScreenState();
}

class _CreateRoarScreenState extends ConsumerState<CreateRoarScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.close, size: 30),
        ),
      ),
    );
  }
}