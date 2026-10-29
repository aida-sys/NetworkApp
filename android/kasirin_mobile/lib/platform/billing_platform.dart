export 'billing_platform_stub.dart'
    if (dart.library.io) 'billing_platform_native.dart'
    if (dart.library.js_interop) 'billing_platform_web.dart';
