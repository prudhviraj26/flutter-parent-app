import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/models.dart';
import '../constants/colors.dart';

class PaymentReceiptScreen extends StatelessWidget {
  const PaymentReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final payment = ModalRoute.of(context)!.settings.arguments as FeeHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'paymentReceipt'.tr(),
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
          children: [
            // Receipt Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Receipt Header Logo/Check
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        LucideIcons.check,
                        color: Color(0xFF2E7D32),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'paymentReceipt'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Receipt rows details
                  _buildReceiptRow('amountPaid'.tr(), '₹${payment.amount.toInt().toString()}', isBold: true),
                  const SizedBox(height: 14),
                  _buildReceiptRow('transactionDate'.tr(), payment.date),
                  const SizedBox(height: 14),
                  _buildReceiptRow('referenceNo'.tr(), payment.reference),
                  const SizedBox(height: 14),
                  _buildReceiptRow('paymentMethod'.tr(), payment.method),
                  const SizedBox(height: 14),
                  _buildReceiptRow('status'.tr(), 'success'.tr(), customColor: const Color(0xFF2E7D32)),

                  const SizedBox(height: 32),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 24),

                  // Download button representation
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('receiptDownloaded'.tr()),
                          backgroundColor: AppColors.primaryTeal,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.download, color: Colors.white, size: 18),
                    label: Text(
                      'downloadReceipt'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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

  Widget _buildReceiptRow(String label, String value, {bool isBold = false, Color? customColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: customColor ?? AppColors.textMain,
              fontSize: 13,
              fontWeight: isBold || customColor != null ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
