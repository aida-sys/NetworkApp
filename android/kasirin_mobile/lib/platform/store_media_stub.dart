import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

Future<String> persistStoreImage(XFile picked, {required String kind}) =>
    Future.error(UnsupportedError('Penyimpanan gambar tidak didukung.'));

ImageProvider? storeImageProvider(String? reference) => null;

bool storeImageExists(String? reference) => false;
