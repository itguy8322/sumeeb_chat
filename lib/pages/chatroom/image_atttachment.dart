import 'package:flutter/material.dart';

class ImageAtttachment extends StatelessWidget {
  final List<String> imageUrls;
  const ImageAtttachment({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => print("Image tapped"),
      child: Builder(
        builder: (context) {
          if (imageUrls.isEmpty) return const SizedBox.shrink();

          final maxImages = 4;
          final displayImages = imageUrls.take(maxImages).toList();
          final remaining = imageUrls.length - maxImages;

          if (displayImages.length == 1) {
            // Show full-width single image
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(displayImages.first, fit: BoxFit.cover),
            );
          }

          // Show grid for multiple images
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 images per row
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: displayImages.length,
            itemBuilder: (context, index) {
              final imageUrl = displayImages[index];

              // For the last image, check if we need overlay (+N)
              if (index == maxImages - 1 && remaining > 0) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '+$remaining',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Normal image tile
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              );
            },
          );
        },
      ),
    );
  }
}
