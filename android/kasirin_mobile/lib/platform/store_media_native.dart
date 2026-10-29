import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> persistStoreImage(XFile picked, {required String kind}) async {
  final support = await getApplicationSupportDirectory();
  final mediaDirectory = Directory(p.join(support.path, 'store_media'));
  await mediaDirectory.create(recursive: true);
  final extension = p.extension(picked.path).isEmpty
      ? '.jpg'
      : p.extension(picked.path);
  final destination = p.join(
    mediaDirectory.path,
    '${kind}_${DateTime.now().microsecondsSinceEpoch}$extension',
  );
  await File(picked.path).copy(destination);
  return destination;
}

ImageProvider? storeImageProvider(String? reference) {
  if (reference == null || reference.isEmpty) return null;
  return FileImage(File(reference));
}

bool storeImageExists(String? reference) =>
    reference != null && reference.isNotEmpty && File(reference).existsSync();
