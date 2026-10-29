import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TrialStatus {
  const TrialStatus({
    required this.active,
    required this.startedAt,
    required this.endsAt,
    required this.remaining,
  });
  final bool active;
  final DateTime startedAt;
  final DateTime endsAt;
  final Duration remaining;
}

/// A seven-day, first-run trial with a persisted high-water clock, matching
/// the desktop TrialService policy. Secure storage survives normal app restarts.
class TrialService {
  TrialService(this._storage);
  static const _key = 'kasirin.trial.v1';
  static const _duration = Duration(days: 7);
  static const _rollbackTolerance = Duration(minutes: 5);
  final FlutterSecureStorage _storage;

  Future<TrialStatus> status({DateTime Function()? now}) async {
    final current = (now ?? DateTime.now)().toUtc();
    Map<String, dynamic> state = {};
    try {
      final raw = await _storage.read(key: _key);
      if (raw != null) state = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      state = {};
    }
    DateTime? parse(dynamic value) {
      if (value is! String) return null;
      return DateTime.tryParse(value)?.toUtc();
    }

    final started = parse(state['started_at']) ?? current;
    final lastSeen = parse(state['last_seen_at']);
    final effectiveNow =
        lastSeen != null &&
            current.isBefore(lastSeen.subtract(_rollbackTolerance))
        ? lastSeen
        : current;
    final highWater = lastSeen == null || effectiveNow.isAfter(lastSeen)
        ? effectiveNow
        : lastSeen;
    await _storage.write(
      key: _key,
      value: jsonEncode({
        'started_at': started.toIso8601String(),
        'last_seen_at': highWater.toIso8601String(),
      }),
    );
    final ends = started.add(_duration);
    final remaining = ends.difference(effectiveNow);
    return TrialStatus(
      active: remaining > Duration.zero,
      startedAt: started,
      endsAt: ends,
      remaining: remaining.isNegative ? Duration.zero : remaining,
    );
  }
}
