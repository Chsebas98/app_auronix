import 'package:flutter/material.dart';

class ConductorRegisterForm extends StatelessWidget {
  const ConductorRegisterForm({super.key, required this.conductorRegisterForm});

  final GlobalKey<FormState> conductorRegisterForm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: Text('ConductorRegisterForm'),
    );
  }
}
