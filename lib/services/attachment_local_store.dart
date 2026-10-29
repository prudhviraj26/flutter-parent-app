import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';

/// WhatsApp-style local file store on flash disk for School Notice and Class Updates attachments.
/// Saves attachments directly in the private Veyho App Space (`getApplicationSupportDirectory()/veyho_attachments`).
/// The OS will NEVER purge these files under storage pressure.
/// Once saved, repeat visits days or months later read directly from local flash storage at $0.00 Azure egress.
/// Automatically cleans up prior academic year attachments upon session transition.
class AttachmentLocalStore {
  static Directory? _cachedDir;

  static Future<Directory> get _attachmentDir async {
    if (_cachedDir != null && await _cachedDir!.exists()) {
      return _cachedDir!;
    }
    final baseDir = await getApplicationSupportDirectory();
    final dir = Directory('${baseDir.path}/veyho_attachments');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cachedDir = dir;
    return dir;
  }

  static String _sanitize(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }

  static String _formatDateSlug(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '';
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt != null) {
        final y = dt.year.toString().padLeft(4, '0');
        final m = dt.month.toString().padLeft(2, '0');
        final d = dt.day.toString().padLeft(2, '0');
        return '$y-$m-$d';
      }
    } catch (_) {}
    final cleaned = dateStr.replaceAll(RegExp(r'[^0-9-]'), '');
    return cleaned.length >= 10 ? cleaned.substring(0, 10) : cleaned;
  }

  static String _buildFilename(String key, String? dateStr, String? originalFileName) {
    final safeKey = _sanitize(key);
    final dateSlug = _formatDateSlug(dateStr);
    final safeName = originalFileName != null && originalFileName.isNotEmpty
        ? _sanitize(originalFileName)
        : 'attachment.bin';

    if (dateSlug.isNotEmpty) {
      return '${dateSlug}_${safeKey}_$safeName';
    }
    return '${safeKey}_$safeName';
  }

  /// Check if attachment already exists on local flash disk
  static Future<File?> getLocalFile(
    String key, {
    String? dateStr,
    String? originalFileName,
  }) async {
    try {
      final dir = await _attachmentDir;
      final filename = _buildFilename(key, dateStr, originalFileName);
      final file = File('${dir.path}/$filename');
      if (await file.exists() && await file.length() > 0) {
        return file;
      }

      // Fallback: check if any file in dir contains the safe key
      final safeKey = _sanitize(key);
      if (safeKey.isNotEmpty && await dir.exists()) {
        final entities = dir.listSync();
        for (final entity in entities) {
          if (entity is File) {
            final name = entity.uri.pathSegments.isNotEmpty
                ? entity.uri.pathSegments.last
                : entity.path.split(Platform.pathSeparator).last;
            if (name.contains(safeKey) && await entity.length() > 0) {
              return entity;
            }
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get locally cached file or download once from Azure SAS URL
  static Future<File?> getOrDownloadAttachment({
    required String key,
    required String url,
    String? dateStr,
    String? originalFileName,
    void Function(double progress)? onProgress,
  }) async {
    // 1. Check local flash disk first (0ms, zero Azure egress)
    final existing = await getLocalFile(key, dateStr: dateStr, originalFileName: originalFileName);
    if (existing != null) {
      if (onProgress != null) onProgress(1.0);
      return existing;
    }

    if (url.trim().isEmpty) return null;

    // 2. Download once from Azure SAS URL
    try {
      final uri = Uri.parse(url);
      final request = http.Request('GET', uri);
      final response = await request.send();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final totalBytes = response.contentLength ?? 0;
        int receivedBytes = 0;
        final List<int> bytes = [];

        await for (final chunk in response.stream) {
          bytes.addAll(chunk);
          receivedBytes += chunk.length;
          if (totalBytes > 0 && onProgress != null) {
            onProgress((receivedBytes / totalBytes).clamp(0.0, 1.0));
          }
        }

        final dir = await _attachmentDir;
        final filename = _buildFilename(key, dateStr, originalFileName);
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes, flush: true);

        if (onProgress != null) onProgress(1.0);
        return file;
      }
    } catch (e) {
      debugPrint('AttachmentLocalStore: Download error for $url: $e');
    }
    return null;
  }

  /// Open an attachment: if cached, opens instantly; if not cached, downloads with live progress then opens
  static Future<void> openAttachment({
    required BuildContext context,
    required String key,
    required String url,
    String? dateStr,
    String? originalFileName,
  }) async {
    // Check if already in local store
    final existing = await getLocalFile(key, dateStr: dateStr, originalFileName: originalFileName);
    if (!context.mounted) return;
    if (existing != null) {
      final openResult = await OpenFilex.open(existing.path);
      if (openResult.type != ResultType.done) {
        if (!context.mounted) return;
        // Fallback to URL launcher if native viewer is absent
        await _launchFallbackUrl(context, url);
      }
      return;
    }

    // Not cached yet: show download progress modal
    final progressNotifier = ValueNotifier<double>(0.0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_download_outlined,
                      color: AppColors.primaryTeal,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    originalFileName != null && originalFileName.isNotEmpty
                        ? 'Opening ${originalFileName.length > 24 ? "${originalFileName.substring(0, 21)}..." : originalFileName}'
                        : 'Opening Attachment',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ValueListenableBuilder<double>(
                    valueListenable: progressNotifier,
                    builder: (context, value, _) {
                      final percent = (value * 100).round();
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: value > 0 ? value : null,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE2E8F0),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            value > 0 ? '$percent%' : 'Downloading...',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    File? downloadedFile;
    try {
      downloadedFile = await getOrDownloadAttachment(
        key: key,
        url: url,
        dateStr: dateStr,
        originalFileName: originalFileName,
        onProgress: (p) => progressNotifier.value = p,
      );
    } finally {
      if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (!context.mounted) return;
    if (downloadedFile != null && await downloadedFile.exists()) {
      final openResult = await OpenFilex.open(downloadedFile.path);
      if (openResult.type != ResultType.done) {
        if (!context.mounted) return;
        await _launchFallbackUrl(context, url);
      }
    } else {
      if (!context.mounted) return;
      await _launchFallbackUrl(context, url);
    }
  }

  static Future<void> _launchFallbackUrl(BuildContext context, String url) async {
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open attachment link')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

  /// Automatically cleans up locally stored attachments belonging to prior academic years.
  /// Runs asynchronously in background to ensure zero UI delay.
  static Future<int> autoCleanupPriorAcademicYear(DateTime activeAcademicYearStartDate) async {
    int deletedCount = 0;
    try {
      final dir = await _attachmentDir;
      if (!await dir.exists()) return 0;

      final entities = dir.listSync();
      final datePattern = RegExp(r'^(\d{4}-\d{2}-\d{2})_(.+)$');

      for (final entity in entities) {
        if (entity is! File) continue;
        final filename = entity.uri.pathSegments.isNotEmpty
            ? entity.uri.pathSegments.last
            : entity.path.split(Platform.pathSeparator).last;

        final match = datePattern.firstMatch(filename);
        if (match != null) {
          final dateStr = match.group(1);
          if (dateStr != null) {
            final fileDate = DateTime.tryParse(dateStr);
            if (fileDate != null && fileDate.isBefore(activeAcademicYearStartDate)) {
              await entity.delete();
              deletedCount++;
              continue;
            }
          }
        } else {
          // Legacy file without date prefix: check physical disk modification date
          try {
            final lastModified = await entity.lastModified();
            if (lastModified.isBefore(activeAcademicYearStartDate)) {
              await entity.delete();
              deletedCount++;
            }
          } catch (_) {}
        }
      }

      if (deletedCount > 0) {
        debugPrint(
          'Veyho Attachment Auto-Cleanup: Freed $deletedCount prior-year artifacts (Threshold: $activeAcademicYearStartDate)',
        );
      }
    } catch (e) {
      debugPrint('Veyho Attachment Auto-Cleanup error: $e');
    }
    return deletedCount;
  }
}
