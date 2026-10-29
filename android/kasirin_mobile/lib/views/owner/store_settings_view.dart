import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../platform/store_media.dart';
import '../../providers.dart';
import 'owner_widgets.dart';

class StoreSettingsView extends ConsumerStatefulWidget {
  const StoreSettingsView({super.key});

  @override
  ConsumerState<StoreSettingsView> createState() => _StoreSettingsViewState();
}

class _StoreSettingsViewState extends ConsumerState<StoreSettingsView> {
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _sloganController = TextEditingController();
  final _addressController = TextEditingController();
  final _whatsappController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSavingPayments = false;
  bool _isPickingImage = false;
  String? _logoPath;
  String? _bannerPath;
  int _tab = 0;
  Map<String, bool> _paymentSettings = {
    'cash': true,
    'qrisDana': false,
    'qrisMidtrans': false,
    'transfer': false,
  };

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _sloganController.dispose();
    _addressController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _loadStoreData() async {
    try {
      final repository = await ref.read(repositoryFutureProvider.future);
      final store = await repository.getStore();
      final paymentSettings = await repository.getPaymentSettings();
      final auth = ref.read(authNotifierProvider);
      _ownerController.text = auth.fullName ?? '';
      if (store != null && mounted) {
        _nameController.text = store.read<String>('name');
        _sloganController.text = store.read<String?>('slogan') ?? '';
        _addressController.text = store.read<String?>('address') ?? '';
        _whatsappController.text = store.read<String?>('whatsapp') ?? '';
        _logoPath = store.read<String?>('logo_path');
        _bannerPath = store.read<String?>('banner_path');
      }
      if (mounted) setState(() => _paymentSettings = paymentSettings);
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePaymentSettings() async {
    setState(() => _isSavingPayments = true);
    try {
      final repository = await ref.read(repositoryFutureProvider.future);
      await repository.savePaymentSettings(_paymentSettings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Metode pembayaran berhasil disimpan.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan metode pembayaran: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingPayments = false);
    }
  }

  Future<void> _saveSettings() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama toko wajib diisi.'),
          backgroundColor: Color(0xFFB42318),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repository = await ref.read(repositoryFutureProvider.future);
      final auth = ref.read(authNotifierProvider);
      if (auth.userId == null) throw StateError('Akun owner tidak ditemukan.');
      final ownerName = _ownerController.text.trim();
      if (ownerName.isEmpty) throw StateError('Nama owner wajib diisi.');
      await repository.updateStore(
        name: name,
        slogan: _sloganController.text.trim(),
        address: _addressController.text.trim(),
        whatsapp: _whatsappController.text.trim(),
        logoPath: _logoPath,
        bannerPath: _bannerPath,
      );
      await repository.updateOwnerName(
        userId: auth.userId!,
        fullName: ownerName,
      );
      ref
          .read(authNotifierProvider.notifier)
          .setAuthenticated(
            userId: auth.userId!,
            username: auth.username!,
            fullName: ownerName,
            role: auth.role!,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan toko berhasil disimpan.'),
            backgroundColor: Color(0xFF18794E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: const Color(0xFFB42318),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickImage({required bool banner}) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
        maxWidth: banner ? 1800 : 1000,
      );
      if (picked == null || !mounted) return;
      final suffix = banner ? 'banner' : 'logo';
      final destination = await persistStoreImage(picked, kind: suffix);
      setState(() {
        if (banner) {
          _bannerPath = destination;
        } else {
          _logoPath = destination;
        }
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $error')));
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OwnerScaffold(
      title: 'Profil Toko',
      onBack: () => context.go('/'),
      maxWidth: 760,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: OwnerTabBar<int>(
              tabs: const [(0, 'Identitas toko'), (1, 'Pembayaran')],
              selected: _tab,
              onSelected: (value) => setState(() => _tab = value),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tab == 1
                ? _buildPaymentSettings()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: OwnerSurface(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF006EAE)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.store_rounded,
                                      color: Color(0xFF006EAE),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Text(
                                    'Identitas Toko',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF17212B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Divider(color: Color(0xFFD7DEE5)),
                              const SizedBox(height: 16),
                              _ImageUploadCard(
                                title: 'Banner toko',
                                path: _bannerPath,
                                height: 132,
                                icon: Icons.panorama_outlined,
                                buttonLabel: 'Upload Banner',
                                isBusy: _isPickingImage,
                                onUpload: () => _pickImage(banner: true),
                              ),
                              const SizedBox(height: 14),
                              _ImageUploadCard(
                                title: 'Logo / foto profil toko',
                                path: _logoPath,
                                height: 100,
                                icon: Icons.storefront_rounded,
                                buttonLabel: 'Upload Logo',
                                isBusy: _isPickingImage,
                                onUpload: () => _pickImage(banner: false),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Toko *',
                                  prefixIcon: Icon(Icons.business),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _ownerController,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Owner',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _sloganController,
                                decoration: const InputDecoration(
                                  labelText: 'Slogan Toko',
                                  prefixIcon: Icon(Icons.format_quote),
                                  hintText:
                                      'Contoh: Belanja hemat, kualitas hebat',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _addressController,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  labelText: 'Alamat Toko',
                                  prefixIcon: Icon(Icons.location_on_outlined),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _whatsappController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Nomor WhatsApp Toko',
                                  prefixIcon: Icon(Icons.chat_bubble_outline),
                                  hintText: '081234567890',
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _saveSettings,
                                  icon: const Icon(Icons.save),
                                  label: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          'Simpan Pengaturan',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF006EAE),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSettings() {
    final methods =
        <({String key, String title, String subtitle, IconData icon})>[
          (
            key: 'cash',
            title: 'Tunai',
            subtitle: 'Pembayaran langsung di kasir',
            icon: Icons.payments_outlined,
          ),
          (
            key: 'transfer',
            title: 'Transfer bank',
            subtitle: 'Pembayaran melalui rekening toko',
            icon: Icons.account_balance_outlined,
          ),
          (
            key: 'qrisDana',
            title: 'QRIS DANA',
            subtitle: 'Pembayaran QRIS melalui DANA',
            icon: Icons.qr_code_2_rounded,
          ),
          (
            key: 'qrisMidtrans',
            title: 'QRIS Midtrans',
            subtitle: 'Pembayaran QRIS melalui Midtrans',
            icon: Icons.qr_code_rounded,
          ),
        ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: OwnerSurface(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (var index = 0; index < methods.length; index++) ...[
              SwitchListTile.adaptive(
                value: _paymentSettings[methods[index].key] ?? false,
                onChanged: (value) => setState(() {
                  _paymentSettings[methods[index].key] = value;
                }),
                secondary: Icon(methods[index].icon, color: ownerBlue),
                title: Text(
                  methods[index].title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(methods[index].subtitle),
              ),
              if (index < methods.length - 1)
                const Divider(height: 1, indent: 56),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSavingPayments ? null : _savePaymentSettings,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    _isSavingPayments ? 'Menyimpan…' : 'Simpan metode',
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Text(
                'Metode yang aktif akan ditampilkan saat pembayaran di kasir.',
                style: TextStyle(color: ownerMuted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageUploadCard extends StatelessWidget {
  const _ImageUploadCard({
    required this.title,
    required this.path,
    required this.height,
    required this.icon,
    required this.buttonLabel,
    required this.isBusy,
    required this.onUpload,
  });

  final String title;
  final String? path;
  final double height;
  final IconData icon;
  final String buttonLabel;
  final bool isBusy;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final imageProvider = storeImageProvider(path);
    final hasImage = storeImageExists(path);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: hasImage
                ? Image(image: imageProvider!, fit: BoxFit.cover)
                : ColoredBox(
                    color: const Color(0xFFF0F4F7),
                    child: Icon(icon, color: ownerMuted, size: 34),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: isBusy ? null : onUpload,
          icon: const Icon(Icons.upload_outlined),
          label: Text(isBusy ? 'Memilih gambar…' : buttonLabel),
        ),
      ],
    );
  }
}
