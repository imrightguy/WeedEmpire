import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/game.dart';
import '../game/weed_empire_game.dart';
import 'widgets/global_hud_widget.dart';
import 'widgets/empire_widgets.dart';

import 'business/lab_modal.dart';
import 'business/streets_modal.dart';
import 'business/office_modal.dart';
import 'business/safe_modal.dart';
import '../game/components/business_component.dart';

class MainScreen extends StatefulWidget {
  final WeedEmpireGame gameInstance;

  const MainScreen({super.key, required this.gameInstance});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    _registerCallbacks();
  }

  void _registerCallbacks() {
    widget.gameInstance.setBusinessCallbacks({
      BusinessType.lab: () => _openModal(context, 'LAB', const LabModal()),
      BusinessType.streets: () => _openModal(context, 'STREETS', const StreetsModal()),
      BusinessType.office: () => _openModal(context, 'OFFICE', const OfficeModal()),
      BusinessType.safe: () => _openModal(context, 'SAFE', const SafeModal()),
    });
  }

  void _openModal(BuildContext context, String title, Widget modalContent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: EmpireTheme.darkMetal,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: Column(
                children: [
                  // Modal Header
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: EmpireTheme.lightMetal,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: const Border(bottom: BorderSide(color: Colors.black54, width: 2)),
                    ),
                    child: Center(
                      child: Text(
                        title,
                        style: GoogleFonts.bangers(fontSize: 28, color: EmpireTheme.neonGreen, letterSpacing: 2),
                      ),
                    ),
                  ),
                  // Modal Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: modalContent,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background: Full Screen Game
          Positioned.fill(
            child: GameWidget(game: widget.gameInstance),
          ),
          
          // Foreground Top: Global HUD
          const SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: GlobalHudWidget(),
            ),
          ),
          
          // Foreground Bottom: Navigation Bar
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: EmpireTheme.lightMetal.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black54, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.5), offset: const Offset(0, 4), blurRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavButton(context, Icons.science, 'LAB', const LabModal()),
                    _buildNavButton(context, Icons.storefront, 'STREETS', const StreetsModal()),
                    _buildNavButton(context, Icons.business_center, 'OFFICE', const OfficeModal()),
                    _buildNavButton(context, Icons.vpn_key, 'SAFE', const SafeModal()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon, String label, Widget modalContent) {
    return InkWell(
      onTap: () => _openModal(context, label, modalContent),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: EmpireTheme.neonGreen, size: 28),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.oswald(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
