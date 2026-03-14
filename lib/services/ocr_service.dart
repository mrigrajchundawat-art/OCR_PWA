import 'dart:html' as html;
import 'dart:js_util';

/// OCR service using Tesseract.js (loaded via script in index.html).
/// Supports English (eng) and Hindi (hin).
abstract class OcrService {
  Future<String> recognize(String imageUrl);
}

/// Web implementation using Tesseract.js.
OcrService createOcrService() => WebOcrService();

class WebOcrService implements OcrService {
  @override
  Future<String> recognize(String imageUrl) async {
    final tesseract = getProperty(html.window, 'Tesseract');
    if (tesseract == null) {
      throw StateError(
        'Tesseract.js not loaded. Ensure the script is in index.html.',
      );
    }
    final promise = callMethod(tesseract, 'recognize', [imageUrl, 'eng+hin']);
    final result = await promiseToFuture<dynamic>(promise);
    if (result == null) return '';
    final data = getProperty(result, 'data');
    if (data == null) return '';
    final text = getProperty(data, 'text');
    return text?.toString() ?? '';
  }
}
