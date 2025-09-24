import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';

Future<File?> generateThumbnail(String videoUrl) async {
  final uint8list = await VideoThumbnail.thumbnailData(
    video: videoUrl, // local file path or network URL
    imageFormat: ImageFormat.PNG, // JPG or PNG
    maxWidth: 300, // resize width, keep aspect ratio
    quality: 75,
  );

  if (uint8list == null) return null;

  // Optionally save to a file
  final tempDir = Directory.systemTemp;
  final file = await File('${tempDir.path}/thumb.png').create();
  file.writeAsBytesSync(uint8list);

  return file;
}
