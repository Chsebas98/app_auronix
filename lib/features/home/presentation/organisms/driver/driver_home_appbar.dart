import 'package:auronix_app/features/home/presentation/bloc/driver-bloc/home_driver_bloc.dart';
import 'package:auronix_app/features/home/presentation/molecules/driver/driver_home_appbar_actions.dart';
import 'package:auronix_app/shared/molecules/avatar/app_avatar_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverHomeAppbar extends StatelessWidget {
  const DriverHomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDriverBloc, HomeDriverState>(
      builder: (context, state) {
        return SliverAppBar(
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          forceMaterialTransparency: true,
          leading: Padding(
            padding: EdgeInsets.only(left: 12),
            child: HomeAvatarButton(
              photoUrl: state.dataProfile.photoUrl,
              onTap: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            DriverHomeAppbarActions(
              onNotificationTap: () => debugPrint('Notificaciones'),
            ),
          ],
        );
      },
    );
  }
}
