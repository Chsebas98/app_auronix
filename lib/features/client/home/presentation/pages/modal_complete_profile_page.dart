import 'package:auronix_app/app/app.dart';
import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/features/client/home/home-client-bloc/home_client_bloc.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModalCompleteProfilePage extends StatelessWidget {
  const ModalCompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ModalCompleteProfilePageController();
  }
}

class _ModalCompleteProfilePageController extends StatelessWidget {
  const _ModalCompleteProfilePageController();

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: AppColors.white,
      child: _ModalCompleteProfilePageStructure(),
    );
  }
}

class _ModalCompleteProfilePageStructure extends StatefulWidget {
  const _ModalCompleteProfilePageStructure();

  @override
  State<_ModalCompleteProfilePageStructure> createState() =>
      _ModalCompleteProfilePageStructureState();
}

class _ModalCompleteProfilePageStructureState
    extends State<_ModalCompleteProfilePageStructure> {
  final _completeProfileFormKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _gender;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _showErrorToast(BuildContext context, String message) {
    final theme = Theme.of(context);
    rootMessengerKey.currentState?.showSnackBar(
      CustomSnackbar(
        title: 'Error al guardar datos',
        description: message,
        theme: theme,
      ),
    );
  }

  void _onSave() {
    if (_completeProfileFormKey.currentState?.validate() ?? false) {
      final name = _nameCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();
      final gender = _gender;
      debugPrint(
        'Saving profile data: name=$name, phone=$phone, gender=$gender',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<HomeClientBloc, HomeClientState>(
      listener: (context, state) {
        final completeStateForm = state.completeProfileStatus;
        if (completeStateForm is FormSubmitSuccesfull) {
          context.read<DialogCubit>().hideAll();
        }
        if (completeStateForm is FormSubmitFailed) {
          _showErrorToast(context, completeStateForm.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.primaryColor,
          appBar: AppbarDefault(
            hasBackButton: true,
            isModalAppBar: true,
            content: Text(
              'Completa tu perfil',
              style: theme.textTheme.titleLarge,
            ),
            goTo: () => Navigator.pop(context),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed:
                          state.completeProfileStatus is FormSubmitProgress
                          ? null
                          : _onSave,
                      child: state.completeProfileStatus is FormSubmitProgress
                          ? Center(child: CircularProgressIndicator.adaptive())
                          : Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Form(
            key: _completeProfileFormKey,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              children: [
                30.verticalSpace,
                Center(
                  child: EditableAvatar(
                    size: 120.w,
                    onEdit: () async {
                      // Aquí abres tu flujo: picker/cámara/archivo
                      // y solo guardas en _avatarImage (temporal)
                    },
                  ),
                ),
                30.verticalSpace,
                CustomTextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Ingresa un nombre y un apellido',
                    labelText: 'Nombre',
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: false,
                  autocorrect: false,
                  hasShowHidePassword: false,
                  hasValidationRules: false,
                  hasStrengthIndicator: false,
                  hasSpace: true,
                  maxLength: 80,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'El nombre es requerido';
                    if (v.split(RegExp(r'\s+')).length < 2) {
                      return 'Ingresa nombre y apellido';
                    }
                    return null;
                  },
                  onChanged: (_) {},
                ),
                20.verticalSpace,
                CustomInputSelect(
                  label: 'Género',
                  options: ['Masculino', 'Femenino', 'Otro'],
                  onChanged: (v) => setState(() => _gender = v),
                ),
                20.verticalSpace,
                CustomTextFormField(
                  controller: _phoneCtrl,
                  decoration: InputDecoration(
                    hintText: '0999999999',
                    labelText: 'Teléfono',
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: false,
                  autocorrect: false,
                  hasShowHidePassword: false,
                  hasValidationRules: false,
                  hasStrengthIndicator: false,
                  hasSpace: false,
                  justNumbers: true,
                  maxLength: 10,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'El teléfono es requerido';
                    if (!RegExp(r'^\d{10}$').hasMatch(v)) {
                      return 'Teléfono inválido';
                    }
                    return null;
                  },
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
