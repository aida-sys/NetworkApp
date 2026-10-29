Future<String?> savePosRequest({
  required String filename,
  required String content,
}) => Future.error(
  UnsupportedError('Unduhan permintaan lisensi tidak didukung.'),
);

Future<void> openExternalUrl(String url) =>
    Future.error(UnsupportedError('Membuka tautan eksternal tidak didukung.'));
