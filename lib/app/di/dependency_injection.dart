import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/core/network/dio_client.dart';
import 'package:auronix_app/app/core/network/interceptors/auth_interceptor.dart';
import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/auth_local_db_datasource.dart';
import 'package:auronix_app/app/database/db_constants.dart';
import 'package:auronix_app/features/auth/auth.dart';
import 'package:auronix_app/features/auth/data/datasources/auth_local_services.dart';
import 'package:auronix_app/features/features.dart';
import 'package:auronix_app/shared/blocs/modals/modal_temp_cubit.dart';
import 'package:auronix_app/shared/templates/appbar/bottom-appbar/cubit/bottom_nav_cubit.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:get_it/get_it.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── 1. Globales ───────────────────────────────────────────────────────────
  // Cubits y servicios transversales que no dependen de nada más.

  sl.registerFactory<GlobalCubit>(() => GlobalCubit());
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  sl.registerFactory<AppLifeCycleCubit>(() => AppLifeCycleCubit());
  sl.registerFactory<PermissionCubit>(() => PermissionCubit());

  sl.registerLazySingleton<RxSharedPreferences>(
    () => RxSharedPreferences.getInstance(),
  );

  sl.registerLazySingleton<DialogCubit>(() => DialogCubit());

  sl.registerLazySingleton<CacheOptions>(
    () => CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.request,
      hitCacheOnErrorCodes: [401, 403],
      priority: CachePriority.normal,
      maxStale: const Duration(days: 1),
      allowPostMethod: true,
    ),
  );

  // ── 2. Base de datos ──────────────────────────────────────────────────────
  // Debe registrarse antes de los datasources locales y del interceptor.

  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);

  sl.registerLazySingleton<AuthLocalDbDataSource>(
    () => AuthLocalDbDataSource(
      sl<AppDatabase>(),
      userType: DbConstants.userTypeClient,
    ),
    instanceName: DbConstants.userTypeClient,
  );

  sl.registerLazySingleton<AuthLocalDbDataSource>(
    () => AuthLocalDbDataSource(
      sl<AppDatabase>(),
      userType: DbConstants.userTypeDriver,
    ),
    instanceName: DbConstants.userTypeDriver,
  );

  // ── 3. Red ────────────────────────────────────────────────────────────────
  // El orden aqui es critico:
  //   a. Crear la instancia de Dio sin el AuthInterceptor.
  //   b. Crear AuthRemoteDatasource con esa instancia y registrarla.
  //   c. Insertar el AuthInterceptor pasando instancias directas, no sl<>().
  //   d. Registrar Dio ya configurado en GetIt.
  //
  // Razon: el AuthInterceptor se resuelve de forma inmediata al insertarse,
  // por lo que sl<Dio>() aun no existiria si se usara dentro del interceptor.

  final dioBasic = await DioClient.getInstance(
    enableSSLPinning: false,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  );

  final authRemote = AuthRemoteDatasource(dio: dioBasic);
  sl.registerLazySingleton<AuthRemoteDatasource>(() => authRemote);

  dioBasic.interceptors.insert(
    2, // posicion: despues de Cache, antes de Retry
    AuthInterceptor(
      db: sl<AppDatabase>(),
      dio: dioBasic,
      authRemote: authRemote,
    ),
  );

  sl.registerLazySingleton<Dio>(() => dioBasic);

  // ── 4. Auth — datasources locales ────────────────────────────────────────

  sl.registerLazySingleton<AuthLocalServices>(
    () => AuthLocalServices(sl<RxSharedPreferences>()),
  );

  // ── 5. Auth — repository ──────────────────────────────────────────────────
  // Una sola instancia registrada bajo la interfaz AuthUnifiedRepository.

  sl.registerLazySingleton<AuthUnifiedRepository>(
    () => AuthRepositoryUnifiedImpl(
      remote: sl<AuthRemoteDatasource>(),
      clientDb: sl<AuthLocalDbDataSource>(
        instanceName: DbConstants.userTypeClient,
      ),
      driverDb: sl<AuthLocalDbDataSource>(
        instanceName: DbConstants.userTypeDriver,
      ),
      local: sl<AuthLocalServices>(),
      prefs: sl<RxSharedPreferences>(),
    ),
  );

  // ── 6. Auth — blocs ───────────────────────────────────────────────────────
  // SessionBloc es singleton porque el router lo escucha como stream global.
  // AuthUnifiedBloc es factory porque cada pantalla necesita una instancia limpia.

  sl.registerLazySingleton<SessionBloc>(
    () => SessionBloc(sl<AuthUnifiedRepository>()),
  );

  sl.registerFactory<AuthUnifiedBloc>(
    () => AuthUnifiedBloc(
      repository: sl<AuthUnifiedRepository>(),
      prefs: sl<RxSharedPreferences>(),
    ),
  );

  sl.registerFactory<AuthFormCubit>(
    () => AuthFormCubit(prefs: sl<RxSharedPreferences>()),
  );

  // ── 7. Globales de navegacion y modales ───────────────────────────────────

  sl.registerLazySingleton<BottomNavCubit>(() => BottomNavCubit());
  sl.registerFactory<ModalTempCubit>(() => ModalTempCubit());
}
