import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../constants/colors.dart';
import '../widgets/bottom_nav.dart';

class TalkToTeacherScreen extends StatefulWidget {
  const TalkToTeacherScreen({super.key});

  @override
  State<TalkToTeacherScreen> createState() => _TalkToTeacherScreenState();
}

class _TalkToTeacherScreenState extends State<TalkToTeacherScreen> {
  String _activeFilter = 'all'; // 'all' or 'unread'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.fetchChatForActiveChild();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allTeachers = List<Teacher>.from(appState.teachers);

    // Sort descending by lastMessageAt or creation date
    allTeachers.sort((a, b) {
      final aDate = a.lastMessageAt ?? DateTime(2000);
      final bDate = b.lastMessageAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    final totalUnread = appState.unreadTeacherMessagesCount;

    final filteredTeachers = _activeFilter == 'unread'
        ? allTeachers.where((t) => t.unreadCount > 0 || t.unread).toList()
        : allTeachers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'talkToTeacher'.tr(),
          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips: All & Unread
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'all'.tr(),
                  isActive: _activeFilter == 'all',
                  onTap: () {
                    setState(() {
                      _activeFilter = 'all';
                    });
                  },
                ),
                const SizedBox(width: 10),
                _buildFilterChip(
                  label: 'unread'.tr(),
                  badgeCount: totalUnread,
                  isActive: _activeFilter == 'unread',
                  onTap: () {
                    setState(() {
                      _activeFilter = 'unread';
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Teacher List
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryTeal,
              onRefresh: () async {
                await appState.fetchChatForActiveChild();
              },
              child: filteredTeachers.isEmpty
                  ? Center(
                      child: Text(
                        _activeFilter == 'unread'
                            ? 'No unread conversations'
                            : 'noTeachersAssigned'.tr(),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: filteredTeachers.length,
                      itemBuilder: (context, idx) {
                        final teacher = filteredTeachers[idx];
                        final hasUnread = teacher.unreadCount > 0 || teacher.unread;

                        return Card(
                          color: hasUnread ? const Color(0xFFF0FDFA) : Colors.white,
                          elevation: hasUnread ? 2 : 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: hasUnread ? AppColors.primaryTeal : AppColors.border,
                              width: hasUnread ? 1.5 : 1,
                            ),
                          ),
                          margin: const EdgeInsets.only(bottom: 14),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeacherChatScreen(teacher: teacher),
                                ),
                              ).then((_) {
                                // Auto refresh on pop
                                if (mounted) {
                                  appState.fetchChatForActiveChild();
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Teacher initial avatar with indicator
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: hasUnread
                                              ? AppColors.primaryTeal.withValues(alpha: 0.15)
                                              : const Color(0xFFE0F7FA),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          teacher.name
                                              .replaceAll('Mrs. ', '')
                                              .replaceAll('Mr. ', '')
                                              .replaceAll('Dr. ', '')
                                              .trim()
                                              .isNotEmpty
                                              ? teacher.name
                                                  .replaceAll('Mrs. ', '')
                                                  .replaceAll('Mr. ', '')
                                                  .replaceAll('Dr. ', '')
                                                  .trim()
                                                  .substring(0, 1)
                                                  .toUpperCase()
                                              : 'T',
                                          style: const TextStyle(
                                            color: AppColors.primaryTeal,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      if (hasUnread)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: AppColors.secondaryOrange,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                teacher.name,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                                                  color: AppColors.textMain,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (teacher.lastMessageAt != null)
                                              Text(
                                                _formatTimeLabel(teacher.lastMessageAt!),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                                                  color: hasUnread ? AppColors.primaryTeal : AppColors.textMuted,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${teacher.displaySubjects} • ${teacher.teacherClass}',
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (teacher.lastMessage != null) ...[
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  teacher.lastMessage!,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: hasUnread ? AppColors.textMain : AppColors.textMuted,
                                                    fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              if (teacher.unreadCount > 0) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryTeal,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    '${teacher.unreadCount} new',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 20),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(active: 'teacher'),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryTeal : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primaryTeal : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textMain,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : AppColors.secondaryOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: TextStyle(
                    color: isActive ? AppColors.primaryTeal : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimeLabel(DateTime dt) {
    final now = DateTime.now();
    if (now.year == dt.year && now.month == dt.month && now.day == dt.day) {
      final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return "$hour12:${dt.minute.toString().padLeft(2, '0')} $period";
    }
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}

class TeacherChatScreen extends StatefulWidget {
  final Teacher teacher;

  const TeacherChatScreen({super.key, required this.teacher});

  @override
  State<TeacherChatScreen> createState() => _TeacherChatScreenState();
}

class _TeacherChatScreenState extends State<TeacherChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _smartPollTimer;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    // Mark conversation read on enter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.markTeacherChatRead(widget.teacher.id);
      _scrollToBottom();
    });

    // Start adaptive smart polling (every 3 seconds)
    _smartPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        final appState = Provider.of<AppState>(context, listen: false);
        appState.pollChatDelta(widget.teacher.id);
      }
    });

    _msgController.addListener(() {
      if (mounted) {
        setState(() {
          _charCount = _msgController.text.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _smartPollTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    if (text.length > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message cannot exceed 1000 characters')),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    appState.addParentMessage(widget.teacher.id, text);
    
    _msgController.clear();
    _scrollToBottom();
  }

  void _handleDeleteMessage(Message message) {
    if (message.isDeleted || message.sender != 'parent') return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Delete this message for everyone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final appState = Provider.of<AppState>(context, listen: false);
              appState.deleteParentMessage(widget.teacher.id, message.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final activeTeachers = appState.teachers;
    final activeTeacher = activeTeachers.firstWhere(
      (t) => t.id == widget.teacher.id,
      orElse: () => widget.teacher,
    );
    final messages = activeTeacher.messages;
    final workingHours = appState.schoolWorkingHours.formattedSchedule;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activeTeacher.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
            ),
            Text(
              '${activeTeacher.displaySubjects} • ${activeTeacher.teacherClass}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Column(
        children: [
          // Dynamic School Working Hours Disclaimer Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(LucideIcons.clock, size: 16, color: Color(0xFFD97706)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'School Hours: $workingHours',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Teachers review messages during school hours. Response might be delayed — please do not expect an instant response.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF78350F),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Message Thread List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, idx) {
                final message = messages[idx];
                final isMe = message.sender == 'parent';
                final isDeleted = message.isDeleted;

                return GestureDetector(
                  onLongPress: isMe && !isDeleted ? () => _handleDeleteMessage(message) : null,
                  child: Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.78,
                      ),
                      decoration: BoxDecoration(
                        color: isDeleted
                            ? Colors.grey.shade200
                            : (isMe ? AppColors.primaryTeal : Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 16),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (isDeleted)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.ban, size: 13, color: Colors.grey.shade600),
                                const SizedBox(width: 6),
                                Text(
                                  'This message was deleted',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              message.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : AppColors.textMain,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatMessageTimestamp(message.timestamp),
                                style: TextStyle(
                                  color: isMe ? Colors.white70 : AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                              if (isMe && !isDeleted) ...[
                                const SizedBox(width: 4),
                                _buildWhatsAppStatusIcon(message.status),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input Field Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 20),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          maxLength: 1000,
                          maxLines: 4,
                          minLines: 1,
                          style: const TextStyle(color: AppColors.textMain, fontSize: 14),
                          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                          decoration: InputDecoration(
                            hintText: 'typeMessage'.tr(),
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryTeal,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(LucideIcons.send, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  if (_charCount > 800)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 54),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$_charCount/1000',
                          style: TextStyle(
                            fontSize: 10,
                            color: _charCount >= 1000 ? Colors.red : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppStatusIcon(String status) {
    if (status == 'sending') {
      return const Icon(LucideIcons.clock, size: 11, color: Colors.white70);
    } else if (status == 'sent') {
      return const Icon(LucideIcons.check, size: 13, color: Colors.white70);
    } else if (status == 'read') {
      // Double blue tick
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.check, size: 13, color: Color(0xFF38BDF8)),
          SizedBox(width: -6),
          Icon(LucideIcons.check, size: 13, color: Color(0xFF38BDF8)),
        ],
      );
    } else {
      // Double gray tick (delivered)
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.check, size: 13, color: Colors.white70),
          SizedBox(width: -6),
          Icon(LucideIcons.check, size: 13, color: Colors.white70),
        ],
      );
    }
  }

  String _formatMessageTimestamp(String ts) {
    if (ts.isEmpty) return '';
    try {
      final dt = DateTime.parse(ts);
      final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return "$hour12:${dt.minute.toString().padLeft(2, '0')} $period";
    } catch (_) {
      return ts;
    }
  }
}
