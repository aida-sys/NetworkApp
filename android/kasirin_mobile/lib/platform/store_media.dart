export 'store_media_stub.dart'
    if (dart.library.io) 'store_media_native.dart'
    if (dart.library.js_interop) 'store_media_web.dart';
