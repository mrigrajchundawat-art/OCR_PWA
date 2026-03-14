import 'dart:async';
import 'dart:html' as html;

/// Picks an image via file input and returns its object URL for OCR.
Future<String?> pickImageUrl() async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..style.display = 'none';
  html.document.body?.append(input);

  final completer = Completer<String?>();
  void cleanup() {
    input.remove();
  }

  input.onChange.listen((_) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      completer.complete(null);
      cleanup();
      return;
    }
    final file = files[0];
    if (!file.type.startsWith('image/')) {
      completer.complete(null);
      cleanup();
      return;
    }
    final url = html.Url.createObjectUrlFromBlob(file);
    completer.complete(url);
    cleanup();
  });

  input.click();

  return completer.future;
}
