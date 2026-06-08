import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sd_institute/screens/about_screen.dart';
import 'package:sd_institute/screens/departments_screen.dart';
import 'package:sd_institute/screens/home_screen.dart';
import 'package:sd_institute/screens/staff_screen.dart';
import 'package:sd_institute/widgets/bottom_nav_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DepartmentsScreen(),
    const StaffScreen(),
    const AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body to flow behind the floating nav bar
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 100,
          child:
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: CustomBottomNavBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ).animate().slideY(
                begin: 1.0,
                end: 0.0,
                duration: 800.ms,
                curve: Curves.easeOutExpo,
              ),
        ),
      ),
    );
  }
}
