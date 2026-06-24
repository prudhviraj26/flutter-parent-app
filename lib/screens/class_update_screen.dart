import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../constants/colors.dart';

class ClassUpdateScreen extends StatefulWidget {
  const ClassUpdateScreen({super.key});

  @override
  State<ClassUpdateScreen> createState() => _ClassUpdateScreenState();
}

class _ClassUpdateScreenState extends State<ClassUpdateScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read route arguments passed (e.g. 'Classwork' or 'Homework') to auto-select tab
    final arg = ModalRoute.of(context)!.settings.arguments as String?;
    if (arg == 'Classwork') {
      _tabController.index = 1;
    } else if (arg == 'Homework') {
      _tabController.index = 2;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final updates = appState.classUpdates;

    final allUpdates = updates;
    final classworkUpdates = updates.where((u) => u.type == 'Classwork').toList();
    final homeworkUpdates = updates.where((u) => u.type == 'Homework').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'classUpdate'.tr(),
          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryTeal,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primaryTeal,
          tabs: [
            Tab(text: 'all'.tr()),
            Tab(text: 'classWork'.tr()),
            Tab(text: 'homeWork'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpdatesList(context, allUpdates),
          _buildUpdatesList(context, classworkUpdates),
          _buildUpdatesList(context, homeworkUpdates),
        ],
      ),
    );
  }

  Widget _buildUpdatesList(BuildContext context, List<ClassUpdate> list) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          'noUpdatesFound'.tr(),
          style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final update = list[idx];
        final isHomework = update.type == 'Homework';
        final hasAttachments = update.attachments != null && update.attachments!.isNotEmpty;

        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClassUpdateDetailScreen(update: update),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge & date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isHomework ? AppColors.primaryTeal.withValues(alpha: 0.1) : AppColors.secondaryOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isHomework ? 'homeWork'.tr() : 'classWork'.tr(),
                          style: TextStyle(
                            color: isHomework ? AppColors.primaryTeal : AppColors.secondaryOrange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        update.date,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Subject & Teacher
                  Text(
                    update.subject,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${'by'.tr()} ${update.teacher}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Body snippet
                  Text(
                    update.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  // Attachment Indicator
                  if (hasAttachments) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(LucideIcons.paperclip, size: 14, color: AppColors.primaryTeal),
                        const SizedBox(width: 4),
                        Text(
                          '${update.attachments!.length} ${'attachments'.tr()}',
                          style: const TextStyle(
                            color: AppColors.primaryTeal,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ClassUpdateDetailScreen extends StatelessWidget {
  final ClassUpdate update;

  const ClassUpdateDetailScreen({super.key, required this.update});

  @override
  Widget build(BuildContext context) {
    final isHomework = update.type == 'Homework';
    final hasAttachments = update.attachments != null && update.attachments!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isHomework ? 'homeWork'.tr() : 'classWork'.tr(),
          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        update.date,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      Text(
                        update.classTarget,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    update.subject,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${'by'.tr()} ${update.teacher}',
                    style: const TextStyle(
                      color: AppColors.primaryTeal,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    update.body,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMain,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Attachments list
            if (hasAttachments)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'attachments'.tr(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...update.attachments!.map((file) {
                      return GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Downloading $file...'),
                              backgroundColor: AppColors.primaryTeal,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.fileText, color: AppColors.primaryTeal, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  file,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMain,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(LucideIcons.download, color: AppColors.textMuted, size: 18),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
