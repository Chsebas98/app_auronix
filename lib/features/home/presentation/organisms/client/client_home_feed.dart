import 'package:auronix_app/core/utils/helpers/responsive_helper.dart';
import 'package:auronix_app/features/home/presentation/molecules/client/current_trip_widget.dart';
import 'package:auronix_app/features/home/presentation/molecules/client/how_it_works_section_widget.dart';
import 'package:auronix_app/features/home/presentation/molecules/client/recent_trips_section_widget.dart';
import 'package:auronix_app/features/home/presentation/organisms/client/client_home_appbar.dart';
import 'package:auronix_app/features/home/presentation/organisms/client/client_home_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

            // ── Viaje activo (visible solo si hay uno en curso) ────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                child: const CurrentTripWidget(),
              ),
            ),

            // ── Viajes recientes ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const RecentTripsSectionWidget(),
              ),
            ),

            // ── Cómo funciona ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const HowItWorksSectionWidget(),
              ),
            ),

            SliverPadding(padding: EdgeInsets.only(bottom: 100.h)),
          ],
        ),
      ),
    );
  }
}
