import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

QueryExecutor createMemoryExecutor() =>
    NativeDatabase.memory(setup: _configureSqlite);

Future<QueryExecutor> openExecutor() async {
  final directory = await getApplicationSupportDirectory();
  return NativeDatabase.createInBackground(
    File(p.join(directory.path, 'kasirin.db')),
    setup: _configureSqlite,
  );
}

void _configureSqlite(sqlite.Database database) {
  database.execute('PRAGMA foreign_keys = ON');
  database.execute('PRAGMA journal_mode = WAL');
  database.execute('PRAGMA busy_timeout = 5000');
}
