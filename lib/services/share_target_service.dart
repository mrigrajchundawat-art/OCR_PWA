import 'package:flutter/foundation.dart';

/// Checks if the app was launched via Web Share Target with a shared image.
bool get hasSharedImage {
  if (!kIsWeb) return false;
  return Uri.base.queryParameters['shared'] == '1';
}

/// URL to fetch the shared image (served from service worker cache).
String get sharedImageUrl {
  return '${Uri.base.origin}/__shared-image__';
}

/// Error message if share failed.
String? get shareError {
  if (!kIsWeb) return null;
  final error = Uri.base.queryParameters['error'];
  if (error == 'no_image') return 'No image was shared.';
  if (error == 'share_failed') return 'Failed to process shared content.';
  return null;
}
