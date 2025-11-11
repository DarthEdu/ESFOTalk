import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esfotalk_app/apis/storage_api.dart';

class CarouselImage extends ConsumerStatefulWidget {
  final List<String> imageLinks;
  const CarouselImage({super.key, required this.imageLinks});

  @override
  ConsumerState<CarouselImage> createState() => _CarouselImageState();
}

class _CarouselImageState extends ConsumerState<CarouselImage> {
  int _current = 0;
  late Future<List<_ImageItem>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _imagesFuture = _loadImages();
  }

  Future<List<_ImageItem>> _loadImages() async {
    final storage = ref.read(storageAPIProvider);
    final list = <_ImageItem>[];
    for (final link in widget.imageLinks) {
      final bytes = await storage.getImageBytesFromUrl(link);
      list.add(_ImageItem(originalUrl: link, bytes: bytes));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_ImageItem>>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('No se pudieron cargar las imágenes')),
          );
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                CarouselSlider(
                  items: items.map((img) {
                    Widget content;
                    if (img.bytes != null) {
                      content = Image.memory(img.bytes!, fit: BoxFit.contain);
                    } else {
                      // Fallback a network si falla descarga autenticada
                      content = Image.network(
                        img.originalUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 48),
                      );
                    }
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      margin: const EdgeInsets.all(10),
                      child: content,
                    );
                  }).toList(),
                  options: CarouselOptions(
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: items.asMap().entries.map((e) {
                    return Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(
                          _current == e.key ? 0.9 : 0.4,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ImageItem {
  final String originalUrl;
  final Uint8List? bytes;
  _ImageItem({required this.originalUrl, required this.bytes});
}
