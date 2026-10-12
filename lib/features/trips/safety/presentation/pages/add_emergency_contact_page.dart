import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/safety/presentation/bloc/emergency_contact_cubit.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Registra el contacto de emergencia mínimo obligatorio (docs/flow.md
/// sección 11.1, docs/database.md `contacto_emergencia`). El CRUD completo
/// (editar/eliminar, varios contactos) es T10.2 — esta pantalla solo cubre
/// agregar el primero para desbloquear disponibilidad/solicitud de viaje.
class AddEmergencyContactPage extends StatefulWidget {
  const AddEmergencyContactPage({super.key});

  @override
  State<AddEmergencyContactPage> createState() =>
      _AddEmergencyContactPageState();
}

class _AddEmergencyContactPageState extends State<AddEmergencyContactPage> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String _telefono = '';
  String _relacion = '';

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: AppColors.white,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppAppbar(
          hasBackButton: true,
          isCenter: true,
          content: AppText(
            'Contacto de emergencia',
            variant: AppTextVariant.titleMedium,
          ),
          goTo: () => Navigator.pop(context),
        ),
        body: BlocBuilder<EmergencyContactCubit, EmergencyContactState>(
          builder: (context, state) {
            final isSaving = state is EmergencyContactLoaded && state.isSaving;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    20.verticalSpace,
                    AppText(
                      'Es obligatorio registrar al menos un contacto de '
                      'emergencia antes de solicitar o atender un viaje.',
                      variant: AppTextVariant.bodyMedium,
                    ),
                    24.verticalSpace,
                    AppTextField(
                      obscureText: false,
                      hasShowHidePassword: false,
                      hasValidationRules: false,
                      hasStrengthIndicator: false,
                      justText: true,
                      hasSpace: true,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del contacto',
                        hintText: 'Nombre completo',
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      validator: (v) {
                        final r = FormValidators.validateName(v ?? '');
                        return r.isValid ? null : r.message;
                      },
                      onChanged: (v) => _nombre = v,
                    ),
                    20.verticalSpace,
                    AppTextField(
                      obscureText: false,
                      hasShowHidePassword: false,
                      hasValidationRules: false,
                      hasStrengthIndicator: false,
                      justNumbers: true,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: 'Número de celular',
                        hintText: 'Número de celular',
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      validator: (v) => FormsHelpers.getMessageFormValidation(
                        FormValidators.validatePhone(v ?? ''),
                      ),
                      onChanged: (v) => _telefono = v,
                    ),
                    20.verticalSpace,
                    AppTextField(
                      obscureText: false,
                      hasShowHidePassword: false,
                      hasValidationRules: false,
                      hasStrengthIndicator: false,
                      justText: true,
                      hasSpace: true,
                      decoration: const InputDecoration(
                        labelText: 'Relación',
                        hintText: 'Ej: Madre, Hermano, Pareja',
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Indica la relación con este contacto'
                          : null,
                      onChanged: (v) => _relacion = v,
                    ),
                    32.verticalSpace,
                    AppButton(
                      label: 'Guardar contacto',
                      expand: true,
                      isLoading: isSaving,
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final ok = await context
                              .read<EmergencyContactCubit>()
                              .addContact(
                                nombre: _nombre,
                                telefono: _telefono,
                                relacion: _relacion,
                              );
                          if (!context.mounted) return;
                          if (ok) {
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No se pudo guardar el contacto'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
