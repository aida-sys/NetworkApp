import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers.dart';

class KasirinApp extends ConsumerStatefulWidget {
  const KasirinApp({super.key});

  @override
  ConsumerState<KasirinApp> createState() => _KasirinAppState();
}

class _KasirinAppState extends ConsumerState<KasirinApp> {
  bool _startupComplete = false;

  @override
  void initState() {
    super.initState();
    ref.read(trialStatusProvider.future);
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _startupComplete = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    if (!_startupComplete) {
      return MaterialApp(
        title: 'Kasirin POS',
        theme: theme,
        debugShowCheckedModeBanner: false,
        home: const _StartupSplash(),
      );
    }

    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Kasirin POS',
      theme: theme,
      routerConfig: router,
    );
  }
}

class _StartupSplash extends StatefulWidget {
  const _StartupSplash();

  @override
  State<_StartupSplash> createState() => _StartupSplashState();
}

class _StartupSplashState extends State<_StartupSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.96,
    upperBound: 1.0,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101827),
      appBar: AppBar(
        title: const Text('Kasirin · Memulai Aplikasi'),
        backgroundColor: const Color(0xFF101827),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _pulseController,
                child: Image.asset(
                  'AnjaySoft.jpg',
                  width: 320,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 150,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Color(0xFF334155),
                  color: Color(0xFF62D8F0),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Menyiapkan Kasirin...',
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 14,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id');
  runApp(const ProviderScope(child: KasirinApp()));
}
