import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../greenthumb/service.dart';
import 'view_model.dart';

class UserPromptPicker extends StatelessWidget {
  UserPromptPicker({this.onRequest, required Message message, super.key})
    : assert(message is UserRequest),
      selectedAction = GardeningAction.fromPrompt(message.text);

  final GardeningAction? selectedAction;
  final ToolRequestCallback? onRequest;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Text(
        'What are you looking to do?',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final action in GardeningAction.values)
            SizedBox(
              width: 160,
              height: 160,
              child: ElevatedButton(
                onPressed:
                    onRequest != null ? () => onRequest!(action.prompt) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedAction == action
                          ? Colors.lightGreen
                          : Colors.lightGreen.shade100,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(action.icon, size: 48),
                    SizedBox(height: 8),
                    Text(action.buttonName, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
        ],
      ),
    ],
  );
}

enum GardeningAction {
  expandGarden(
    buttonName: 'Expand my\ngarden',
    icon: Icons.local_florist,
    prompt: 'I\'d like to expand my garden.',
  ),
  keepGardenHealthy(
    buttonName: 'Keep my\ngarden healthy',
    icon: Icons.water_drop,
    prompt: 'I\'d like to keep my garden healthy.',
  );

  const GardeningAction({
    required this.buttonName,
    required this.prompt,
    required this.icon,
  });

  final String buttonName;
  final String prompt;
  final IconData icon;

  static GardeningAction? fromPrompt(String? prompt) =>
      values.firstWhereOrNull((v) => v.prompt == prompt);
}
