import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';

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

class _ModalCompleteProfilePageStructure extends StatelessWidget {
  const _ModalCompleteProfilePageStructure();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarDefault(
        hasBackButton: true,
        isModalAppBar: true,
        goTo: () => Navigator.pop(context),
      ),
      body: Text('ModalCompleteProfilePage'),
    );
  }
}
