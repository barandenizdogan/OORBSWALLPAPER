// Automatic FlutterFlow imports
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
import 'package:gallery_saver/gallery_saver.dart';

Future downloadImage(String url) async {
  GallerySaver.saveImage(url, albumName: 'OORBS').then((bool success) {});
}
