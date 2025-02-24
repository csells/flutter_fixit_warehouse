import 'package:flutter/material.dart';

enum GardeningAction {
  expandGarden(
    chatTitle: 'Expand My Garden',
    buttonName: 'Expand my\ngarden',
    icon: Icons.local_florist,
    prompt:
        "I'd like to expand my garden. "
        "Attached is a picture of a plant I'd like to add.",
  ),
  keepGardenHealthy(
    chatTitle: 'Keep My Garden Healthy',
    buttonName: 'Keep my\ngarden healthy',
    icon: Icons.water_drop,
    prompt:
        "I'd like to keep my garden healthy. "
        "Attached is a picture of a plant I want to care for.",
  );

  const GardeningAction({
    required this.chatTitle,
    required this.buttonName,
    required this.prompt,
    required this.icon,
  });

  final String chatTitle;
  final String buttonName;
  final String prompt;
  final IconData icon;
}
