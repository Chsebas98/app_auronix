import 'package:auronix_app/core/utils/helpers/responsive_helper.dart';
import 'package:auronix_app/features/home/presentation/bloc/driver-bloc/home_driver_bloc.dart';
import 'package:auronix_app/features/home/presentation/organisms/driver/driver_daily_earnings_card.dart';
import 'package:auronix_app/features/home/presentation/organisms/driver/driver_home_appbar.dart';
import 'package:auronix_app/features/home/presentation/organisms/driver/driver_home_hero.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Contiene todo el scroll del home: appbar + hero + secciones.
/// No sabe nada de Scaffold ni drawer.
class DriverHomeFeed extends StatelessWidget {
  const DriverHomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveHelper.maxContentWidth(context),
        ),
        child: BlocBuilder<HomeDriverBloc, HomeDriverState>(
          builder: (context, state) {
            return AutoSkeleton(
              enabled: state.status == HomeDriverStatus.loading,
              child: CustomScrollView(
                slivers: [
                  const DriverHomeAppbar(),

                  SliverToBoxAdapter(child: DriverHomeHero()),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: AppSpacing.sm,
                      ),
                      child: DriverDailyEarningsCard(
                        totalEarnings: state.dailyEarnings,
                        completedTrips: state.completedTrips,
                        earningsHistory: state.earningsHistory,
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
                        child: Center(
                          child: Text('Recent Trips Section Widget'),
                        ),
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
                        child: Center(
                          child: Text('How It Works Section Widget'),
                        ),
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
                        child: Center(
                          child: Text('Payment Methods Section Widget'),
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(padding: EdgeInsets.only(bottom: 100.h)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
