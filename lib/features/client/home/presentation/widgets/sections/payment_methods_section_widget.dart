import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/features/client/home/presentation/widgets/home_client_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentMethodsSectionWidget extends StatelessWidget {
  const PaymentMethodsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);

    return Column(
      children: [
        const SectionHeader(
          title: 'Formas de Pago',
          subtitle: 'Elige tu método preferido',
          icon: Icons.payment,
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            alignment: WrapAlignment.center,
            children: [
              _PaymentMethodChip(
                icon: Icons.credit_card,
                label: 'Tarjeta',
                color: AppColors.fifth,
              ),
              _PaymentMethodChip(
                icon: Icons.wallet,
                label: 'Wallet',
                color: AppColors.third,
              ),
              _PaymentMethodChip(
                icon: Icons.money,
                label: 'Efectivo',
                color: AppColors.eleventh,
              ),
              _PaymentMethodChip(
                icon: Icons.account_balance,
                label: 'Transferencia',
                color: AppColors.sixth,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: OutlinedButton.icon(
            onPressed: () {
              debugPrint('Agregar método de pago');
            },
            icon: Icon(Icons.add, size: 20.r),
            label: const Text('Agregar Método de Pago'),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PaymentMethodChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColorsExtension.cardColor(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColorsExtension.borderColor(context),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.r, color: color),
          ),
          SizedBox(width: 8.w),
          Text(label, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}
