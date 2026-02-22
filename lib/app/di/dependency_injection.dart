import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/core/network/dio_client.dart';
import 'package:auronix_app/app/core/network/interceptors/auth_interceptor.dart'; // ✅ NUEVO
import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/auth_local_db_datasource.dart';
import 'package:auronix_app/features/features.dart';
import 'package:auronix_app/shared/modals/modal_temp_cubit.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:get_it/get_it.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  //?Globales
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

  //?Database (MOVER ANTES DE DIO)
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);
  sl.registerLazySingleton<AuthLocalDbDataSource>(
    () => AuthLocalDbDataSource(sl<AppDatabase>()),
  );

  // ✅ 1. Crear Dio SIN AuthInterceptor primero
  final dioBasic = await DioClient.getInstance(
    enableSSLPinning: false,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  );

  // ✅ 2. Crear AuthenticationService con Dio básico
  final authenticationService = AuthenticationService(dio: dioBasic);
  sl.registerLazySingleton<AuthenticationService>(() => authenticationService);

  // ✅ 3. Agregar AuthInterceptor DESPUÉS
  dioBasic.interceptors.insert(
    2, // Después de Cache, antes de Retry
    AuthInterceptor(
      db: sl<AppDatabase>(),
      authenticationService: authenticationService,
    ),
  );

  // ✅ 4. Registrar Dio configurado
  sl.registerLazySingleton<Dio>(() => dioBasic);

  //?auth
  //local
  sl.registerLazySingleton<AuthLocalServices>(
    () => AuthLocalServices(sl<RxSharedPreferences>()),
  );

  //Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      local: sl<AuthLocalServices>(),
      localDb: sl<AuthLocalDbDataSource>(),
      authenticationService: sl<AuthenticationService>(),
    ),
  );

  sl.registerLazySingleton<HomeClientRepository>(
    () => HomeClientRepositoryImpl(localDb: sl<AuthLocalDbDataSource>()),
  );

  //Blocs
  sl.registerLazySingleton<SessionBloc>(
    () => SessionBloc(sl<AuthRepository>()),
  );
  sl.registerFactory<ModalTempCubit>(() => ModalTempCubit());
  sl.registerLazySingleton<BottomNavCubit>(() => BottomNavCubit());
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));
  sl.registerFactory<MemberBloc>(() => MemberBloc(sl<RxSharedPreferences>()));
  sl.registerFactory<HomeClientBloc>(
    () => HomeClientBloc(sl<HomeClientRepository>()),
  );
}
