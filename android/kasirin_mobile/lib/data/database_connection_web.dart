import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

Future<QueryExecutor> openExecutor() async {
  final result = await WasmDatabase.open(
    databaseName: 'kasirin',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  );
  return result.resolvedExecutor;
}

QueryExecutor createMemoryExecutor() =>
    throw UnsupportedError('Database memory tidak tersedia di browser.');
