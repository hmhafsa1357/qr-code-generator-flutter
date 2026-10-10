import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import '../theme/app_theme.dart';
import '../models/qr_history_item.dart';
import '../services/history_service.dart';

/// Shows the generated QR code and lets the user save it to their gallery
/// or share it via the system share sheet.
class ResultScreen extends StatefulWidget {
  final String content;
  final String type;

  const ResultScreen({super.key, required this.content, required this.type});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final HistoryService _historyService = HistoryService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Record this QR code in history as soon as it's generated.
    _historyService.addToHistory(
      QrHistoryItem(
        content: widget.content,
        type: widget.type,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<Uint8List?> _captureQrImage() {
    return _screenshotController.capture(pixelRatio: 3);
  }

  Future<void> _onSavePressed() async {
    setState(() => _saving = true);
    try {
      final bytes = await _captureQrImage();
      if (bytes == null) throw Exception('Could not capture QR code');

      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permission denied to save photos')),
            );
          }
          return;
        }
      }

      await Gal.putImageBytes(bytes, name: 'qr_${DateTime.now().millisecondsSinceEpoch}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR code saved to gallery')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onSharePressed() async {
    try {
      final bytes = await _captureQrImage();
      if (bytes == null) throw Exception('Could not capture QR code');

      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: widget.content,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your QR code')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: QrImageView(
                    data: widget.content,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppTheme.navyDark,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppTheme.navyDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.content,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : _onSavePressed,
                      icon: _saving
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.download),
                      label: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _onSharePressed,
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}