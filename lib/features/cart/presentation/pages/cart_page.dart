import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/cart_cubit.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('سلة التسوق'),
            actions: [
              if (!state.isEmpty)
                TextButton(
                  onPressed: () => context.read<CartCubit>().clearCart(),
                  child: const Text(
                    'تفريغ',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
            ],
          ),
          body: state.isEmpty
              ? _EmptyCart()
              : Column(
                  children: [
                    // Items List
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) => _CartItemCard(
                          item: state.items[i],
                          onIncrement: () => context
                              .read<CartCubit>()
                              .addItem(state.items[i]),
                          onDecrement: () => context
                              .read<CartCubit>()
                              .decrementItem(state.items[i].productId),
                          onRemove: () => context
                              .read<CartCubit>()
                              .removeItem(state.items[i].productId),
                        ),
                      ),
                    ),

                    // Order Summary
                    _OrderSummary(state: state),
                  ],
                ),
        );
      },
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'سلتك فارغة',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'أضف منتجات من المطاعم المفضلة لديك',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: AppColors.divider,
                child: const Icon(Icons.fastfood),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${item.price.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),

          // Quantity Control
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    onTap: onDecrement,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${item.quantity}',
                      style: AppTextStyles.titleMedium,
                    ),
                  ),
                  _QuantityButton(
                    icon: Icons.add,
                    onTap: onIncrement,
                    isAdd: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isAdd;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.isAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color:
              isAdd ? AppColors.primary : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isAdd ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartState state;

  const _OrderSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            _SummaryRow('المجموع',
                '${state.subtotal.toStringAsFixed(2)} ر.س'),
            const SizedBox(height: 8),
            _SummaryRow(
              'رسوم التوصيل',
              state.deliveryFee == 0
                  ? 'مجاناً'
                  : '${state.deliveryFee.toStringAsFixed(2)} ر.س',
              valueColor:
                  state.deliveryFee == 0 ? AppColors.success : null,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            _SummaryRow(
              'الإجمالي',
              '${state.total.toStringAsFixed(2)} ر.س',
              isBold: true,
              valueColor: AppColors.primary,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to checkout
                },
                child: Text(
                    'متابعة الدفع (${state.total.toStringAsFixed(2)} ر.س)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow(this.label, this.value,
      {this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold ? AppTextStyles.titleMedium : AppTextStyles.bodyMedium,
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            fontFamily: 'Cairo',
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
