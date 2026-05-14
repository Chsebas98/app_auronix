import 'package:auronix_app/core/utils/helpers/responsive_helper.dart';
import 'package:auronix_app/features/home/presentation/organisms/client/client_home_appbar.dart';
import 'package:auronix_app/features/home/presentation/organisms/client/client_home_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Contiene todo el scroll del home: appbar + hero + secciones.
/// No sabe nada de Scaffold ni drawer.
class ClientHomeFeed extends StatelessWidget {
  const ClientHomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveHelper.maxContentWidth(context),
        ),
        child: CustomScrollView(
          slivers: [
            const ClientHomeAppbar(),

            const SliverToBoxAdapter(child: HomeClientHero()),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                // child: const CurrentTripWidget(),
                child: Container(
                  height: 150,
                  color: Colors.blueGrey,
                  child: Center(child: Text('Current Trip Widget')),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                // child: const RecentTripsSectionWidget(),
                child: Container(
                  height: 150,
                  color: Colors.orangeAccent,
                  child: Center(child: Text('Recent Trips Section Widget')),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                // child: const HowItWorksSectionWidget(),
                child: Container(
                  height: 150,
                  color: Colors.greenAccent,
                  child: Center(child: Text('How It Works Section Widget')),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                // child: PaymentMethodsSectionWidget(),
                child: Container(
                  height: 150,
                  color: Colors.purpleAccent,
                  child: Center(child: Text('Payment Methods Section Widget')),
                ),
              ),
            ),

            SliverPadding(padding: EdgeInsets.only(bottom: 100.h)),
          ],
        ),
      ),
    );
  }
}
