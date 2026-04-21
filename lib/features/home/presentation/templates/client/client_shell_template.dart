import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/features/home/presentation/organisms/client/client_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class ClientShellTemplate extends StatefulWidget {
  const ClientShellTemplate({required this.child, super.key});

  final Widget child;

  @override
  State<ClientShellTemplate> createState() => _ClientShellTemplateState();
}

class _ClientShellTemplateState extends State<ClientShellTemplate>
    with WidgetsBindingObserver {
  bool _isCheckingPermission = false;

  // ── Lifecycle ───────────────────────────────���─────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  // ── Permisos ──────────────────────────────────────────────────────

  Future<void> _checkLocationPermission() async {
    if (_isCheckingPermission) return;
    _isCheckingPermission = true;

    try {
      final status = await Permission.locationWhenInUse.status;

      if (!status.isGranted && mounted) {
        final currentRoute = GoRouterState.of(context).uri.path;
        if (currentRoute != Routes.allowLocation) {
          context.go(Routes.allowLocation);
        }
      }
    } catch (_) {
      // Silenciar — no bloquear la UI por un error de permisos
    } finally {
      _isCheckingPermission = false;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: widget.child,
      bottomNavigationBar: const ClientBottomNav(), // ← organism
    );
  }
}
