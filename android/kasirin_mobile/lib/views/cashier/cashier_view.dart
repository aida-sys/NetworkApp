import 'dart:math';

import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/pos_repository.dart';
import '../../providers.dart';
import '../owner/owner_widgets.dart';

class CashierCartItem {
  final QueryRow product;
  int quantity;
  int unitPrice;

  CashierCartItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  int get lineTotal => quantity * unitPrice;
  int get productId => product.read<int>('id');
  String get name => product.read<String>('name');
  String get sku => product.read<String>('sku');
  int get stock => product.read<int>('stock_qty');
}

class CashierView extends ConsumerStatefulWidget {
  const CashierView({super.key});

  @override
  ConsumerState<CashierView> createState() => _CashierViewState();
}

class _CashierViewState extends ConsumerState<CashierView> {
  final _searchController = TextEditingController();
  final _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  List<QueryRow> _products = [];
  final List<CashierCartItem> _cartItems = [];

  bool _isLoadingProducts = true;
  int? _activeShiftId;
  int _openingCash = 0;
  final Map<int, int> _cashDenominations = {
    100000: 1,
    50000: 1,
    20000: 2,
    10000: 1,
    1000: 0,
  };
  bool _showDenominations = true;
  bool _isOpeningShift = false;
  String _storeName = 'Toko Kasirin';
  String _searchQuery = '';

  int get _cashFloat => _cashDenominations.entries.fold(
    0,
    (sum, entry) => sum + entry.key * entry.value,
  );

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final authState = ref.read(authNotifierProvider);
    final userId = authState.userId ?? 1;

