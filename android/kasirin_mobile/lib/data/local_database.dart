import 'package:drift/drift.dart';

import 'database_connection.dart'
    if (dart.library.io) 'database_connection_native.dart'
    if (dart.library.js_interop) 'database_connection_web.dart' as connection;

const _schemaStatements = <String>[
  '''CREATE TABLE roles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
  )''',
  '''CREATE TABLE permissions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''CREATE TABLE role_permissions (
    role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INTEGER NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
  )''',
  '''CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    whatsapp TEXT,
    password_hash TEXT NOT NULL,
    role_id INTEGER NOT NULL REFERENCES roles(id),
    is_active INTEGER NOT NULL DEFAULT 1,
    failed_login_count INTEGER NOT NULL DEFAULT 0,
    locked_until TEXT,
    last_login_at TEXT,
    must_change_password INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
  )''',
  'CREATE INDEX ix_users_username ON users(username)',
  '''CREATE TABLE stores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    slogan TEXT,
    address TEXT,
    whatsapp TEXT,
    logo_path TEXT,
    banner_path TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
  )''',
  '''CREATE TABLE payment_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cash_enabled INTEGER NOT NULL DEFAULT 1,
    qris_dana_enabled INTEGER NOT NULL DEFAULT 0,
    qris_midtrans_enabled INTEGER NOT NULL DEFAULT 0,
    transfer_enabled INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''CREATE TABLE payment_wizard_states (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    method TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'not_started',
    payload TEXT NOT NULL DEFAULT '',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
  )''',
  '''CREATE TABLE units (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    symbol TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
  )''',
  '''CREATE TABLE suppliers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
  )''',
  '''CREATE TABLE products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sku TEXT NOT NULL UNIQUE,
    barcode TEXT UNIQUE,
    name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(id),
    unit_id INTEGER REFERENCES units(id),
    supplier_id INTEGER REFERENCES suppliers(id),
    purchase_price INTEGER NOT NULL DEFAULT 0,
    selling_price INTEGER NOT NULL DEFAULT 0,
    stock_qty INTEGER NOT NULL DEFAULT 0,
    min_stock INTEGER NOT NULL DEFAULT 0,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
  )''',
  'CREATE INDEX ix_products_sku ON products(sku)',
  'CREATE INDEX ix_products_barcode ON products(barcode)',
  '''CREATE TABLE login_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id),
    login_at TEXT NOT NULL
  )''',
  'CREATE INDEX ix_login_history_user_id ON login_history(user_id)',
  'CREATE INDEX ix_login_history_login_at ON login_history(login_at)',
  '''CREATE TABLE inventaris_toko (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    kode_inventaris TEXT NOT NULL UNIQUE,
    nama_barang TEXT NOT NULL,
    jumlah INTEGER NOT NULL DEFAULT 0,
    satuan TEXT,
    tanggal_perolehan TEXT,
    harga_perolehan INTEGER NOT NULL DEFAULT 0,
    lokasi TEXT,
    kondisi TEXT NOT NULL DEFAULT 'Baik',
    keterangan TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
  )''',
  'CREATE INDEX ix_inventaris_toko_kode_inventaris ON inventaris_toko(kode_inventaris)',
  '''CREATE TABLE bulk_price_rules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity_threshold INTEGER NOT NULL CHECK(quantity_threshold >= 1),
    discount_percent NUMERIC(5, 2) NOT NULL CHECK(discount_percent > 0 AND discount_percent <= 100),
    special_price INTEGER NOT NULL DEFAULT 0 CHECK(special_price >= 0),
    quantity_multiplier INTEGER NOT NULL DEFAULT 2 CHECK(quantity_multiplier >= 2),
    multiple_special_price INTEGER NOT NULL DEFAULT 0 CHECK(multiple_special_price >= 0),
    multiple_quantity_threshold INTEGER NOT NULL DEFAULT 0 CHECK(multiple_quantity_threshold >= 0),
    pricing_mode TEXT NOT NULL DEFAULT 'PERCENT' CHECK(pricing_mode IN ('PRICE', 'PERCENT')),
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    UNIQUE(product_id, quantity_threshold)
  )''',
  '''CREATE TABLE shifts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    store_id INTEGER NOT NULL REFERENCES stores(id),
    cashier_id INTEGER NOT NULL REFERENCES users(id),
    opened_at TEXT NOT NULL,
    closed_at TEXT,
    opening_cash INTEGER NOT NULL DEFAULT 0,
    closing_cash INTEGER,
    status TEXT NOT NULL DEFAULT 'OPEN',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''CREATE TABLE customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    phone TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
  )''',
  '''CREATE TABLE sales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_no TEXT NOT NULL UNIQUE,
    store_id INTEGER NOT NULL REFERENCES stores(id),
    shift_id INTEGER NOT NULL REFERENCES shifts(id),
    cashier_id INTEGER NOT NULL REFERENCES users(id),
    customer_id INTEGER REFERENCES customers(id),
    subtotal INTEGER NOT NULL DEFAULT 0,
    discount INTEGER NOT NULL DEFAULT 0,
    tax INTEGER NOT NULL DEFAULT 0,
    grand_total INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'PAID',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''CREATE TABLE cashier_daily_reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cashier_id INTEGER NOT NULL REFERENCES users(id),
    report_date TEXT NOT NULL,
    sales_count INTEGER NOT NULL DEFAULT 0 CHECK(sales_count >= 0),
    sales_total INTEGER NOT NULL DEFAULT 0 CHECK(sales_total >= 0),
    notes TEXT NOT NULL DEFAULT '',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    UNIQUE(cashier_id, report_date)
  )''',
  'CREATE INDEX ix_cashier_daily_reports_report_date ON cashier_daily_reports(report_date)',
  '''CREATE TABLE sale_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sale_id INTEGER NOT NULL REFERENCES sales(id),
    product_id INTEGER NOT NULL REFERENCES products(id),
    qty INTEGER NOT NULL,
    unit_price INTEGER NOT NULL,
    unit_cost INTEGER,
    discount INTEGER NOT NULL DEFAULT 0,
    line_total INTEGER NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''CREATE TABLE payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sale_id INTEGER NOT NULL REFERENCES sales(id),
    method TEXT NOT NULL,
    amount INTEGER NOT NULL,
    reference TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''CREATE TABLE stock_movements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL REFERENCES products(id),
    movement_type TEXT NOT NULL,
    stock_before INTEGER NOT NULL,
    qty INTEGER NOT NULL,
    stock_after INTEGER NOT NULL,
    reference_type TEXT,
    reference_id INTEGER,
    note TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''CREATE TABLE payment_methods (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
  )''',
  '''CREATE TABLE price_lists (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    starts_at TEXT,
    ends_at TEXT,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
  )''',
  '''CREATE TABLE price_list_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    price_list_id INTEGER NOT NULL REFERENCES price_lists(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    price INTEGER NOT NULL CHECK(price >= 0),
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    UNIQUE(price_list_id, product_id)
  )''',
  '''CREATE TABLE promotions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    discount_type TEXT NOT NULL CHECK(discount_type IN ('AMOUNT', 'PERCENT')),
    discount_value INTEGER NOT NULL CHECK(discount_value > 0),
    product_id INTEGER REFERENCES products(id),
    category_id INTEGER REFERENCES categories(id),
    starts_at TEXT,
    ends_at TEXT,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT,
    CHECK(discount_type != 'PERCENT' OR discount_value <= 100),
    CHECK(ends_at IS NULL OR starts_at IS NULL OR ends_at >= starts_at)
  )''',
  '''CREATE TABLE purchase_orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_no TEXT NOT NULL UNIQUE,
    supplier_id INTEGER NOT NULL REFERENCES suppliers(id),
    store_id INTEGER NOT NULL REFERENCES stores(id),
    created_by INTEGER NOT NULL REFERENCES users(id),
    status TEXT NOT NULL DEFAULT 'DRAFT',
    ordered_at TEXT,
    expected_at TEXT,
    subtotal INTEGER NOT NULL DEFAULT 0 CHECK(subtotal >= 0),
    payment_status TEXT NOT NULL DEFAULT 'PAID' CHECK(payment_status IN ('PAID', 'TEMPO', 'DP')),
    due_date TEXT,
    paid_amount INTEGER NOT NULL DEFAULT 0 CHECK(paid_amount >= 0 AND paid_amount <= subtotal),
    notes TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    CHECK((payment_status = 'PAID' AND paid_amount = subtotal) OR (payment_status = 'TEMPO' AND due_date IS NOT NULL) OR (payment_status = 'DP' AND paid_amount > 0 AND paid_amount < subtotal AND due_date IS NOT NULL))
  )''',
  '''CREATE TABLE purchase_order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_order_id INTEGER NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    ordered_qty INTEGER NOT NULL CHECK(ordered_qty > 0),
    received_qty INTEGER NOT NULL DEFAULT 0 CHECK(received_qty >= 0),
    unit_cost INTEGER NOT NULL CHECK(unit_cost >= 0),
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''CREATE TABLE stock_opnames (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    opname_no TEXT NOT NULL UNIQUE,
    store_id INTEGER NOT NULL REFERENCES stores(id),
    counted_by INTEGER NOT NULL REFERENCES users(id),
    status TEXT NOT NULL DEFAULT 'DRAFT',
    counted_at TEXT,
    notes TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''CREATE TABLE stock_opname_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    stock_opname_id INTEGER NOT NULL REFERENCES stock_opnames(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    system_qty INTEGER NOT NULL CHECK(system_qty >= 0),
    counted_qty INTEGER NOT NULL CHECK(counted_qty >= 0),
    notes TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    UNIQUE(stock_opname_id, product_id)
  )''',
  '''CREATE TABLE accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    account_type TEXT NOT NULL CHECK(account_type IN ('ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE')),
    is_active INTEGER NOT NULL DEFAULT 1,
    is_system INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''CREATE TABLE financial_settings (
    id INTEGER PRIMARY KEY,
    effective_from TEXT,
    initialized_by INTEGER REFERENCES users(id),
    initialized_at TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''CREATE TABLE expenses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shift_id INTEGER REFERENCES shifts(id),
    recorded_by INTEGER NOT NULL REFERENCES users(id),
    category TEXT NOT NULL,
    amount INTEGER NOT NULL CHECK(amount > 0),
    paid_amount INTEGER NOT NULL DEFAULT 0,
    payment_status TEXT NOT NULL DEFAULT 'CASH' CHECK(payment_status IN ('CASH', 'HUTANG', 'DP')),
    due_date TEXT,
    payee TEXT,
    account_id INTEGER REFERENCES accounts(id),
    incurred_at TEXT NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''CREATE TABLE journal_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    entry_date TEXT NOT NULL,
    source_type TEXT NOT NULL,
    source_id INTEGER NOT NULL,
    memo TEXT NOT NULL,
    posted_by INTEGER NOT NULL REFERENCES users(id),
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    UNIQUE(source_type, source_id)
  )''',
  'CREATE INDEX ix_journal_entries_entry_date ON journal_entries(entry_date)',
  '''CREATE TABLE journal_lines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    journal_entry_id INTEGER NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
    account_id INTEGER NOT NULL REFERENCES accounts(id),
    debit INTEGER NOT NULL DEFAULT 0,
    credit INTEGER NOT NULL DEFAULT 0,
    description TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    CHECK((debit > 0 AND credit = 0) OR (credit > 0 AND debit = 0))
  )''',
  'CREATE INDEX ix_journal_lines_journal_entry_id ON journal_lines(journal_entry_id)',
  '''CREATE TABLE financial_payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_order_id INTEGER REFERENCES purchase_orders(id),
    expense_id INTEGER REFERENCES expenses(id),
    account_id INTEGER NOT NULL REFERENCES accounts(id),
    amount INTEGER NOT NULL CHECK(amount > 0),
    payment_method TEXT NOT NULL,
    paid_at TEXT NOT NULL,
    created_by INTEGER NOT NULL REFERENCES users(id),
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    CHECK((purchase_order_id IS NOT NULL AND expense_id IS NULL) OR (purchase_order_id IS NULL AND expense_id IS NOT NULL))
  )''',
  'CREATE INDEX ix_financial_payments_purchase_order_id ON financial_payments(purchase_order_id)',
  'CREATE INDEX ix_financial_payments_expense_id ON financial_payments(expense_id)',
  '''CREATE TABLE cash_transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shift_id INTEGER NOT NULL REFERENCES shifts(id),
    transaction_type TEXT NOT NULL,
    amount INTEGER NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''CREATE TABLE audit_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER REFERENCES users(id),
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id INTEGER,
    detail TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
];

class KasirinDatabase extends GeneratedDatabase {
  KasirinDatabase(super.executor);

  factory KasirinDatabase.memory() =>
      KasirinDatabase(connection.createMemoryExecutor());

  @override
  int get schemaVersion => 4;

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      for (final statement in _schemaStatements) {
        await customStatement(statement);
      }
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 1 && to >= 1) {
        for (final statement in _schemaStatements) {
          await customStatement(statement);
        }
      }
      if (from >= 1 && from < 2 && to >= 2) {
        await customStatement(
          'ALTER TABLE bulk_price_rules ADD COLUMN quantity_multiplier INTEGER NOT NULL DEFAULT 2 CHECK(quantity_multiplier >= 2)',
        );
        await customStatement(
          'ALTER TABLE bulk_price_rules ADD COLUMN multiple_special_price INTEGER NOT NULL DEFAULT 0 CHECK(multiple_special_price >= 0)',
        );
      }
      if (from >= 1 && from < 3 && to >= 3) {
        await customStatement('ALTER TABLE stores ADD COLUMN banner_path TEXT');
      }
      if (from >= 1 && from < 4 && to >= 4) {
        await customStatement(
          'ALTER TABLE bulk_price_rules ADD COLUMN multiple_quantity_threshold INTEGER NOT NULL DEFAULT 0 CHECK(multiple_quantity_threshold >= 0)',
        );
        await customStatement(
          'UPDATE bulk_price_rules SET multiple_quantity_threshold = quantity_threshold * quantity_multiplier WHERE multiple_special_price > 0',
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA busy_timeout = 5000');
    },
  );
}

Future<KasirinDatabase> openKasirinDatabase() async {
  final database = KasirinDatabase(await connection.openExecutor());
  await database.customSelect('SELECT 1').get();
  return database;
}
