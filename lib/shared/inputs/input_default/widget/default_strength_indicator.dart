import 'package:auronix_app/app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultStrengthIndicator extends StatelessWidget {
  const DefaultStrengthIndicator(this._strength, {super.key});

  final double _strength;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        12.verticalSpace,
        Text(
          _getPasswordStrengthLabel(),
          style: TextStyle(
            fontFamily: 'SFProDisplay-SemiBold',
            fontSize: 10.sp,
            color: _getPasswordStrengthColor(),
          ),
        ),
        3.verticalSpace,
        // LinearProgressIndicator(
        //   value: _strength,

        //   valueColor: AlwaysStoppedAnimation<Color>(
        //     _getPasswordStrengthColor(),
        //   ),
        //   backgroundColor: Colors.white,
        // ),
        buildSegmentedStrengthIndicator(_strength),
        6.verticalSpace,
      ],
    );
  }

  /// Llama a esto en lugar de LinearProgressIndicator
  Widget buildSegmentedStrengthIndicator(double strength) {
    const int segments = 6;
    // Número de segmentos “llenos”
    final int filled = (strength * segments).ceil().clamp(0, segments);

    return Row(
      children: List.generate(segments, (i) {
        final bool isOn = i < filled;
        return Expanded(
          child: Container(
            height: 4.r, // o la altura que quieras
            margin: EdgeInsets.symmetric(horizontal: 2.r),
            decoration: BoxDecoration(
              color: isOn ? _getPasswordStrengthColor() : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        );
      }),
    );
  }

  String _getPasswordStrengthLabel() {
    if (_strength < .25) {
      return 'Débil';
    } else if (_strength < .5) {
      return 'Regular';
    } else if (_strength < .95) {
      return 'Buena';
    }
    return 'Fuerte';
  }

  Color _getPasswordStrengthColor() {
    if (_strength < .25) {
      return AppColors.sevent;
    } else if (_strength < .35) {
      return AppColors.tenth;
    } else if (_strength < .5) {
      return AppColors.nineth;
    } else if (_strength < .75) {
      return AppColors.eleventh;
    }
    return AppColors.fifth;
  }
}
