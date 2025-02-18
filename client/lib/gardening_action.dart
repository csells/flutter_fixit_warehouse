import 'package:flutter/material.dart';

enum GardeningAction {
  expandGarden(
    display: 'Expand my\ngarden',
    icon: Icons.local_florist,
    prompt:
        "I'd like to expand my garden. "
        "Attached is a picture of a plant I'd like to add.",
  ),
  keepGardenHealthy(
    display: 'Keep my\ngarden healthy',
    icon: Icons.water_drop,
    prompt:
        "I'd like to keep my garden healthy. "
        "Attached is a picture of a plant I want to care for.",
  );

  const GardeningAction({
    required this.display,
    required this.prompt,
    required this.icon,
  });

  final String display;
  final String prompt;
  final IconData icon;
}
