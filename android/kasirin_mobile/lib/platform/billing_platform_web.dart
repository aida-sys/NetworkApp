import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;

Future<String?> savePosRequest({
  required String filename,
  required String content,
}) async {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'application/octet-stream');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  Timer(const Duration(seconds: 1), () => html.Url.revokeObjectUrl(url));
  return filename;
}

Future<void> openExternalUrl(String url) async {
  html.window.location.assign(url);
}
