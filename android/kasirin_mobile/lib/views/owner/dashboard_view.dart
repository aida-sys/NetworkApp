import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers.dart';
import '../../platform/store_media.dart';
import 'owner_widgets.dart';

class _DashboardPalette {
  const _DashboardPalette({
    required this.name,
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.text,
    required this.muted,
    required this.accent,
    required this.accentText,
    required this.border,
    required this.gradientEnd,
  });

  final String name;
  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color text;
  final Color muted;
  final Color accent;
  final Color accentText;
  final Color border;
  final Color gradientEnd;

  static const options = <_DashboardPalette>[
    _DashboardPalette(
      name: 'Dark Emerald',
      background: Color(0xFF0B1326),
      surface: Color(0xFF171F33),
      surfaceRaised: Color(0xFF222A3D),
      text: Color(0xFFDAE2FD),
      muted: Color(0xFFBACBBE),
      accent: Color(0xFF6DFFBA),
      accentText: Color(0xFF003822),
      border: Color(0xFF3B4A41),
      gradientEnd: Color(0xFF222A3D),
    ),
    _DashboardPalette(
      name: 'Ocean Blue',
      background: Color(0xFF091722),
      surface: Color(0xFF12283A),
      surfaceRaised: Color(0xFF1C354A),
      text: Color(0xFFE7F5FF),
      muted: Color(0xFFB3CDDC),
      accent: Color(0xFF55C8FF),
      accentText: Color(0xFF062235),
      border: Color(0xFF31536A),
      gradientEnd: Color(0xFF1C354A),
    ),
    _DashboardPalette(
      name: 'Light Slate',
      background: Color(0xFFF2F5F9),
      surface: Color(0xFFFFFFFF),
      surfaceRaised: Color(0xFFE7EDF4),
      text: Color(0xFF1D2939),
      muted: Color(0xFF526174),
      accent: Color(0xFF0877B9),
      accentText: Color(0xFFFFFFFF),
      border: Color(0xFFD3DCE7),
      gradientEnd: Color(0xFFE7EDF4),
    ),
    _DashboardPalette(
      name: 'Warm Amber',
      background: Color(0xFF21170F),
      surface: Color(0xFF302116),
      surfaceRaised: Color(0xFF45301E),
      text: Color(0xFFFFF3E0),
      muted: Color(0xFFD8C2A5),
      accent: Color(0xFFFFC266),
      accentText: Color(0xFF382100),
      border: Color(0xFF674B30),
      gradientEnd: Color(0xFF45301E),
    ),
    _DashboardPalette(
      name: 'Plum Night',
      background: Color(0xFF1B1426),
      surface: Color(0xFF2A1E3A),
      surfaceRaised: Color(0xFF3A2B4F),
      text: Color(0xFFF4EAFE),
      muted: Color(0xFFC9B8DB),
      accent: Color(0xFFD6A5FF),
      accentText: Color(0xFF301344),
      border: Color(0xFF59446F),
      gradientEnd: Color(0xFF3A2B4F),
    ),
  ];
}

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  final _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isLoading = true;
  bool _isSeedingDemo = false;
  Map<String, dynamic> _stats = {
    'productCount': 0,
    'todaySales': 0,
    'todayCount': 0,
    'activeShifts': 0,
    'lowStockCount': 0,
  };
  String _storeName = 'Toko Kasirin';
  String? _storeLogoPath;
  _DashboardPalette _palette = _DashboardPalette.options.first;

  @override
  void initState() {
    super.initState();
    _loadDashboardPalette();
    _loadDashboardData();
  }

  Future<void> _loadDashboardPalette() async {
    final storage = ref.read(secureStorageProvider);
    final savedName = await storage.read(key: 'dashboard_palette');
    if (!mounted || savedName == null) return;
    final savedPalette = _DashboardPalette.options
        .cast<_DashboardPalette?>()
        .firstWhere(
          (palette) => palette?.name == savedName,
          orElse: () => null,
        );
    if (savedPalette != null) setState(() => _palette = savedPalette);
  }

  Future<void> _selectDashboardPalette(_DashboardPalette palette) async {
    setState(() => _palette = palette);
    await ref
        .read(secureStorageProvider)
        .write(key: 'dashboard_palette', value: palette.name);
  }

  Future<void> _showDashboardPalettePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tema Dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text('Pilih warna latar dan teks yang nyaman dibaca.'),
            const SizedBox(height: 12),
            for (final palette in _DashboardPalette.options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: palette.background,
                  child: Icon(Icons.circle, color: palette.accent),
                ),
                title: Text(palette.name),
                subtitle: Text(
                  'Teks ${palette.text == const Color(0xFFFFFFFF)
                      ? 'terang'
                      : palette.name == 'Light Slate'
                      ? 'gelap'
                      : 'kontras'}',
                  style: TextStyle(color: palette.muted),
                ),
                trailing: _palette.name == palette.name
                    ? Icon(Icons.check_circle, color: palette.accent)
                    : null,
                onTap: () {
                  _selectDashboardPalette(palette);
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadDashboardData() async {
    try {
      final repository = await ref.read(repositoryFutureProvider.future);
      final stats = await repository.getDashboardStats();
      final store = await repository.getStore();

      if (mounted) {
        setState(() {
          _stats = stats;
          if (store != null) {
            _storeName = store.read<String>('name');
            _storeLogoPath = store.read<String?>('logo_path');
          }
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadDemoData() async {
    final userId = ref.read(authNotifierProvider).userId;
    if (userId == null || _isSeedingDemo) return;
    setState(() => _isSeedingDemo = true);
    try {
      final repository = await ref.read(repositoryFutureProvider.future);
      await repository.seedDemoData(userId);
      await _loadDashboardData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Data demo berhasil ditambahkan ke database perangkat ini.',
            ),
            backgroundColor: Color(0xFF18794E),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data demo gagal dimuat: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeedingDemo = false);
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari dashboard?'),
        content: const Text(
          'Anda akan kembali ke layar login dan perlu memasukkan username serta kata sandi untuk masuk lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Tetap di dashboard'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    final menuItems = [
      if (authState.isOwner)
        _DashboardMenuItem(
          title: 'Kasir POS',
          subtitle: 'Mulai transaksi penjualan',
          icon: Icons.point_of_sale_rounded,
          color: const Color(0xFF006EAE),
          route: '/cashier',
        ),
      _DashboardMenuItem(
        title: 'Produk & Stok',
        subtitle: 'Kelola katalog, harga, dan persediaan',
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF18794E),
        route: '/master-data',
      ),
      _DashboardMenuItem(
        title: 'Harga Spesial',
        subtitle: 'Atur harga grosir berdasarkan jumlah',
        icon: Icons.sell_rounded,
        color: const Color(0xFFD14F87),
        route: '/special-prices',
      ),
      _DashboardMenuItem(
        title: 'Laporan & Keuangan',
        subtitle: 'Pantau penjualan dan aktivitas toko',
        icon: Icons.bar_chart_rounded,
        color: const Color(0xFF6B5CE7),
        route: '/report-center',
      ),
      _DashboardMenuItem(
        title: 'Tim & Akses',
        subtitle: 'Atur karyawan dan hak akses',
        icon: Icons.groups_2_rounded,
        color: const Color(0xFFB7791F),
        route: '/user-management',
      ),
      _DashboardMenuItem(
        title: 'Belanja',
        subtitle: 'Belanja barang dan kelola supplier',
        icon: Icons.local_shipping_rounded,
        color: const Color(0xFF288A75),
        route: '/purchase',
      ),
      _DashboardMenuItem(
        title: 'Profil Toko',
        subtitle: 'Atur identitas dan informasi toko',
        icon: Icons.storefront_rounded,
        color: const Color(0xFF526579),
        route: '/store-settings',
      ),
      _DashboardMenuItem(
        title: 'Lisensi & Trial',
        subtitle: 'Periksa status aktivasi aplikasi',
        icon: Icons.shield_rounded,
        color: const Color(0xFF0877B9),
        route: '/license',
      ),
      _DashboardMenuItem(
        title: 'Tema Dashboard',
        subtitle: 'Ubah warna dan keterbacaan dashboard',
        icon: Icons.palette_outlined,
        color: _palette.accent,
        route: '__dashboard_theme__',
      ),
    ];

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _confirmLogout();
          });
        }
      },
      child: Theme(
        data: Theme.of(context).copyWith(
          brightness: _palette.name == 'Light Slate'
              ? Brightness.light
              : Brightness.dark,
          scaffoldBackgroundColor: _palette.background,
          colorScheme:
              ColorScheme.fromSeed(
                seedColor: _palette.accent,
                brightness: _palette.name == 'Light Slate'
                    ? Brightness.light
                    : Brightness.dark,
                surface: _palette.surface,
              ).copyWith(
                primary: _palette.accent,
                onPrimary: _palette.accentText,
                onSurface: _palette.text,
                secondary: _palette.accent,
              ),
          textTheme: Theme.of(context).textTheme
              .apply(bodyColor: _palette.text, displayColor: _palette.text),
          iconTheme: IconThemeData(color: _palette.text),
          dividerColor: _palette.border,
        ),
        child: Scaffold(
          backgroundColor: _palette.background,
          bottomNavigationBar: const SafeArea(top: false, child: TrialBanner()),
          drawer: Drawer(
            backgroundColor: _palette.surface,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _palette.surfaceRaised,
                          foregroundColor: _palette.accent,
                          child: const Icon(Icons.storefront_rounded),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _storeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                authState.fullName ?? 'Pemilik Toko',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _palette.muted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        for (final item in menuItems)
                          ListTile(
                            leading: Icon(item.icon, color: _palette.accent),
                            title: Text(item.title),
                            subtitle: Text(item.subtitle),
                            onTap: () {
                              Navigator.of(context).pop();
                              if (item.route == '__dashboard_theme__') {
                                _showDashboardPalettePicker();
                              } else {
                                context.go(item.route);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            backgroundColor: _palette.background,
            foregroundColor: _palette.text,
            title: const Text(
              'Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Tema Dashboard',
                onPressed: _showDashboardPalettePicker,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Segarkan',
                onPressed: _loadDashboardData,
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Keluar ke login',
                onPressed: _confirmLogout,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [_palette.surface, _palette.gradientEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: _palette.border),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: _palette.surfaceRaised,
                                backgroundImage: storeImageProvider(
                                  _storeLogoPath,
                                ),
                                child: _storeLogoPath == null
                                    ? Icon(
                                        Icons.storefront_rounded,
                                        color: _palette.accent,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _storeName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: _palette.text,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${authState.fullName ?? 'Pengguna'} · ${authState.role ?? 'OWNER'}',
                                      style: TextStyle(
                                        color: _palette.muted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (authState.isOwner)
                                IconButton(
                                  tooltip: 'Pengaturan toko',
                                  onPressed: () =>
                                      context.go('/store-settings'),
                                  icon: const Icon(Icons.tune_rounded),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: _palette.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _palette.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.query_stats_rounded,
                                    color: _palette.accent,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Penjualan hari ini',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'dd MMM',
                                      'id',
                                    ).format(DateTime.now()),
                                    style: TextStyle(
                                      color: _palette.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _rupiahFormat.format(
                                    _stats['todaySales'] ?? 0,
                                  ),
                                  style: TextStyle(
                                    color: _palette.accent,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _DashboardMetric(
                                      palette: _palette,
                                      icon: Icons.receipt_long_rounded,
                                      label: 'Transaksi',
                                      value: '${_stats['todayCount'] ?? 0}',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _DashboardMetric(
                                      palette: _palette,
                                      icon: Icons.inventory_2_rounded,
                                      label: 'Produk',
                                      value: '${_stats['productCount'] ?? 0}',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _DashboardMetric(
                                      palette: _palette,
                                      icon: Icons.timer_rounded,
                                      label: 'Shift aktif',
                                      value: '${_stats['activeShifts'] ?? 0}',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aksi cepat',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: _palette.text,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (authState.isOwner)
                              _DashboardQuickAction(
                                palette: _palette,
                                icon: Icons.point_of_sale_rounded,
                                label: 'Buka kasir',
                                primary: true,
                                onTap: () => context.go('/cashier'),
                              ),
                            _DashboardQuickAction(
                              palette: _palette,
                              icon: Icons.inventory_2_outlined,
                              label: 'Produk & stok',
                              onTap: () => context.go('/master-data'),
                            ),
                            _DashboardQuickAction(
                              palette: _palette,
                              icon: Icons.assessment_outlined,
                              label: 'Laporan',
                              onTap: () => context.go('/report-center'),
                            ),
                            if (authState.isOwner)
                              _DashboardQuickAction(
                                palette: _palette,
                                icon: Icons.shopping_bag_outlined,
                                label: 'Pembelian',
                                onTap: () => context.go('/purchase'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _palette.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _palette.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: _palette.accent,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Peringatan stok rendah',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${_stats['lowStockCount'] ?? 0} produk perlu diperiksa',
                                      style: TextStyle(
                                        color: _palette.muted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/master-data'),
                                child: const Text('Lihat'),
                              ),
                            ],
                          ),
                        ),
                        if (authState.isOwner &&
                            _stats['demoDataPresent'] != true) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _palette.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Coba dengan data contoh',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Data contoh disimpan lokal di perangkat ini.',
                                        style: TextStyle(
                                          color: _palette.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: _isSeedingDemo
                                      ? null
                                      : _loadDemoData,
                                  child: _isSeedingDemo
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Muat'),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Text(
                          'Menu operasional',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: _palette.text,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 10),
                        for (final item in menuItems)
                          Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: _palette.surface,
                            child: ListTile(
                              leading: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _palette.surfaceRaised,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(item.icon, color: _palette.accent),
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  color: _palette.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                item.subtitle,
                                style: TextStyle(color: _palette.muted),
                              ),
                              trailing: Icon(
                                Icons.chevron_right_rounded,
                                color: _palette.muted,
                              ),
                              onTap: item.route == '__dashboard_theme__'
                                  ? _showDashboardPalettePicker
                                  : () => context.go(item.route),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  const _DashboardMetric({
    required this.palette,
    required this.icon,
    required this.label,
    required this.value,
  });

  final _DashboardPalette palette;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: palette.surfaceRaised,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: palette.accent),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: palette.text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: palette.muted),
        ),
      ],
    ),
  );
}

class _DashboardQuickAction extends StatelessWidget {
  const _DashboardQuickAction({
    required this.palette,
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final _DashboardPalette palette;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) => FilledButton.tonalIcon(
    onPressed: onTap,
    icon: Icon(icon, size: 18),
    label: Text(label),
    style: FilledButton.styleFrom(
      backgroundColor: primary ? palette.accent : palette.surfaceRaised,
      foregroundColor: primary ? palette.accentText : palette.text,
      minimumSize: const Size(48, 46),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

class _DashboardMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  _DashboardMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}
