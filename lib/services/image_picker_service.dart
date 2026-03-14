import 'image_picker_service_stub.dart'
    if (dart.library.html) 'image_picker_service_web.dart' as impl;

/// Picks an image and returns its URL for OCR.
/// Web: uses hidden file input. Other platforms: returns null.
Future<String?> pickImageUrl() => impl.pickImageUrl();
