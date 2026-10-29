# Kasirin Mobile - Server Integration Parity Matrix

## Integration Status: Mobile App â†” Billing Server

| Feature | Status | Notes | Server Reference |
|---|---|---|---|
| Persisted trial | Implemented | Seven-day trial starts on first app launch, persists in secure storage, and uses the desktop clock rollback high-water rule. New sales are blocked after expiry unless the server reports an active license. | `app/services/trial_service.py` behavior |
| Customer authentication | Implemented | Billing account register/login is separate from the local POS owner/cashier account. Customer token is stored in Android secure storage. | `POST /api/auth/register`, `POST /api/auth/login` |
| Device registration | Implemented | Stable installation UUID and 64-character device identifier are sent as a versioned POS request with customer bearer token. Device token and PK are securely stored. | `POST /api/pos/register` |
| License status | Implemented | UI reports activation only when the device license response says `status=active`; server document is returned with that status. | `GET /api/pos/license` |
| Subscription and plans | Implemented | Fetches server subscription status and plan catalog. | `GET /api/pos/status` |
| Checkout | Implemented | Sends customer bearer token, device PK, and selected plan code. | `POST /api/checkout/create` |
| Payment handoff | Implemented with server URL field | Opens server-supplied HTTPS `payment_url` in Android browser and polls device license after returning. It does not mark checkout creation itself as paid. | Checkout response `payment_url`; server Midtrans verification |
| Server health | Partial | Client health helper is available; the license view uses billing operations directly and does not show a separate health indicator. | `GET /health` |
| POS transaction synchronization | Not implemented | Local POS data remains on-device; billing calls only cover account, device, subscription and license. | Out of scope |

## Notes

- `BILLING_BASE_URL` can be supplied at build time with `--dart-define=BILLING_BASE_URL=https://your-billing-host`.
- Android payment handoff uses an HTTPS `ACTION_VIEW` intent through a Flutter method channel; no additional Dart package is required.
- Midtrans payment completion is confirmed by the billing server and license endpoint, never by the browser return alone.
- Local POS authentication remains independent from billing account authentication.
