import 'package:drift/drift.dart';

QueryExecutor createMemoryExecutor() =>
    throw UnsupportedError('Tidak ada koneksi database untuk platform ini.');

Future<QueryExecutor> openExecutor() =>
    Future.error(UnsupportedError('Platform ini belum didukung.'));
