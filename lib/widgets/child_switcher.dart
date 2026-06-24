import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../constants/colors.dart';

class ChildSwitcher extends StatelessWidget {
  final VoidCallback onClose;

  const ChildSwitcher({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final children = appState.children;
    final currentChild = appState.currentChild;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children.map((child) {
          final isSelected = child.id == currentChild.id;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                appState.setCurrentChild(child);
                onClose();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Switched to ${child.name}'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primaryTeal,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryTeal.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      child.grade,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
