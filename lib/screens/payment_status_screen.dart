import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/colors.dart';

class PaymentStatusScreen extends StatelessWidget {
  const PaymentStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract parameters passed from method screen
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final double amount = args['amount'] as double;
    final String method = args['method'] as String;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Success Icon Animation container
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    LucideIcons.check,
                    color: Color(0xFF2E7D32),
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'paymentSuccessful'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'yourFeePaymentProcessed'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 32),

              // Summary Info
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'amountPaid'.tr(),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                        Text(
                          '₹${amount.toInt().toString()}',
                          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'paymentMethod'.tr(),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                        Text(
                          method,
                          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'status'.tr(),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                        Text(
                          'success'.tr(),
                          style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Done Button
              ElevatedButton(
                onPressed: () {
                  // Pop back to the Fees dashboard
                  Navigator.popUntil(context, ModalRoute.withName('/fees'));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'done'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
