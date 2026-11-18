import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:flutter/material.dart';

class HealthCheckScreen extends StatelessWidget {
  const HealthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final environment = sl<Environment>();
    final apiUrl = environment.config?.apiBaseUrl;

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ambiente: ${environment.activeEnvironment}'),
            Text('API URL: ${apiUrl ?? 'No disponible'}'),
            Text(
              'WebSocket: ${apiUrl == null ? 'No disponible' : _webSocketUrl(apiUrl)}',
            ),
          ],
        ),
      ),
    );
  }

  String _webSocketUrl(String apiUrl) {
    final apiUri = Uri.parse(apiUrl);
    final scheme = apiUri.scheme == 'https' ? 'wss' : 'ws';
    if (!apiUri.hasAuthority) return '$scheme://';

    return apiUri
        .replace(scheme: scheme, path: '', query: '', fragment: '')
        .toString();
  }
}
