import 'package:auronix_app/features/client/home/presentation/widgets/home_client_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeClientPage extends StatelessWidget {
  const HomeClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 📜 Contenido scrolleable
          CustomScrollView(
            slivers: [
              // ✅ AppBar fijo (solo iconos/avatar)
              const HomeAppBar(),

              // ✅ Hero Section (se desplaza)
              const SliverToBoxAdapter(child: HeroSectionWidget()),

              // 2️⃣ Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const QuickActionsWidget(),
                ),
              ),

              // 3️⃣ Cooperativas
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const CooperativasSectionWidget(),
                ),
              ),

              // 4️⃣ Viajes Recientes
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const RecentTripsSectionWidget(),
                ),
              ),

              // 5️⃣ Promociones
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const PromotionsSectionWidget(),
                ),
              ),

              // 6️⃣ Stats / Credibilidad
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const StatsSectionWidget(),
                ),
              ),

              // 7️⃣ Cómo Funciona
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const HowItWorksSectionWidget(),
                ),
              ),

              // 8️⃣ Métodos de Pago
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const PaymentMethodsSectionWidget(),
                ),
              ),

              // Espacio extra para el FAB
              SliverPadding(padding: EdgeInsets.only(bottom: 100.h)),
            ],
          ),

          // 🚕 FAB Flotante (siempre visible)
          const Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: FloatingActionTaxiButton(),
          ),
        ],
      ),
    );
  }
}
