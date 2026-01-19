import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/core/permission/domain/models/interfaces/app_permission_type.dart';
import 'package:auronix_app/core/utils/permission_spec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PermissionRationalePage extends StatelessWidget {
  const PermissionRationalePage({super.key, required this.type});
  final AppPermissionType type;

  @override
  Widget build(BuildContext context) {
    final spec = specOf(type);
    final cubit = context.read<PermissionCubit>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Cierra solo el top overlay
            context.read<DialogCubit>().hideTop();
            cubit.clearRequest();
          },
        ),
        title: const Text('Permisos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(spec.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(spec.description),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await cubit.request(type);
                  // Cierra fullscreen cuando termine
                  // ignore: use_build_context_synchronously
                  context.read<DialogCubit>().hideTop();
                },
                child: const Text('Permitir'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  cubit.openSettings();
                },
                child: const Text('Abrir ajustes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
