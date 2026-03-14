import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/image_picker_service.dart';
import '../services/ocr_service.dart';
import '../services/share_target_service.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  final OcrService _ocr = createOcrService();

  bool _loading = false;
  String? _error;
  String? _extractedText;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _checkSharedImage();
  }

  void _checkSharedImage() {
    if (shareError != null) {
      setState(() => _error = shareError);
      return;
    }
    if (hasSharedImage) {
      _imageUrl = sharedImageUrl;
      _runOcr();
    }
  }

  Future<void> _runOcr() async {
    final url = _imageUrl ?? sharedImageUrl;
    setState(() {
      _loading = true;
      _error = null;
      _extractedText = null;
    });
    try {
      final text = await _ocr.recognize(url);
      if (mounted) {
        setState(() {
          _loading = false;
          _extractedText = text.trim().isEmpty ? 'No text detected.' : text;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'OCR failed: $e';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final url = await pickImageUrl();
    if (url != null && mounted) {
      _imageUrl = url;
      _runOcr();
    }
  }

  void _scanAnother() {
    setState(() {
      _imageUrl = null;
      _extractedText = null;
      _error = null;
    });
  }

  void _copyText() {
    if (_extractedText == null || _extractedText!.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _extractedText!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text(
          'OCR Scanner',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: const Color(0xFF161B22),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_extractedText != null)
            IconButton(
              onPressed: _scanAnother,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              tooltip: 'Scan another',
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _buildError();
    }
    if (_loading) {
      return _buildLoading();
    }
    if (_extractedText != null) {
      return _buildResult();
    }
    return _buildEmpty();
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Share an image from another app to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF238636),
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 20),
          Text(
            'Extracting text (English & Hindi)...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _imageUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: const Color(0xFF21262D),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF238636),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Extracted Text',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
                          color: const Color(0xFF238636),
                          tooltip: 'Scan another',
                        ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _copyText,
                          icon: const Icon(Icons.copy, size: 20),
                          color: const Color(0xFF238636),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF238636).withValues(alpha: 0.15),
                          ),
                        ),
                        IconButton(
                          onPressed: _scanAnother,
                          icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
                          color: const Color(0xFF238636),
                          tooltip: 'Scan another',
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF238636).withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                  ],
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _extractedText!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF238636).withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.image_outlined,
                size: 56,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Share an image to extract text',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Install this app, then share images from your gallery or camera.\nSupports English & Hindi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library_outlined, size: 20),
              label: const Text('Pick image'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
