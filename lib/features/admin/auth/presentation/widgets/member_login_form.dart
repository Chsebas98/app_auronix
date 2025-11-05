import 'package:auronix_app/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MemberLoginForm extends StatelessWidget {
  const MemberLoginForm({super.key, required this.memberLoginForm});
  final GlobalKey<FormState> memberLoginForm;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        MemberFields(),
        BlocBuilder<MemberBloc, MemberState>(
          builder: (context, state) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Checkbox(
                  value: state.isRemember,
                  visualDensity: VisualDensity.compact,
                  onChanged: (value) => context.read<MemberBloc>().add(
                    MemberCheckedChangedEvent(),
                  ),
                ),
                const SizedBox(width: 6),
                Text('Recuérdame', style: theme.textTheme.bodyMedium),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        10.verticalSpace,
      ],
    );
  }
}
