import 'package:auronix_app/app/app.dart';
import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/core/firebase/release/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

final rootNavKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String environment = const String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: Environment.prod,
  );
  Environment().initConfig(environment);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDependencies();
  await RiveNative.init();
  final sessionBloc = sl<SessionBloc>();
  AppRouter.initialize(sessionBloc, rootNavKey);
  runApp(const AppAuronixMain());
}
