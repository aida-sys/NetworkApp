# Desktop Parity Matrix

Status captured 2026-10-24 from the active desktop services/tests and current mobile code. `Partial` means a usable slice exists but desktop behavior or required validation is missing. Repository tests are present; execution status is reported separately because Android SDK command-line tools are absent.

| Feature / flow | Desktop source of truth | Mobile surface | Status |
|---|---|---|---|
| First-run OWNER setup, no demo data | `../../app/services/owner_setup_service.py`; `../../tests/test_owner_setup.py` | `/setup`, `PosRepository.createOwner` creates OWNER roles, account, and MAIN store in one transaction | Partial; repository contract test exists, not executable in this environment |
| Local authentication, lockout, active user, login history | `../../app/services/auth_service.py`; `../../app/core/security.py`; `../../tests/test_auth_service.py` | `/login`, local session, 5-attempt/15-minute lockout and login history in repository | Partial; desktop Argon2 hashes are not compatible with mobile PBKDF2 hashes; password-change flow absent |
| Role routing and permission enforcement | `../../app/models/entities.py`; `../../tests/test_security.py` | Cashier route restriction and OWNER/other role shell | Partial; no domain permission matrix/use-case guards or user management |
| Store and product basics | `../../app/services/master_data_service.py`; `../../tests/test_master_data.py` | Setup store, product search by name/SKU/barcode and product creation with initial stock movement | Partial; no edit, soft delete, category/unit/supplier UX, barcode form, or import |
| Tiered wholesale pricing | `../../app/services/bulk_pricing_service.py`; `../../tests/test_master_data.py` | Repository quote and checkout recompute highest eligible tier | Partial; repository test covers threshold; UI quantity changes refresh price; desktop tier-count/rounding parity needs more tests |
| Shift open/close and cashier daily report | `../../app/services/shift_service.py`; `../../app/services/cashier_daily_report_service.py`; `../../tests/test_cashier_view.py` | Cashier page opens a shift and shows active shift state | Partial; close/count/variance and daily report absent |
| Checkout, cash payment, stock, journal and audit | `../../app/services/sales_service.py`; `../../app/services/financial_service.py`; `../../tests/test_all_views_and_full_app.py`; `../../tests/test_read_only_mode.py` | Cart, numeric cash received, repository atomic transaction, retry by invoice, receipt result | Partial; repository tests cover commit/retry/rollback/ledger/tier; no runtime test executed yet; discounts, multiple methods, customer, print/share, refund and license lock absent |
| Customers and suppliers | `../../app/services/master_data_service.py`; `../../app/services/supplier_service.py`; `../../tests/test_supplier.py` | No mobile feature | Not implemented |
| Purchases, PAID/TEMPO/DP, partial payment, stock receipt | `../../app/services/purchase_service.py`; `../../app/services/financial_service.py`; `../../tests/test_purchase.py` | No mobile feature | Not implemented |
| Inventory, stock movement history, opname and non-sale inventory | `../../app/services/inventory_service.py`; `../../tests/test_inventory.py` | Checkout and initial product stock movements only | Partial; no inventory UX/opname |
| Financial initialization, accounts, balanced journals, expenses/payments | `../../app/services/financial_service.py`; `../../tests/test_financial_service.py` | Checkout creates baseline accounts and sale/COGS journal | Partial; no finance workflows/reports; zero/unknown purchase cost has no invented COGS |
| Sales, inventory, attendance and financial reports | `../../app/services/report_service.py`; `../../app/services/report_periods.py`; `../../tests/test_reports.py`; `../../tests/test_attendance.py` | Owner overview of all-time sale count/value and low-stock count | Partial; not equivalent to desktop reports or period semantics |
| Store profile, receipt and payment settings/wizard | `../../app/services/store_settings_service.py`; `../../app/services/payment_settings_service.py`; `../../app/services/payment_wizard_service.py`; `../../tests/test_store_settings.py`; `../../tests/test_payment_wizard.py` | Store name at initial setup; cash-only checkout | Partial; no settings wizard or other methods |
| Trial, read-only mode, license documents | `../../app/services/trial_service.py`; `../../app/services/license_service.py`; `../../tests/test_trial_service.py`; `../../tests/test_license_service.py`; `../../tests/test_read_only_mode.py` | Persisted seven-day trial with clock rollback guard; expired-trial sales require an active server license | Partial; mobile checks server online at checkout and does not yet verify/store signed licenses for offline use |
| Billing auth, device registration, subscription and license polling | `../../app/services/billing_client.py`; `../../server/app/main.py`; `../../tests/test_server_billing.py` | Securely stored billing account/device tokens, device registration, plan listing, hosted checkout, and polling | Implemented for online billing; payment confirmation depends on Midtrans and `/api/pos/license` |
| Barcode camera, receipt printing, import/export and local backup | `../../app/hardware/`; `../../app/services/product_import_service.py`; `../../tests/test_printer.py`; `../../tests/test_product_import.py` | Search accepts typed/scanner-wedge text; no platform adapter | Partial for manual search only; hardware unverified |

## Next Work

1. Resolve Android command-line tools and run analyzer/tests/build; add setup-to-checkout widget/integration coverage and migration tests.
2. Add safe password-hash compatibility/migration and domain permission guards before broader staff use.
3. Complete shift closing, discounts/customers/multiple payment methods, refund, store and product CRUD.
4. Implement purchase/inventory, finance and reports with desktop-source tests.
5. Add mobile verification and offline storage for signed licenses, with Windows and Android contract coverage.
6. Add supported file/hardware adapters and validate on real Android/iOS devices.

The app stores POS data in its app-private local SQLite file. Transaction synchronization is not implemented; billing calls cover account, device, subscription and license only. Desktop source under `../../app/` remains unchanged.
