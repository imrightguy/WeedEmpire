import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget gameArea;
  final Widget menuArea;

  const ResponsiveLayout({
    super.key,
    required this.gameArea,
    required this.menuArea,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Simple breakpoint: if width > height, assume desktop/landscape layout
        if (constraints.maxWidth > constraints.maxHeight) {
          // Desktop Layout
          return Scaffold(
            body: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: gameArea,
                ),
                Container(
                  width: 350, // Fixed width side menu
                  color: Colors.grey[900],
                  child: menuArea,
                ),
              ],
            ),
          );
        } else {
          // Mobile Layout (Portrait)
          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: gameArea,
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.grey[900],
                    child: menuArea,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
