import 'package:flutter/material.dart';

class MemberRegisterForm extends StatelessWidget {
  const MemberRegisterForm({super.key, required this.memberRegisterForm});

  final GlobalKey<FormState> memberRegisterForm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: Text('MemberRegisterForm'),
    );
  }
}
