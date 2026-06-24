import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../state/app_state.dart';
import '../constants/colors.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selectedMethod = 'UPI';

  void _processPayment(double amount) {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.payFees(amount, _selectedMethod);
    
    // Pass paid amount and reference to status screen
    Navigator.pushNamed(
      context,
      '/fees/payment-status',
      arguments: {
        'amount': amount,
        'method': _selectedMethod,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final fees = appState.fees;

    final double amount = fees.amount;

    final methods = [
      {'code': 'UPI', 'label': 'UPI (Google Pay, PhonePe, Paytm)', 'icon': LucideIcons.smartphone},
      {'code': 'Debit Card', 'label': 'Credit / Debit Card', 'icon': LucideIcons.creditCard},
      {'code': 'Net Banking', 'label': 'Net Banking', 'icon': LucideIcons.globe},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'selectPaymentMethod'.tr(),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Summary Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'payableAmount'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₹${amount.toInt().toString()}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Selectable List
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'selectPaymentMethod'.tr(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...methods.map((m) {
                    final code = m['code'] as String;
                    final isSelected = _selectedMethod == code;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMethod = code;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryTeal : AppColors.border.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              m['icon'] as IconData,
                              color: isSelected ? AppColors.primaryTeal : AppColors.textMuted,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                m['label'] as String,
                                style: TextStyle(
                                  color: AppColors.textMain,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryTeal : AppColors.textMuted,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: isSelected
                                  ? Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryTeal,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Pay Button
            ElevatedButton(
              onPressed: () => _processPayment(amount),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
              child: Text(
                '${'pay'.tr()} ₹${amount.toInt().toString()}',
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
    );
  }
}
