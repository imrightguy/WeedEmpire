import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmpireTheme {
  static const Color darkMetal = Color(0xFF1A1A1A);
  static const Color lightMetal = Color(0xFF2A2A2A);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color brightOrange = Color(0xFFFF8C00);
  static const Color errorRed = Color(0xFFFF2400);

  static final TextStyle headerStyle = GoogleFonts.bangers(
    fontSize: 24,
    color: Colors.white,
    letterSpacing: 1.5,
  );

  static final TextStyle bodyStyle = GoogleFonts.oswald(
    fontSize: 16,
    color: Colors.white70,
  );
}

class EmpireCard extends StatelessWidget {
  final Widget child;
  final bool isHighlighted;

  const EmpireCard({super.key, required this.child, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: EmpireTheme.lightMetal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? EmpireTheme.brightOrange : Colors.black54,
          width: isHighlighted ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }
}

class EmpireButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final Widget? icon;

  const EmpireButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    final Color bgColor = isDisabled
        ? Colors.grey[800]!
        : (isPrimary ? EmpireTheme.neonGreen : EmpireTheme.brightOrange);
    final Color textColor = isDisabled
        ? Colors.white30
        : (isPrimary ? Colors.black : Colors.white);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDisabled ? Colors.transparent : Colors.black87,
            width: 2,
          ),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: bgColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.bangers(
                  fontSize: 20,
                  color: textColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
