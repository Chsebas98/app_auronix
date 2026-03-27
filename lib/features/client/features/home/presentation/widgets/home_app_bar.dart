import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/features/client/features/home/home-client-bloc/home_client_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeClientBloc, HomeClientState>(
      builder: (context, state) {
        final user = state.dataProfile;

        return SliverAppBar(
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          forceMaterialTransparency: true,
          leading: Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Container(
                width: 40,
                height: 40,
                margin: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.third, width: 2.w),
                  image: user.photoUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(user.photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: AppColors.third.withValues(alpha: 0.3),
                ),
                child: user.photoUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 20.r,
                        color: AppColorsExtension.iconColor(context),
                      )
                    : null,
              ),
            ),
          ),
          actions: [
            // Notificaciones
            IconButton(
              onPressed: () {
                debugPrint('🔔 Notificaciones');
              },
              icon: Stack(
                children: [
                  Icon(Icons.notifications_outlined, size: 26.r),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.sevent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Settings (Tema)
            IconButton(
              onPressed: () {
                context.read<ThemeCubit>().toggleTheme();
              },
              icon: BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return Icon(
                    themeMode == ThemeMode.light
                        ? Icons.nightlight_rounded
                        : Icons.wb_sunny_rounded,
                    size: 26.r,
                  );
                },
              ),
            ),

            8.horizontalSpace,
          ],
        );
      },
    );
  }
}
