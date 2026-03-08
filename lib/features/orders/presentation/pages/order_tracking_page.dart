import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/order_entity.dart';

class OrderTrackingPage extends StatelessWidget {
  final String orderId;
  const OrderTrackingPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('تتبع الطلب')),
      body: _OrderTrackingView(orderId: orderId),
    );
  }
}

class _OrderTrackingView extends StatelessWidget {
  final String orderId;
  const _OrderTrackingView({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (label: 'تم استلام الطلب', icon: Icons.receipt_outlined, status: OrderStatus.pending),
      (label: 'تم تأكيد الطلب', icon: Icons.check_circle_outlined, status: OrderStatus.confirmed),
      (label: 'جاري التحضير', icon: Icons.restaurant_outlined, status: OrderStatus.preparing),
      (label: 'المندوب في الطريق', icon: Icons.delivery_dining_outlined, status: OrderStatus.onWay),
      (label: 'تم التوصيل ✓', icon: Icons.home_outlined, status: OrderStatus.delivered),
    ];

    const currentStep = 2;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('طلب رقم #$orderId', style: AppTextStyles.titleLarge),
          const SizedBox(height: 32),
          ...List.generate(steps.length, (i) {
            final isDone = i < currentStep;
            final isActive = i == currentStep;
            return _TrackingStep(
              label: steps[i].label,
              icon: steps[i].icon,
              isDone: isDone,
              isActive: isActive,
              isLast: i == steps.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDone;
  final bool isActive;
  final bool isLast;

  const _TrackingStep({
    required this.label,
    required this.icon,
    required this.isDone,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : AppColors.textHint;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.success
                    : isActive
                        ? AppColors.primary
                        : AppColors.divider,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check_rounded : icon,
                color: isDone || isActive ? Colors.white : AppColors.textHint,
                size: 22,
              ),
            ),
            if (!isLast)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 2,
                height: 40,
                color: isDone ? AppColors.success : AppColors.divider,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              fontSize: 15,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ],
    );
  }
}
