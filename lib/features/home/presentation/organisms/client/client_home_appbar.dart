import 'package:auronix_app/features/home/presentation/bloc/client/home_client_bloc.dart';
import 'package:auronix_app/features/home/presentation/molecules/client/client_home_appbar_actions.dart';
import 'package:auronix_app/shared/molecules/avatar/app_avatar_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientHomeAppbar extends StatelessWidget {
  const ClientHomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeClientBloc, HomeClientState>(
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
            ClientHomeAppbarActions(
              onNotificationTap: () => debugPrint('Notificaciones'),
            ),
          ],
        );
      },
    );
  }
}
