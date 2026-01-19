import 'package:flutter/material.dart';
import '../core/theme.dart';

class EmotionIndicator extends StatelessWidget {
  final double intensity; // 0.0 to 1.0

  const EmotionIndicator({super.key, required this.intensity});

  String get _label {
    if (intensity < 0.3) return "CALM";
    if (intensity < 0.7) return "EXPRESSIVE";
    return "URGENT";
  }

  Color get _color {
    if (intensity < 0.3) return AppTheme.logoSage;
    if (intensity < 0.7) return AppTheme.logoRose;
    return AppTheme.logoBerry;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _color,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: _color.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: 80,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: intensity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_color, _color.withOpacity(0.5)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
