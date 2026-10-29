import 'package:flutter/services.dart';

const _paymentChannel = MethodChannel('com.kasirin/payment');

Future<String?> savePosRequest({
  required String filename,
  required String content,
}) => _paymentChannel.invokeMethod<String>('savePosRequest', {
  'filename': filename,
  'content': content,
});

Future<void> openExternalUrl(String url) =>
    _paymentChannel.invokeMethod<void>('openUrl', {'url': url});
