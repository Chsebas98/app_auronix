import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/core/network/dio_client.dart';
import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/auth_local_db_datasource.dart';
import 'package:auronix_app/features/client/auth/infraestructure/data/remote/strapi_services.dart';
import 'package:auronix_app/features/client/home/domain/repository/home_client_repository.dart';
import 'package:auronix_app/features/client/home/domain/repository/home_client_repository_impl.dart';
import 'package:auronix_app/features/client/home/home-client-bloc/home_client_bloc.dart';
import 'package:auronix_app/features/features.dart';
import 'package:auronix_app/shared/modals/modal_temp_cubit.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:get_it/get_it.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  //?GLobales
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

  final dio = await DioClient.getInstance(
    enableSSLPinning: false, // Cambia a true en producción
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  );
  sl.registerLazySingleton<Dio>(() => dio);

  //?Database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);
  sl.registerLazySingleton<AuthLocalDbDataSource>(
    () => AuthLocalDbDataSource(sl<AppDatabase>()),
  );

  //?auth
  //local
  sl.registerLazySingleton<AuthLocalServices>(
    () => AuthLocalServices(sl<RxSharedPreferences>()),
  );
  //remote
  sl.registerLazySingleton<AuthRemoteServices>(() => AuthRemoteServices());
  sl.registerLazySingleton<StrapiServices>(
    () => StrapiServices(dio: sl<Dio>()),
  );

  //Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      local: sl<AuthLocalServices>(),
      remote: sl<AuthRemoteServices>(),
      localDb: sl<AuthLocalDbDataSource>(),
      strapiServices: sl<StrapiServices>(),
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
