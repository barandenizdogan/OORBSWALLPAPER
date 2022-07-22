import 'package:gallery_saver/gallery_saver.dart';

Future downloadImage(String url) async {
  GallerySaver.saveImage(url, albumName: 'OORBS').then((bool success) {});
}
