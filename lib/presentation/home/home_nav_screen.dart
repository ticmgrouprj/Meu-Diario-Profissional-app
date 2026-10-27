import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/pacientes_repository.dart';
import 'dashboard_screen.dart';
import 'alertas_screen.dart';
import 'agenda_screen.dart';
import 'perfil_screen.dart';

class HomeNavScreen extends ConsumerStatefulWidget {
  const HomeNavScreen({super.key});

  @override
  ConsumerState<HomeNavScreen> createState() => _HomeNavScreenState();
}

class _HomeNavScreenState extends ConsumerState<HomeNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    AlertasScreen(),
    AgendaScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final alertas = ref.watch(alertasProvider);
    final naoLidos = alertas.where((a) => !a.lido).length;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.slateBorder, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A0F172A),
              offset: Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.slateTextMuted,
          selectedLabelStyle: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTypography.bodySmall,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Pacientes',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: naoLidos > 0,
                label: Text('$naoLidos'),
                backgroundColor: AppColors.riskCritico,
                child: const Icon(Icons.notifications_none_rounded),
              ),
              activeIcon: Badge(
                isLabelVisible: naoLidos > 0,
                label: Text('$naoLidos'),
                backgroundColor: AppColors.riskCritico,
                child: const Icon(Icons.notifications_rounded),
              ),
              label: 'Alertas',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: 'Agenda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
