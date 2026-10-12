import 'package:auronix_app/app/core/services/location_service.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/presentation/atoms/auth_ci_field.dart';
import 'package:auronix_app/features/auth/presentation/atoms/auth_email_field.dart';
import 'package:auronix_app/features/auth/presentation/atoms/auth_password_field.dart';
import 'package:auronix_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _licenseTypes = <String>['Tipo B', 'Tipo C', 'Tipo D', 'Tipo E'];
const _licenseTypeValues = <String>['B', 'C', 'D', 'E'];

class DriverRegisterForm extends StatefulWidget {
  const DriverRegisterForm({required this.formKey, super.key});

  final GlobalKey<FormState> formKey;

  @override
  State<DriverRegisterForm> createState() => _DriverRegisterFormState();
}

class _DriverRegisterFormState extends State<DriverRegisterForm> {
  DateTime? _birthDate;

  /// País detectado por ubicación para elegir el regex de placa correcto
  /// (docs/requerimientos_backend.md sección 2.1). `null` mientras se
  /// detecta o si falla — se valida contra Ecuador por defecto en ese caso.
  String? _countryCode;

  @override
  void initState() {
    super.initState();
    sl<LocationService>().detectCountryCode().then((result) {
      if (!mounted) return;
      result.fold((_) {}, (code) => setState(() => _countryCode = code));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: BlocBuilder<AuthFormCubit, AuthFormState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthCiField(),
              20.verticalSpace,
              const AuthEmailField(),
              20.verticalSpace,
              const AuthPasswordField(isRegister: true),
              20.verticalSpace,

              // Fecha de nacimiento
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now().subtract(
                      const Duration(days: 365 * 18),
                    ),
                  );
                  if (picked != null) {
                    setState(() => _birthDate = picked);
                    if (mounted) {
                      context.read<AuthFormCubit>().setBirthDate(picked);
                    }
                  }
                },
                child: AbsorbPointer(
                  child: AppTextField(
                    obscureText: false,
                    hasShowHidePassword: false,
                    hasValidationRules: false,
                    hasStrengthIndicator: false,
                    readOnly: true,
                    initialValue: _birthDate == null
                        ? ''
                        : '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}',
                    decoration: const InputDecoration(
                      labelText: 'Fecha de nacimiento',
                      hintText: 'Fecha de nacimiento',
                      border: InputBorder.none,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                ),
              ),

              20.verticalSpace,

              // Número de licencia
              AppTextField(
                obscureText: false,
                hasShowHidePassword: false,
                hasValidationRules: false,
                hasStrengthIndicator: false,
                initialValue: state.licenseNumber,
                onChanged: (v) =>
                    context.read<AuthFormCubit>().changeLicenseNumber(v),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa el número de licencia'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Número de licencia',
                  hintText: 'Número de licencia',
                  border: InputBorder.none,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),

              20.verticalSpace,

              // Tipo de licencia
              AppInputSelect(
                label: 'Tipo de licencia',
                value: state.licenseType.isEmpty
                    ? null
                    : _licenseTypes[_licenseTypeValues.indexOf(state.licenseType)
                          .clamp(0, _licenseTypes.length - 1)],
                options: _licenseTypes,
                onChanged: (v) {
                  if (v != null) {
                    final idx = _licenseTypes.indexOf(v);
                    final typeValue = idx >= 0 ? _licenseTypeValues[idx] : v;
                    context.read<AuthFormCubit>().changeLicenseType(typeValue);
                  }
                },
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Selecciona el tipo de licencia'
                    : null,
              ),

              20.verticalSpace,

              // Número de placa
              TextFormField(
                initialValue: state.plateNumber,
                textCapitalization: TextCapitalization.characters,
                onChanged: (v) =>
                    context.read<AuthFormCubit>().changePlateNumber(v),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ingresa la placa del vehículo';
                  }
                  if (!PlateValidationHelper.isValid(v, _countryCode)) {
                    return 'Formato inválido. Usa '
                        '${PlateValidationHelper.hintFor(_countryCode)}';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: InputDecoration(
                  labelText: 'Placa del vehículo',
                  hintText: PlateValidationHelper.hintFor(_countryCode),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),

              20.verticalSpace,

              // Marca del vehículo
              AppTextField(
                obscureText: false,
                hasShowHidePassword: false,
                hasValidationRules: false,
                hasStrengthIndicator: false,
                initialValue: state.vehicleBrand,
                onChanged: (v) =>
                    context.read<AuthFormCubit>().changeVehicleBrand(v),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa la marca del vehículo'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Marca del vehículo',
                  hintText: 'Toyota, Chevrolet...',
                  border: InputBorder.none,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),

              20.verticalSpace,

              // Modelo del vehículo
              AppTextField(
                obscureText: false,
                hasShowHidePassword: false,
                hasValidationRules: false,
                hasStrengthIndicator: false,
                initialValue: state.vehicleModel,
                onChanged: (v) =>
                    context.read<AuthFormCubit>().changeVehicleModel(v),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa el modelo del vehículo'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Modelo del vehículo',
                  hintText: 'Corolla, Aveo...',
                  border: InputBorder.none,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),

              20.verticalSpace,

              // Año del vehículo
              TextFormField(
                initialValue: state.vehicleYear,
                keyboardType: TextInputType.number,
                onChanged: (v) =>
                    context.read<AuthFormCubit>().changeVehicleYear(v),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ingresa el año del vehículo';
                  }
                  final year = int.tryParse(v.trim());
                  final currentYear = DateTime.now().year;
                  if (year == null || year < 1990 || year > currentYear) {
                    return 'Año inválido (1990–$currentYear)';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  labelText: 'Año del vehículo',
                  hintText: '2020',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),

              12.verticalSpace,

              // Checkbox de Términos y Condiciones
              Row(
                children: [
                  Checkbox(
                    value: state.termsAccepted,
                    onChanged: (_) =>
                        context.read<AuthFormCubit>().toggleTerms(),
                  ),
                  Expanded(
                    child: Wrap(
                      children: [
                        const Text('Acepto los '),
                        InkWell(
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Términos y Condiciones'),
                              content: const Text(
                                'Los términos y condiciones de Auronix se actualizarán antes del lanzamiento.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          ),
                          child: const Text(
                            'Términos y Condiciones',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              12.verticalSpace,

              AppButton(
                label: 'Registrarse',
                expand: true,
                onPressed: (state.termsAccepted && _birthDate != null)
                    ? () {
                        if (widget.formKey.currentState?.validate() ?? false) {
                          context.read<AuthUnifiedBloc>().add(
                            AuthRegisterDriverEvent(
                              ciPassport: state.ciPassport,
                              password: state.password,
                              email: state.email,
                              licenseNumber: state.licenseNumber,
                              licenseType: state.licenseType,
                              plateNumber: state.plateNumber,
                              vehicleBrand: state.vehicleBrand,
                              vehicleModel: state.vehicleModel,
                              vehicleYear: state.vehicleYear,
                              birthDate: _birthDate!,
                            ),
                          );
                        }
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
