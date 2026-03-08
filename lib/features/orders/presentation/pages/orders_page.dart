import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/orders_cubit.dart';
import '../../../../core/di/injection_container.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';

    return BlocProvider(
      create: (_) => sl<OrdersCubit>()..loadOrders(userId),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('طلباتي')),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OrdersLoaded) {
              if (state.orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      const Text('لا توجد طلبات', style: AppTextStyles.titleLarge),
                      const SizedBox(height: 8),
                      const Text('لم تقم بأي طلب حتى الآن', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.go(AppRoutes.home),
                        child: const Text('اطلب الآن'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _OrderCard(
                  order: state.orders[i],
                  onTrack: () => context.push('/order-tracking/${state.orders[i].id}'),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onTrack;

  const _OrderCard({required this.order, required this.onTrack});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.delivered: return AppColors.success;
      case OrderStatus.cancelled: return AppColors.error;
      case OrderStatus.onWay: return AppColors.info;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('#${order.id.substring(0, 8).toUpperCase()}', style: AppTextStyles.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(order.status.label,
                    style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(order.restaurantName, style: AppTextStyles.bodyMedium),
          Text('${order.items.length} منتجات • ${order.total.toStringAsFixed(2)} ر.س', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 12),
          if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onTrack,
                child: const Text('تتبع الطلب'),
              ),
            ),
        ],
      ),
    );
  }
}
