import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../constants/colors.dart';
import '../widgets/bottom_nav.dart';

class TalkToTeacherScreen extends StatelessWidget {
  const TalkToTeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final teachersList = appState.teachers;

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
      body: teachersList.isEmpty
          ? Center(
              child: Text(
                'noTeachersAssigned'.tr(),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: teachersList.length,
              itemBuilder: (context, idx) {
                final teacher = teachersList[idx];
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeacherChatScreen(teacher: teacher),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Teacher initial avatar
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0F7FA),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              teacher.name.replaceAll('Mrs. ', '').replaceAll('Mr. ', '').replaceAll('Dr. ', '').substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  teacher.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${teacher.subject} • ${teacher.teacherClass}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                if (teacher.lastMessage != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    teacher.lastMessage!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: const BottomNav(active: 'teacher'),
    );
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

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final appState = Provider.of<AppState>(context, listen: false);
    appState.addParentMessage(widget.teacher.id, text);
    
    _msgController.clear();
    
    // Auto scroll down
    Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Start with list scrolled to bottom
    Timer(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch AppState for incoming messages
    final appState = Provider.of<AppState>(context);
    final activeTeachers = appState.teachers;
    final activeTeacher = activeTeachers.firstWhere((t) => t.id == widget.teacher.id, orElse: () => widget.teacher);
    final messages = activeTeacher.messages;

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
              activeTeacher.subject,
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
          // Message Thread
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: messages.length,
              itemBuilder: (context, idx) {
                final message = messages[idx];
                final isMe = message.sender == 'parent';
                
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primaryTeal : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 16),
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
                        Text(
                          message.text,
                          style: TextStyle(
                            color: isMe ? Colors.white : AppColors.textMain,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.timestamp,
                          style: TextStyle(
                            color: isMe ? Colors.white70 : AppColors.textMuted,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input Field Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    maxLines: null,
                    style: const TextStyle(color: AppColors.textMain),
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
                    width: 40,
                    height: 40,
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
          ),
        ],
      ),
    );
  }
}
