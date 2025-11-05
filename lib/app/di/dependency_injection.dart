import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/features/features.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:get_it/get_it.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  //?GLobales
  sl.registerFactory<GlobalCubit>(() => GlobalCubit());
  sl.registerFactory<ThemeCubit>(() => ThemeCubit());
  sl.registerFactory<SessionCubit>(() => SessionCubit());
  sl.registerFactory<AppLifeCycleCubit>(() => AppLifeCycleCubit());
  sl.registerLazySingleton<RxSharedPreferences>(
    () => RxSharedPreferences.getInstance(),
  );

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

  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Environment().config!.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(DioCacheInterceptor(options: sl<CacheOptions>()));
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ),
    );
    return dio;
  });

  //Blocs
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<RxSharedPreferences>()));
  sl.registerFactory<MemberBloc>(() => MemberBloc(sl<RxSharedPreferences>()));
}
