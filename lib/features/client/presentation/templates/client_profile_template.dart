import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/client/presentation/bloc/client_profile_bloc.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:auronix_app/shared/molecules/avatar/app_editable_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientProfileTemplate extends StatefulWidget {
  const ClientProfileTemplate({required this.initialCredentials, super.key});
  final AuthenticationCredentials initialCredentials;

  @override
  State<ClientProfileTemplate> createState() => _ClientProfileTemplateState();
}

class _ClientProfileTemplateState extends State<ClientProfileTemplate> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final c = widget.initialCredentials;
    _firstNameCtrl = TextEditingController(text: c.firstName);
    _lastNameCtrl = TextEditingController(text: c.lastName);
    _phoneCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _toggleEdit() => setState(() => _editing = !_editing);

  void _save(BuildContext context, ClientProfileState state) {
    final session = context.read<SessionBloc>().state;
    final userId = session is SessionAuthenticated
        ? (int.tryParse(session.dataUser.username) ?? 0)
        : 0;

    context.read<ClientProfileBloc>().add(
          ClientProfileUpdateEvent(
            userId: userId,
            firstName: _firstNameCtrl.text.trim().isNotEmpty
                ? _firstNameCtrl.text.trim()
                : null,
            lastName: _lastNameCtrl.text.trim().isNotEmpty
                ? _lastNameCtrl.text.trim()
                : null,
            phone: _phoneCtrl.text.trim().isNotEmpty
                ? _phoneCtrl.text.trim()
                : null,
          ),
        );
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientProfileBloc, ClientProfileState>(
      listenWhen: (prev, curr) => curr.status == ClientProfileStatus.ready &&
          prev.status == ClientProfileStatus.loading,
      listener: (_, state) {
        _firstNameCtrl.text = state.profile.firstName;
        _lastNameCtrl.text = state.profile.lastName;
      },
      child: BlocBuilder<ClientProfileBloc, ClientProfileState>(
        builder: (context, state) {
          final profile = state.status == ClientProfileStatus.initial
              ? widget.initialCredentials
              : state.profile;

          return Scaffold(
            backgroundColor: context.appColors.background,
            appBar: AppBar(
              backgroundColor: context.appColors.background,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: context.appColors.icon, size: 20.r),
                onPressed: () => Navigator.pop(context),
              ),
              title: AppText(
                'Mi perfil',
                variant: AppTextVariant.titleMedium,
                color: context.appColors.text,
                fontWeight: FontWeight.w700,
              ),
              centerTitle: true,
              actions: [
                TextButton(
                  onPressed: _editing
                      ? () => _save(context, state)
                      : _toggleEdit,
                  child: AppText(
                    _editing ? 'Guardar' : 'Editar',
                    variant: AppTextVariant.bodyMedium,
                    color: AppColors.third,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            body: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: 24.w, vertical: 24.h),
                    child: Column(
                      children: [
                        // ── Avatar ──────────────────────────────────────
                        Center(
                          child: Stack(
                            children: [
                              AppEditableAvatar(
                                size: 96.r,
                                showEdit: false,
                                image: profile.photoUrl.isNotEmpty
                                    ? NetworkImage(profile.photoUrl)
                                    : null,
                                placeholder: Icon(
                                  Icons.person_rounded,
                                  size: 44.r,
                                  color: context.appColors.textSecondary,
                                ),
                              ),
                              if (_editing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 28.r,
                                    height: 28.r,
                                    decoration: BoxDecoration(
                                      color: AppColors.third,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.camera_alt_rounded,
                                        color: AppColors.secondary, size: 14.r),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        8.verticalSpace,
                        AppText(
                          profile.email,
                          variant: AppTextVariant.bodySmall,
                          color: context.appColors.textSecondary,
                        ),
                        32.verticalSpace,

                        // ── Campos ───────────────────────────────────────
                        _ProfileField(
                          label: 'Nombre',
                          controller: _firstNameCtrl,
                          readOnly: !_editing,
                        ),
                        16.verticalSpace,
                        _ProfileField(
                          label: 'Apellido',
                          controller: _lastNameCtrl,
                          readOnly: !_editing,
                        ),
                        16.verticalSpace,
                        _ProfileField(
                          label: 'Teléfono',
                          controller: _phoneCtrl,
                          readOnly: !_editing,
                          keyboardType: TextInputType.phone,
                          hint: 'Sin número registrado',
                        ),
                        16.verticalSpace,
                        _ProfileField(
                          label: 'Correo electrónico',
                          controller: TextEditingController(text: profile.email),
                          readOnly: true,
                        ),

                        if (state.errorMessage != null) ...[
                          16.verticalSpace,
                          AppText(
                            state.errorMessage!,
                            variant: AppTextVariant.bodySmall,
                            color: AppColors.sevent,
                            align: TextAlign.center,
                          ),
                        ],

                        if (_editing) ...[
                          32.verticalSpace,
                          AppButton(
                            label: 'GUARDAR CAMBIOS',
                            variant: AppButtonVariant.filled,
                            expand: true,
                            isLoading: state.status == ClientProfileStatus.saving,
                            onPressed: () => _save(context, state),
                          ),
                          12.verticalSpace,
                          AppButton(
                            label: 'CANCELAR',
                            variant: AppButtonVariant.outlined,
                            expand: true,
                            onPressed: _toggleEdit,
                          ),
                        ],
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.readOnly,
    this.keyboardType,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final TextInputType? keyboardType;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          variant: AppTextVariant.labelMedium,
          color: context.appColors.textSecondary,
        ),
        6.verticalSpace,
        Container(
          decoration: BoxDecoration(
            color: readOnly
                ? context.appColors.background
                : context.appColors.input,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: readOnly
                  ? context.appColors.border
                  : context.appColors.borderPrimary,
            ),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: TextStyle(
              color: context.appColors.text,
              fontSize: 14.sp,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: context.appColors.textSecondary,
                fontSize: 14.sp,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
