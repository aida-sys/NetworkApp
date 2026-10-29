import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

Future<String> persistStoreImage(XFile picked, {required String kind}) async {
  final bytes = await picked.readAsBytes();
  final mimeType = picked.mimeType ?? 'image/jpeg';
  return 'data:$mimeType;base64,${base64Encode(bytes)}';
}

ImageProvider? storeImageProvider(String? reference) {
  if (reference == null || !reference.startsWith('data:image/')) return null;
  final comma = reference.indexOf(',');
  if (comma < 0) return null;
  try {
    return MemoryImage(base64Decode(reference.substring(comma + 1)));
  } on FormatException {
    return null;
  }
}

bool storeImageExists(String? reference) =>
    storeImageProvider(reference) != null;
