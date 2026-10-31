import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';

class ClickwrapDialog extends StatefulWidget {
  final Map<String, dynamic>? activeDocs;
  final String deviceUuid;

  const ClickwrapDialog({
    super.key,
    required this.activeDocs,
    required this.deviceUuid,
  });

  /// Displays the modal bottom sheet in a non-dismissible manner
  static Future<bool> show(
    BuildContext context, {
    required Map<String, dynamic>? activeDocs,
    required String deviceUuid,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClickwrapDialog(
        activeDocs: activeDocs,
        deviceUuid: deviceUuid,
      ),
    );
    return result == true;
  }

  @override
  State<ClickwrapDialog> createState() => _ClickwrapDialogState();
}

class _ClickwrapDialogState extends State<ClickwrapDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ScrollController _termsScrollController = ScrollController();
  final ScrollController _privacyScrollController = ScrollController();

  bool _termsRead = false;
  bool _privacyRead = false;
  bool _isSubmitting = false;

  String _termsText = '';
  String _privacyText = '';
  String _termsVersion = 'v1.0.0';
  String _privacyVersion = 'v1.0.0';
  String _termsSha256 = '';
  String _privacySha256 = '';
  String _termsUrl = 'https://veyho.com/terms';
  String _privacyUrl = 'https://veyho.com/privacy';

  bool _isLoadingContent = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    _termsScrollController.addListener(_checkTermsScroll);
    _privacyScrollController.addListener(_checkPrivacyScroll);

    _loadDocumentContent();
  }

  void _checkTermsScroll() {
    if (_termsRead) return;
    if (_termsScrollController.hasClients) {
      final pos = _termsScrollController.position;
      if (pos.maxScrollExtent <= 10 || pos.pixels >= pos.maxScrollExtent - 30) {
        setState(() {
          _termsRead = true;
        });
      }
    }
  }

  void _checkPrivacyScroll() {
    if (_privacyRead) return;
    if (_privacyScrollController.hasClients) {
      final pos = _privacyScrollController.position;
      if (pos.maxScrollExtent <= 10 || pos.pixels >= pos.maxScrollExtent - 30) {
        setState(() {
          _privacyRead = true;
        });
      }
    }
  }

  Future<void> _loadDocumentContent() async {
    setState(() => _isLoadingContent = true);

    try {
      final docs = widget.activeDocs;
      final termsDoc = docs?['terms'] as Map<String, dynamic>?;
      final privacyDoc = docs?['privacy'] as Map<String, dynamic>?;

      if (termsDoc != null &&
          termsDoc['contentMarkdown'] != null &&
          termsDoc['contentMarkdown'].toString().trim().isNotEmpty) {
        _termsText = termsDoc['contentMarkdown'].toString();
        _termsVersion = termsDoc['version']?.toString() ?? 'v1.0.0';
        _termsSha256 = termsDoc['contentSha256']?.toString() ?? '';
        _termsUrl = termsDoc['websiteUrl']?.toString() ?? _termsUrl;
      } else {
        _termsText =
            await rootBundle.loadString('assets/legal/terms_v1.md');
      }

      if (privacyDoc != null &&
          privacyDoc['contentMarkdown'] != null &&
          privacyDoc['contentMarkdown'].toString().trim().isNotEmpty) {
        _privacyText = privacyDoc['contentMarkdown'].toString();
        _privacyVersion = privacyDoc['version']?.toString() ?? 'v1.0.0';
        _privacySha256 = privacyDoc['contentSha256']?.toString() ?? '';
        _privacyUrl = privacyDoc['websiteUrl']?.toString() ?? _privacyUrl;
      } else {
        _privacyText =
            await rootBundle.loadString('assets/legal/privacy_v1.md');
      }
    } catch (e) {
      debugPrint('[ClickwrapDialog] Error loading legal documents: $e');
      _termsText = await rootBundle.loadString('assets/legal/terms_v1.md');
      _privacyText = await rootBundle.loadString('assets/legal/privacy_v1.md');
    } finally {
      if (mounted) {
        setState(() => _isLoadingContent = false);
        // Post frame check in case content fits completely without scroll
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkTermsScroll();
          _checkPrivacyScroll();
        });
      }
    }
  }

  Future<void> _openLiveWebsite(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[ClickwrapDialog] Could not launch URL: $e');
    }
  }

  Future<void> _handleAgreeAndContinue() async {
    if (!_termsRead || !_privacyRead || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final consents = [
        {
          'documentType': 'terms_of_service',
          'documentVersion': _termsVersion,
          'documentSha256': _termsSha256,
        },
        {
          'documentType': 'privacy_policy',
          'documentVersion': _privacyVersion,
          'documentSha256': _privacySha256,
        },
      ];

      final success = await ApiService.recordLegalConsent(
        consents: consents,
        deviceUuid: widget.deviceUuid,
      );

      if (success && mounted) {
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to record agreement. Please check connection and try again.',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _termsScrollController.dispose();
    _privacyScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double sheetHeight = mediaQuery.size.height * 0.90;
    final bool canAgree = _termsRead && _privacyRead;

    return PopScope(
      canPop: false,
      child: Container(
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // Handle pill
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // Top Header: Title & Live Web Link
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.shieldCheck,
                      color: AppColors.primaryTeal,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Legal Agreement',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                        ),
                        Text(
                          'Review both documents to continue',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openLiveWebsite(
                      _tabController.index == 0 ? _termsUrl : _privacyUrl,
                    ),
                    icon: const Icon(
                      LucideIcons.externalLink,
                      size: 14,
                      color: AppColors.primaryTeal,
                    ),
                    label: const Text(
                      'Live Web',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Dual Tab Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('1. Terms'),
                          const SizedBox(width: 6),
                          Icon(
                            _termsRead
                                ? LucideIcons.circleCheck
                                : LucideIcons.circle,
                            size: 14,
                            color: _termsRead
                                ? AppColors.success
                                : (_tabController.index == 0
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('2. Privacy'),
                          const SizedBox(width: 6),
                          Icon(
                            _privacyRead
                                ? LucideIcons.circleCheck
                                : LucideIcons.circle,
                            size: 14,
                            color: _privacyRead
                                ? AppColors.success
                                : (_tabController.index == 1
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Document Viewport
            Expanded(
              child: _isLoadingContent
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryTeal,
                        ),
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Terms
                        _buildDocumentViewer(
                          content: _termsText,
                          controller: _termsScrollController,
                          isRead: _termsRead,
                          version: _termsVersion,
                          label: 'Terms of Service',
                        ),
                        // Tab 2: Privacy Policy
                        _buildDocumentViewer(
                          content: _privacyText,
                          controller: _privacyScrollController,
                          isRead: _privacyRead,
                          version: _privacyVersion,
                          label: 'Privacy Policy',
                        ),
                      ],
                    ),
            ),

            // Bottom Assent Action Bar
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                mediaQuery.padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.card,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -3),
                    blurRadius: 10,
                  ),
                ],
                border: const Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status guideline notice
                  if (!canAgree)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.info,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            !_termsRead && !_privacyRead
                                ? 'Scroll to the end of both documents to enable button'
                                : (!_termsRead
                                    ? 'Scroll to the end of Terms & Conditions'
                                    : 'Scroll to the end of Privacy Policy'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: canAgree && !_isSubmitting
                          ? _handleAgreeAndContinue
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryOrange,
                        disabledBackgroundColor:
                            AppColors.border.withValues(alpha: 0.6),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: AppColors.textMuted,
                        elevation: canAgree ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  canAgree
                                      ? 'Agree & Continue'
                                      : 'Read Both to Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: canAgree
                                        ? Colors.white
                                        : AppColors.textMuted,
                                  ),
                                ),
                                if (canAgree) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    LucideIcons.arrowRight,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentViewer({
    required String content,
    required ScrollController controller,
    required bool isRead,
    required String version,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Subheader: Version and Read state
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Text(
                  '$label ($version)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isRead
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.border.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRead
                            ? LucideIcons.check
                            : LucideIcons.arrowDown,
                        size: 12,
                        color:
                            isRead ? AppColors.success : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isRead ? 'Read & Verified' : 'Scroll to End',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isRead
                              ? AppColors.success
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Markdown Area
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(19)),
              child: Markdown(
                controller: controller,
                data: content,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: AppColors.textMain,
                  ),
                  h1: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryTeal,
                  ),
                  h2: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryTeal,
                  ),
                  h3: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryTealDark,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                  listBullet: const TextStyle(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                  horizontalRuleDecoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1, color: AppColors.border),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
