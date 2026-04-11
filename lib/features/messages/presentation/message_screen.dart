import 'package:auronix_app/core/core.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key, required this.role});
  final Roles role;
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: Text('MessageScreen'),
    );
  }
}
