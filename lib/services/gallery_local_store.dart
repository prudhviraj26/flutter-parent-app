import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// WhatsApp-style local file store on flash disk.
/// Saves event photos directly in the private Veyho App Space (`getApplicationSupportDirectory()`).
/// The OS will NEVER purge these files under storage pressure.
/// Once saved, repeat visits 3 days or 6 months later read directly from local flash storage at $0.00 Azure egress.
class GalleryLocalStore {
  static Directory? _cachedDir;

  static Future<Directory> get _galleryDir async {
    if (_cachedDir != null && await _cachedDir!.exists()) {
      return _cachedDir!;
    }
    final baseDir = await getApplicationSupportDirectory();
    final dir = Directory('${baseDir.path}/veyho_gallery');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cachedDir = dir;
    return dir;
  }

  static String _sanitizeId(String mediaId) {
    return mediaId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  /// Check if local file exists in Veyho App Space
  static Future<File?> getLocalImageFile(String mediaId, {bool isThumbnail = false}) async {
    try {
      final dir = await _galleryDir;
      final prefix = isThumbnail ? 'thumb' : 'full';
      final safeId = _sanitizeId(mediaId);
      final file = File('${dir.path}/${prefix}_$safeId.jpg');
      if (await file.exists()) {
        final length = await file.length();
        if (length > 0) return file;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Save raw image bytes into Veyho App Space
  static Future<File?> saveImageBytes(
    String mediaId,
    Uint8List bytes, {
    bool isThumbnail = false,
  }) async {
    try {
      final dir = await _galleryDir;
      final prefix = isThumbnail ? 'thumb' : 'full';
      final safeId = _sanitizeId(mediaId);
      final file = File('${dir.path}/${prefix}_$safeId.jpg');
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (_) {
      return null;
    }
  }

  /// Fetch photo from local flash storage or download once from Azure
  static Future<File?> getOrDownloadImage(
    String mediaId,
    String url, {
    bool isThumbnail = false,
  }) async {
    // 1. Check local flash storage first
    final existing = await getLocalImageFile(mediaId, isThumbnail: isThumbnail);
    if (existing != null) {
      return existing;
    }

    if (url.isEmpty) return null;

    // 2. Download 1 time only from Azure SAS URL
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return await saveImageBytes(mediaId, response.bodyBytes, isThumbnail: isThumbnail);
      }
    } catch (_) {
      // Return null on failure, widget displays error placeholder
    }
    return null;
  }
}

/// A performant widget that renders an image from Veyho's local flash store.
/// If not yet cached, streams from Azure SAS URL, writes to local disk, and renders.
class VeyhoCachedImage extends StatefulWidget {
  final String mediaId;
  final String url;
  final bool isThumbnail;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const VeyhoCachedImage({
    super.key,
    required this.mediaId,
    required this.url,
    this.isThumbnail = true,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<VeyhoCachedImage> createState() => _VeyhoCachedImageState();
}

class _VeyhoCachedImageState extends State<VeyhoCachedImage> {
  File? _localFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant VeyhoCachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaId != widget.mediaId || oldWidget.url != widget.url) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    // Quick check if already on local flash disk
    final cached = await GalleryLocalStore.getLocalImageFile(
      widget.mediaId,
      isThumbnail: widget.isThumbnail,
    );
    if (cached != null) {
      if (mounted) {
        setState(() {
          _localFile = cached;
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // Download once and write to flash disk
    final downloaded = await GalleryLocalStore.getOrDownloadImage(
      widget.mediaId,
      widget.url,
      isThumbnail: widget.isThumbnail,
    );

    if (mounted) {
      setState(() {
        _localFile = downloaded;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localFile != null) {
      return Image.file(
        _localFile!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ??
              Container(
                width: widget.width,
                height: widget.height,
                color: const Color(0xFFF1F5F9),
                child: const Icon(Icons.broken_image_rounded, size: 28, color: Color(0xFF94A3B8)),
              );
        },
      );
    }

    if (_isLoading) {
      return widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: const Color(0xFFF1F5F9),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
              ),
            ),
          );
    }

    return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height,
          color: const Color(0xFFF1F5F9),
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_rounded, size: 26, color: Color(0xFF94A3B8)),
        );
  }
}