    try {
      final repository = await ref.read(repositoryFutureProvider.future);
      final store = await repository.getStore();
      if (store != null && mounted) {
        _storeName = store.read<String>('name');
      }
      // Check active shift
      final activeShift = await repository.openShiftFor(userId);
      if (activeShift != null && mounted) {
        setState(() {
          _activeShiftId = activeShift.read<int>('id');
          _openingCash = activeShift.read<int>('opening_cash');
        });
      }

      await _refreshProducts();
    } catch (_) {
      // Ignored
    } finally {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  Future<void> _handleBackToPreviousScreen() async {
    final authState = ref.read(authNotifierProvider);
    if (authState.isCashier) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) context.go('/login');
    } else {
      context.go('/');
    }
  }

  Future<void> _refreshProducts() async {
    try {
      final repository = await ref.read(repositoryFutureProvider.future);
      final list = await repository.products(search: _searchQuery);
      if (mounted) {
        setState(() => _products = list);
      }
    } catch (_) {}
  }

  Future<void> _addToCart(QueryRow product) async {
    final productId = product.read<int>('id');
    final stock = product.read<int>('stock_qty');
    if (stock <= 0) return;

    final existingIndex = _cartItems.indexWhere(
      (item) => item.productId == productId,
    );

    try {
      final quantity = await showDialog<int>(
        context: context,
        builder: (_) => _ProductQuantityDialog(
          productName: product.read<String>('name'),
          unitPriceText: _rupiahFormat.format(
            product.read<int>('selling_price'),
          ),
          stock: stock,
          initialQuantity: existingIndex < 0
              ? 1
              : _cartItems[existingIndex].quantity,
        ),
      );

      if (quantity == null || !mounted) return;
      final repository = await ref.read(repositoryFutureProvider.future);
      final unitPrice = await repository.unitPriceFor(productId, quantity);
      if (!mounted) return;
      setState(() {
        final index = _cartItems.indexWhere(
          (item) => item.productId == productId,
        );
        if (index < 0) {
          _cartItems.add(
            CashierCartItem(
              product: product,
              quantity: quantity,
              unitPrice: unitPrice,
            ),
          );
        } else {
          _cartItems[index].quantity = quantity;
          _cartItems[index].unitPrice = unitPrice;
        }
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk tidak dapat dipilih: $error')),
        );
      }
    }
  }

  Future<void> _updateQuantity(int index, int newQty) async {
    if (index < 0 || index >= _cartItems.length) return;
    if (newQty <= 0) {
      setState(() => _cartItems.removeAt(index));
      return;
    }
    final item = _cartItems[index];
    if (newQty > item.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok ${item.name} hanya tersisa ${item.stock}.'),
          backgroundColor: const Color(0xFFB42318),
        ),
      );
      return;
    }

    final previousQuantity = item.quantity;
    final previousUnitPrice = item.unitPrice;
    setState(() => item.quantity = newQty);
    try {
      final repository = await ref.read(repositoryFutureProvider.future);
      final unitPrice = await repository.unitPriceFor(item.productId, newQty);
      if (!mounted) return;
      final currentIndex = _cartItems.indexWhere(
        (cartItem) => cartItem.productId == item.productId,
      );
      if (currentIndex >= 0 && _cartItems[currentIndex].quantity == newQty) {
        setState(() => _cartItems[currentIndex].unitPrice = unitPrice);
      }
    } catch (error) {
      if (!mounted) return;
      final currentIndex = _cartItems.indexWhere(
        (cartItem) => cartItem.productId == item.productId,
      );
      if (currentIndex >= 0 && _cartItems[currentIndex].quantity == newQty) {
        setState(() {
          _cartItems[currentIndex].quantity = previousQuantity;
          _cartItems[currentIndex].unitPrice = previousUnitPrice;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jumlah produk gagal diperbarui: $error')),
      );
    }
  }

  int get _cartTotal => _cartItems.fold(0, (sum, item) => sum + item.lineTotal);

  Future<void> _handleOpenShift() async {
    if (_isOpeningShift) return;
    setState(() => _isOpeningShift = true);
    final userId = ref.read(authNotifierProvider).userId ?? 1;
    final openingAmount = _cashFloat;
    try {
      final repository = await ref.read(repositoryFutureProvider.future);
      final shiftId = await repository.openShift(
        cashierId: userId,
        openingCash: openingAmount,
      );
      if (!mounted) return;
      setState(() {
        _activeShiftId = shiftId;
        _openingCash = openingAmount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shift kasir berhasil dibuka.')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuka shift: $error')));
      }
    } finally {
      if (mounted) setState(() => _isOpeningShift = false);
    }
  }

  Future<void> _handleCloseShift() async {
    if (_activeShiftId == null) return;

    final cashController = TextEditingController(text: '$_openingCash');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tutup Shift Kasir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hitung total uang fisik kas di laci:',
              style: TextStyle(fontSize: 14, color: Color(0xFFBACBBE)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cashController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Kas Akhir (Rp)',
                prefixText: 'Rp ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
              foregroundColor: Colors.white,
            ),
            child: const Text('Tutup Shift'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final cash = int.tryParse(cashController.text.replaceAll('.', '')) ?? 0;
      final authState = ref.read(authNotifierProvider);
      final userId = authState.userId ?? 1;

      try {
        final repository = await ref.read(repositoryFutureProvider.future);
        await repository.closeShift(
          shiftId: _activeShiftId!,
          cashierId: userId,
          closingCash: cash,
        );

        if (mounted) {
          setState(() {
            _activeShiftId = null;
            _openingCash = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shift kasir telah ditutup.'),
              backgroundColor: Color(0xFF6DFFBA),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menutup shift: $e'),
              backgroundColor: const Color(0xFFB42318),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleCheckout() async {
    final trial = await ref.read(trialServiceProvider).status();
    if (!trial.active) {
      final deviceToken = await ref
          .read(secureStorageProvider)
          .read(key: 'billing.device_token');
      var licensed = false;
      if (deviceToken != null) {
        try {
          final license =
              await ref
                      .read(billingClientProvider)
                      .checkLicense(bearerToken: deviceToken)
                  as Map;
          licensed = license['status'] == 'active';
        } catch (_) {
          // An expired trial cannot be extended while activation is offline.
        }
      }
      if (!licensed) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Masa trial berakhir. Aktifkan langganan dari menu Lisensi sebelum menerima transaksi baru.',
            ),
            backgroundColor: Color(0xFF9A6700),
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }
    }

    if (!mounted) return;

    if (_activeShiftId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan Buka Shift terlebih dahulu sebelum checkout.'),
          backgroundColor: Color(0xFF9A6700),
        ),
      );
      return;
    }

    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang masih kosong.'),
          backgroundColor: Color(0xFF9A6700),
        ),
      );
      return;
    }

    late final Map<String, bool> settings;
    try {
      settings = await (await ref.read(repositoryFutureProvider.future))
          .getPaymentSettings();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat memuat metode pembayaran: $error')),
      );
      return;
    }
    final paymentMethods = <(String, String)>[
      if (settings['cash'] == true) ('CASH', 'Tunai'),
      if (settings['transfer'] == true) ('BANK', 'Transfer bank'),
      if (settings['qrisDana'] == true) ('QRIS_DANA', 'QRIS DANA'),
      if (settings['qrisMidtrans'] == true) ('QRIS_MIDTRANS', 'QRIS Midtrans'),
    ];
    if (paymentMethods.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada metode pembayaran yang aktif.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    final total = _cartTotal;
    final cashController = TextEditingController(text: '$total');
    var selectedPaymentMethod = paymentMethods.first.$1;

    final paymentResult =
        await showModalBottomSheet<({CheckoutResult result, int paidAmount})>(
          context: context,
          isScrollControlled: true,
          backgroundColor: const Color(0xFF171F33),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (sheetContext) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                final enteredCash =
                    int.tryParse(cashController.text.replaceAll('.', '')) ?? 0;
                final isCash = selectedPaymentMethod == 'CASH';
                final change = isCash ? max(0, enteredCash - total) : 0;
                final isEnough = !isCash || enteredCash >= total;
                final methodLabel = paymentMethods
                    .firstWhere((method) => method.$1 == selectedPaymentMethod)
                    .$2;

                return Padding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Pembayaran $methodLabel',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF17212B),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(sheetContext).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1326),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text(
                                'Total Belanja:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFBACBBE),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _rupiahFormat.format(total),
                                textAlign: TextAlign.end,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00E599),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: selectedPaymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Metode pembayaran',
                        ),
                        items: paymentMethods
                            .map(
                              (method) => DropdownMenuItem(
                                value: method.$1,
                                child: Text(method.$2),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() {
                              selectedPaymentMethod = value;
                              if (value != 'CASH') {
                                cashController.text = '$total';
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: cashController,
                        enabled: isCash,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Dibayar (Rp)',
                          prefixText: 'Rp ',
                          helperText: 'Untuk non-tunai, nominal mengikuti total belanja.',
                        ),
                        onChanged: (_) => setModalState(() {}),
                      ),
                      if (isCash) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              label: const Text('Uang Pas'),
                              onPressed: () {
                                cashController.text = '$total';
                                setModalState(() {});
                              },
                            ),
                            for (final denom in [
                              10000,
                              20000,
                              50000,
                              100000,
                              200000,
                            ])
                              if (denom >= total ||
                                  denom == 50000 ||
                                  denom == 100000)
                                ActionChip(
                                  label: Text(_rupiahFormat.format(denom)),
                                  onPressed: () {
                                    cashController.text = '$denom';
                                    setModalState(() {});
                                  },
                                ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kembalian:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFBACBBE),
                            ),
                          ),
                          Text(
                            _rupiahFormat.format(change),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isEnough
                                  ? const Color(0xFF6DFFBA)
                                  : const Color(0xFFB42318),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isEnough
                              ? () async {
                                  if (!isCash) {
                                    final paymentConfirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text(
                                          'Konfirmasi pembayaran',
                                        ),
                                        content: Text(
                                          'Pastikan pembayaran ${methodLabel.toLowerCase()} sebesar ${_rupiahFormat.format(total)} sudah diterima dan terverifikasi.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                              dialogContext,
                                              false,
                                            ),
                                            child: const Text('Periksa lagi'),
                                          ),
                                          FilledButton(
                                            onPressed: () => Navigator.pop(
                                              dialogContext,
                                              true,
                                            ),
                                            child: const Text('Sudah diterima'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (paymentConfirmed != true ||
                                        !context.mounted) {
                                      return;
                                    }
                                  }
                                  final authState = ref.read(
                                    authNotifierProvider,
                                  );
                                  final userId = authState.userId ?? 1;
                                  final invoiceNo =
                                      'INV-${DateTime.now().toUtc().microsecondsSinceEpoch}';

                                  final itemsInput = _cartItems
                                      .map(
                                        (e) => CartItemInput(
                                          productId: e.productId,
                                          quantity: e.quantity,
                                        ),
                                      )
                                      .toList();

                                  try {
                                    final repository = await ref.read(
                                      repositoryFutureProvider.future,
                                    );
                                    final result = await repository.checkout(
                                      invoiceNo: invoiceNo,
                                      cashierId: userId,
                                      shiftId: _activeShiftId!,
                                      items: itemsInput,
                                      paymentMethod: selectedPaymentMethod,
                                      paymentAmount: isCash
                                          ? enteredCash
                                          : total,
                                    );

                                    if (sheetContext.mounted) {
                                      Navigator.of(sheetContext).pop((
                                        result: result,
                                        paidAmount: isCash
                                            ? enteredCash
                                            : total,
                                      ));
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Checkout gagal: $e'),
                                          backgroundColor: const Color(
                                            0xFFB42318,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6DFFBA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Selesaikan Pembayaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );

    cashController.dispose();
    if (paymentResult != null) {
      setState(() => _cartItems.clear());
      await _refreshProducts();
      if (mounted) {
        _showReceiptDialog(paymentResult.result, paymentResult.paidAmount);
      }
    }
  }

  void _showReceiptDialog(CheckoutResult result, int paidAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF6DFFBA),
              size: 28,
            ),
            SizedBox(width: 8),
            Text('Transaksi Berhasil!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No. Faktur: ${result.invoiceNo}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:'),
                Text(
                  _rupiahFormat.format(result.total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dibayar:'),
                Text(_rupiahFormat.format(paidAmount)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kembalian:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _rupiahFormat.format(result.change),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6DFFBA),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E599),
              foregroundColor: Colors.white,
            ),
            child: const Text('Transaksi Baru'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final isShiftOpen = _activeShiftId != null;

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _handleBackToPreviousScreen();
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1326),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              authState.isCashier ? Icons.logout : Icons.arrow_back_rounded,
            ),
            tooltip: authState.isCashier
                ? 'Keluar ke login'
                : 'Kembali ke Dashboard',
            onPressed: _handleBackToPreviousScreen,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isShiftOpen ? 'Cashier Register' : 'Buka Kasir',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              Text(
                'Kasir / Penjualan · ${authState.role ?? "CASHIER"}',
                style: const TextStyle(fontSize: 12, color: Color(0xFFBACBBE)),
              ),
            ],
          ),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isShiftOpen
                    ? const Color(0xFF6DFFBA).withValues(alpha: 0.12)
                    : const Color(0xFFFFB95F).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isShiftOpen
                      ? const Color(0xFF6DFFBA)
                      : const Color(0xFFFFB95F),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isShiftOpen ? Icons.fiber_manual_record : Icons.lock_clock,
                    size: 12,
                    color: isShiftOpen
                        ? const Color(0xFF6DFFBA)
                        : const Color(0xFFFFB95F),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isShiftOpen ? 'Shift Aktif' : 'Shift Tertutup',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isShiftOpen
                          ? const Color(0xFF6DFFBA)
                          : const Color(0xFFFFB95F),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!isShiftOpen)
              IconButton(
                icon: const Icon(Icons.lock_open),
                tooltip: 'Buka Shift',
                onPressed: _handleOpenShift,
              )
            else
              IconButton(
                icon: const Icon(Icons.lock_outline),
                tooltip: 'Tutup Shift',
                onPressed: _handleCloseShift,
              ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Keluar',
              onPressed: () async {
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        bottomNavigationBar: const SafeArea(top: false, child: TrialBanner()),
        body: Column(
          children: [
            Expanded(
              child: _isLoadingProducts
                  ? const Center(child: CircularProgressIndicator())
                  : isShiftOpen
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 720) {
                          return Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildProductCatalog(theme),
                              ),
                              const VerticalDivider(
                                width: 1,
                                color: Color(0xFF2D3449),
                              ),
                              Expanded(
                                flex: 2,
                                child: _buildCartSection(theme),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            Expanded(child: _buildProductCatalog(theme)),
                            _buildCompactCartBar(theme),
                          ],
                        );
                      },
                    )
                  : _buildShiftSetup(
                      authState.fullName ?? 'Kasir',
                      authState.role ?? 'CASHIER',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftSetup(String cashierName, String role) {
    const panel = Color(0xFF171F33);
    const raised = Color(0xFF222A3D);
    const mint = Color(0xFF6DFFBA);
    final denominations = [100000, 50000, 20000, 10000, 1000];

    return Column(
      children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: raised,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF3B4A41)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Buka Kasir',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.store_outlined,
                                        size: 15,
                                        color: mint,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Terminal 04 · $_storeName',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFFBACBBE),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB95F)
                                    .withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.lock_outline,
                                    size: 14,
                                    color: Color(0xFFFFB95F),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Laci terkunci',
                                    style: TextStyle(
                                      color: Color(0xFFFFB95F),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: panel,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 22,
                                backgroundColor: Color(0xFF2D3449),
                                child: Icon(Icons.person_rounded, color: mint),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cashierName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      role,
                                      style: const TextStyle(
                                        color: Color(0xFFBACBBE),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.wb_sunny_outlined,
                                color: Color(0xFFC0C1FF),
                                size: 18,
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Shift baru',
                                style: TextStyle(
                                  color: Color(0xFFBACBBE),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: mint,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Modal awal kas',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              'Uang tunai',
                              style: TextStyle(
                                color: Color(0xFFBACBBE),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF060E20),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'TOTAL NOMINAL MASUK',
                                style: TextStyle(
                                  color: Color(0xFFBACBBE),
                                  fontSize: 10,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _rupiahFormat.format(_cashFloat),
                                  style: const TextStyle(
                                    color: mint,
                                    fontSize: 31,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _cashQuickButton(
                                '+50 ribu',
                                () => setState(
                                  () => _cashDenominations[50000] =
                                      (_cashDenominations[50000] ?? 0) + 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: _cashQuickButton(
                                '+100 ribu',
                                () => setState(
                                  () => _cashDenominations[100000] =
                                      (_cashDenominations[100000] ?? 0) + 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: _cashQuickButton(
                                'Standar',
                                () => setState(
                                  () => _cashDenominations
                                    ..clear()
                                    ..addAll({
                                      100000: 1,
                                      50000: 1,
                                      20000: 2,
                                      10000: 1,
                                      1000: 0,
                                    }),
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: _cashQuickButton(
                                'Nol',
                                () => setState(
                                  () => _cashDenominations.updateAll(
                                    (key, value) => 0,
                                  ),
                                ),
                                danger: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF131B2E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                dense: true,
                                leading: const Icon(
                                  Icons.payments_outlined,
                                  color: mint,
                                  size: 19,
                                ),
                                title: const Text(
                                  'Rincian uang kertas & koin',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                trailing: Icon(
                                  _showDenominations
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: const Color(0xFFBACBBE),
                                ),
                                onTap: () => setState(
                                  () =>
                                      _showDenominations = !_showDenominations,
                                ),
                              ),
                              if (_showDenominations) ...[
                                const Divider(height: 1),
                                for (final denomination in denominations)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: raised,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            '${denomination ~/ 1000}k',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: mint,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: Text(
                                            denomination == 1000
                                                ? 'Koin Rp 1.000'
                                                : 'Pecahan ${_rupiahFormat.format(denomination)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFBACBBE),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Kurangi pecahan',
                                          visualDensity: VisualDensity.compact,
                                          onPressed:
                                              (_cashDenominations[denomination] ??
                                                      0) >
                                                  0
                                              ? () => setState(
                                                  () => _cashDenominations[denomination] =
                                                      _cashDenominations[denomination]! -
                                                      1,
                                                )
                                              : null,
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            size: 19,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 24,
                                          child: Text(
                                            '${_cashDenominations[denomination] ?? 0}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Tambah pecahan',
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () => setState(
                                            () => _cashDenominations[denomination] =
                                                (_cashDenominations[denomination] ??
                                                    0) +
                                                1,
                                          ),
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                            size: 19,
                                            color: mint,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: mint),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Katalog produk',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${_products.length} produk tersedia untuk dicari',
                                style: const TextStyle(
                                  color: Color(0xFFBACBBE),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle_outline, color: mint),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 648),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: _isOpeningShift ? null : _handleOpenShift,
                        icon: _isOpeningShift
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.key_rounded),
                        label: Text(
                          _isOpeningShift
                              ? 'Membuka shift…'
                              : 'Buka kasir & mulai',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF00E599),
                          foregroundColor: const Color(0xFF003822),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton.icon(
                      onPressed: _handleBackToPreviousScreen,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Kembali ke dashboard'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cashQuickButton(
    String label,
    VoidCallback onPressed, {
    bool danger = false,
  }) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      foregroundColor: danger
          ? const Color(0xFFFFB4AB)
          : const Color(0xFFDAE2FD),
      backgroundColor: danger
          ? const Color(0xFF93000A).withValues(alpha: .15)
          : const Color(0xFF222A3D),
      side: BorderSide(
        color: danger ? const Color(0xFF93000A) : const Color(0xFF2D3449),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
    ),
    child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
  );

  Widget _buildProductCatalog(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
        color: Color(0xFF171F33),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama, SKU, atau scan barcode...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        _refreshProducts();
                      },
                    )
                  : null,
            ),
            onChanged: (val) {
              setState(() => _searchQuery = val);
              _refreshProducts();
            },
          ),
        ),
        Expanded(
          child: _isLoadingProducts
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Color(0xFF2D3449),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Tidak ada produk ditemukan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFBACBBE),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        showCheckboxColumn: false,
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFF222A3D),
                        ),
                        columns: const [
                          DataColumn(label: Text('Produk / SKU')),
                          DataColumn(label: Text('Stok'), numeric: true),
                          DataColumn(label: Text('Harga'), numeric: true),
                          DataColumn(label: Text('Tambah')),
                        ],
                        rows: _products.map((product) {
                          final stock = product.read<int>('stock_qty');
                          final cartIndex = _cartItems.indexWhere(
                            (item) => item.productId == product.read<int>('id'),
                          );
                          return DataRow(
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: 190,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.read<String>('name'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        product.read<String>('sku'),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFBACBBE),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: stock > 0
                                    ? () => _addToCart(product)
                                    : null,
                              ),
                              DataCell(Text('$stock')),
                              DataCell(
                                Text(
                                  _rupiahFormat.format(
                                    product.read<int>('selling_price'),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: cartIndex >= 0,
                                      onChanged: stock <= 0
                                          ? null
                                          : (selected) {
                                              if (selected == true) {
                                                _addToCart(product);
                                              } else if (cartIndex >= 0) {
                                                _updateQuantity(cartIndex, 0);
                                              }
                                            },
                                    ),
                                    IconButton(
                                      tooltip: 'Tambah ke keranjang',
                                      icon: const Icon(
                                        Icons.add_shopping_cart_rounded,
                                      ),
                                      onPressed: stock > 0
                                          ? () => _addToCart(product)
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildCartSection(ThemeData theme) {
    return Container(
      color: const Color(0xFF171F33),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF2D3449))),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: Color(0xFF00E599),
                ),
                const SizedBox(width: 8),
                Text(
                  'Keranjang (${_cartItems.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_cartItems.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => setState(() => _cartItems.clear()),
                    icon: const Icon(
                      Icons.delete_sweep_outlined,
                      size: 16,
                      color: Color(0xFFB42318),
                    ),
                    label: const Text(
                      'Kosongkan',
                      style: TextStyle(color: Color(0xFFB42318), fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
          if (_cartItems.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: 500,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: const Color(0xFF222A3D),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 190,
                      child: Text(
                        'Produk / Harga',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Text(
                        'Jumlah',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: Text(
                        'Subtotal',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _cartItems.isEmpty
                ? const Center(
                    child: Text(
                      'Pilih produk untuk menambah ke keranjang',
                      style: TextStyle(color: Color(0xFFBACBBE), fontSize: 13),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _cartItems.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          width: 500,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 190,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      _rupiahFormat.format(item.unitPrice),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFBACBBE),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () => _updateQuantity(
                                        index,
                                        item.quantity - 1,
                                      ),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: () => _updateQuantity(
                                        index,
                                        item.quantity + 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 140,
                                child: Text(
                                  _rupiahFormat.format(item.lineTotal),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0B1326),
              border: Border(top: BorderSide(color: Color(0xFF2D3449))),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(color: Color(0xFFBACBBE)),
                    ),
                    Text(_rupiahFormat.format(_cartTotal)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand Total:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFBACBBE),
                      ),
                    ),
                    Text(
                      _rupiahFormat.format(_cartTotal),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00E599),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _cartItems.isNotEmpty ? _handleCheckout : null,
                    icon: const Icon(Icons.payment_rounded),
                    label: const Text(
                      'Bayar Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E599),
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
        ],
      ),
    );
  }

  Widget _buildCompactCartBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF171F33),
        border: Border(top: BorderSide(color: Color(0xFF2D3449))),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_cartItems.length} Produk',
                style: const TextStyle(fontSize: 12, color: Color(0xFFBACBBE)),
              ),
              Text(
                _rupiahFormat.format(_cartTotal),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E599),
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _showCompactCart,
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text('Keranjang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E599),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCompactCart() async {
    final continueToCheckout = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * .82,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Daftar Belanja (${_cartItems.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_cartItems.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _cartItems.clear());
                          setSheetState(() {});
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Kosongkan'),
                      ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: _cartItems.isEmpty
                      ? const Center(child: Text('Keranjang masih kosong.'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                const Color(0xFF222A3D),
                              ),
                              columns: const [
                                DataColumn(label: Text('Produk')),
                                DataColumn(label: Text('Qty')),
                                DataColumn(label: Text('Harga'), numeric: true),
                                DataColumn(
                                  label: Text('Subtotal'),
                                  numeric: true,
                                ),
                              ],
                              rows: [
                                for (var i = 0; i < _cartItems.length; i++)
                                  DataRow(
                                    cells: [
                                      DataCell(
                                        SizedBox(
                                          width: 130,
                                          child: Text(
                                            _cartItems[i].name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              icon: const Icon(Icons.remove),
                                              onPressed: () async {
                                                await _updateQuantity(
                                                  i,
                                                  _cartItems[i].quantity - 1,
                                                );
                                                if (sheetContext.mounted) {
                                                  setSheetState(() {});
                                                }
                                              },
                                            ),
                                            Text('${_cartItems[i].quantity}'),
                                            IconButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              icon: const Icon(Icons.add),
                                              onPressed: () async {
                                                await _updateQuantity(
                                                  i,
                                                  _cartItems[i].quantity + 1,
                                                );
                                                if (sheetContext.mounted) {
                                                  setSheetState(() {});
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _rupiahFormat.format(
                                            _cartItems[i].unitPrice,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _rupiahFormat.format(
                                            _cartItems[i].lineTotal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                ),
                const Divider(),
                _summaryRow('Subtotal', _rupiahFormat.format(_cartTotal)),
                const SizedBox(height: 4),
                _summaryRow(
                  'Total Tagihan',
                  _rupiahFormat.format(_cartTotal),
                  strong: true,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _cartItems.isEmpty
                      ? null
                      : () {
                          Navigator.of(sheetContext).pop(true);
                        },
                  icon: const Icon(Icons.payment),
                  label: const Text('Lanjut ke pembayaran'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (continueToCheckout == true && mounted) {
      await _handleCheckout();
    }
  }

  Widget _summaryRow(String label, String value, {bool strong = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: strong ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: strong ? 20 : 15,
                fontWeight: FontWeight.bold,
                color: strong ? const Color(0xFF00E599) : null,
              ),
            ),
          ],
        ),
      );
}

class _ProductQuantityDialog extends StatefulWidget {
  const _ProductQuantityDialog({
    required this.productName,
    required this.unitPriceText,
    required this.stock,
    required this.initialQuantity,
  });

  final String productName;
  final String unitPriceText;
  final int stock;
  final int initialQuantity;

  @override
  State<_ProductQuantityDialog> createState() => _ProductQuantityDialogState();
}

class _ProductQuantityDialogState extends State<_ProductQuantityDialog> {
  late final TextEditingController _quantityController;
  late int _selectedQuantity;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _selectedQuantity = widget.initialQuantity;
    _quantityController = TextEditingController(text: '$_selectedQuantity');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _setQuantity(int quantity) {
    setState(() {
      _selectedQuantity = quantity;
      _quantityController.text = '$quantity';
      _validationMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF6DFFBA)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.productName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${widget.unitPriceText} per unit · Stok tersedia ${widget.stock}',
            style: const TextStyle(color: Color(0xFFBACBBE)),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                tooltip: 'Kurangi jumlah',
                onPressed: _selectedQuantity > 1
                    ? () => _setQuantity(_selectedQuantity - 1)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 88,
                child: TextField(
                  controller: _quantityController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    errorText: _validationMessage,
                  ),
                  onChanged: (value) => setState(() {
                    _selectedQuantity = int.tryParse(value) ?? 0;
                    _validationMessage = null;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                tooltip: 'Tambah jumlah',
                onPressed: _selectedQuantity < widget.stock
                    ? () => _setQuantity(_selectedQuantity + 1)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
            if (quantity < 1 || quantity > widget.stock) {
              setState(() {
                _validationMessage =
                    'Masukkan jumlah 1 sampai ${widget.stock}.';
              });
              return;
            }
            Navigator.pop(context, quantity);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
