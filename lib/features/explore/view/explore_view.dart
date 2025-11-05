import 'package:esfotalk_app/common/error_page.dart';
import 'package:esfotalk_app/common/loading_page.dart';
import 'package:esfotalk_app/features/explore/controller/explore_controller.dart';
import 'package:esfotalk_app/features/explore/widgets/search_tile.dart';
import 'package:esfotalk_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreView extends ConsumerStatefulWidget {
  const ExploreView({super.key});

  @override
  ConsumerState<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends ConsumerState<ExploreView> {
  final searchController = TextEditingController();
  // Se elimina 'isShowUsers' y se reemplaza por un término de búsqueda.
  String _searchTerm = '';

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarTextFieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(color: Pallete.searchBarColor),
    );
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 50,
          child: TextField(
            controller: searchController,
            onSubmitted: (value) {
              setState(() {
                _searchTerm = value;
              });
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10).copyWith(left: 20),
              fillColor: Pallete.searchBarColor,
              filled: true,
              enabledBorder: appBarTextFieldBorder,
              focusedBorder: appBarTextFieldBorder,
              hintText: 'Buscar en ESFOTalk',
            ),
          ),
        ),
      ),
      body: _searchTerm.isEmpty
          ? const Center(
              child: Text('Busca usuarios por su nombre de perfil.'),
            )
          : ref.watch(searchUserProvider(_searchTerm)).when(
                data: (users) {
                  if (users.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron usuarios.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return SearchTile(userModel: user);
                    },
                  );
                },
                error: (error, stackTrace) => ErrorText(error: error.toString()),
                loading: () => const Loader(),
              ),
    );
  }
}
