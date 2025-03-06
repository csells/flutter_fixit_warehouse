import 'package:flutter/material.dart';
import 'package:flutter_fix_warehouse/greenthumb/service.dart';
import 'package:flutter_fix_warehouse/views/action_view.dart';
import 'package:flutter_fix_warehouse/views/choice_tool_view.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../greenthumb/model.dart';

class WizardPage extends StatefulWidget {
  const WizardPage({super.key});

  @override
  State<WizardPage> createState() => _WizardPageState();
}

class _WizardPageState extends State<WizardPage> {
  final _chat = GreenthumbService();
  var _currentStep = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.green,
      title: const Row(
        children: [
          Icon(Icons.eco, color: Colors.white),
          SizedBox(width: 8),
          Text('GreenThumb', style: TextStyle(color: Colors.white)),
          Text(
            ' by Fix-It Warehouse',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    ),
    body: ListenableBuilder(
      listenable: _chat,
      builder: (context, child) {
        final units = _chat.units;

        // Update current step if new questions have been added
        if (_currentStep < units.length - 1) {
          _currentStep = units.length - 1;
        }

        // Create a PageController that starts at the current step
        final pageController = PageController(initialPage: _currentStep);

        return Column(
          children: [
            // Step indicators at the top
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(units.length, (index) {
                  final isCurrentStep = index == _currentStep;
                  final unit = units[index];
                  final needsAnswer = unit.type == MessageUnitType.model;

                  return GestureDetector(
                    onTap: () {
                      // Only allow going back to previous steps, not forward
                      if (index <= _currentStep) {
                        setState(() => _currentStep = index);
                        pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isCurrentStep ? Colors.green : Colors.green[100],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Center(
                        child:
                            needsAnswer
                                ? Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color:
                                        isCurrentStep
                                            ? Colors.white
                                            : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                : const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Tool title
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Step #${_currentStep + 1}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            // PageView for horizontal swiping between questions
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: units.isEmpty ? 1 : units.length,
                physics:
                    _currentStep == units.length - 1
                        ? const NeverScrollableScrollPhysics() // Prevent scrolling past the last question
                        : const PageScrollPhysics(),
                onPageChanged: (index) {
                  // Only allow going back to previous steps, not forward
                  if (index <= _currentStep) {
                    setState(() => _currentStep = index);
                  } else {
                    // If trying to go forward, snap back to current step
                    pageController.animateToPage(
                      _currentStep,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                itemBuilder: (context, index) {
                  final isCurrentStep = index == _currentStep;
                  final widget = _buildStepView(
                    units.isEmpty ? null : units[index],
                    isCurrentStep ? _onPrompt : null,
                  );

                  return _chat.isLoading
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          widget,
                          const SizedBox(height: 16),
                          const CircularProgressIndicator(),
                        ],
                      )
                      : widget;
                },
              ),
            ),
          ],
        );
      },
    ),
  );

  Widget _buildStepView(
    MessageUnit? unit,
    void Function(String)? onPrompt,
  ) => switch (unit?.type ?? MessageUnitType.user) {
    MessageUnitType.user => ActionView(unit: unit, onPrompt: onPrompt),
    MessageUnitType.model => MarkdownBody(data: unit!.text),
    MessageUnitType.tool => switch (unit!.m1.content.first.toolRequest.name) {
      'choiceInterrupt' => ChoiceToolView(unit: unit, onPrompt: onPrompt),
      _ =>
        throw Exception(
          'Unknown tool: ${unit.m1.content.first.toolRequest.name}',
        ),
    },
  };

  void _onPrompt(String prompt) {
    // void _onPrompt(String prompt, PageController pageController) {
    // setState(() {
    //   // Move to the next step after answering
    //   if (_currentStep < _chat.units.length - 1) {
    //     _currentStep++;
    //     // Animate to the next page
    //     pageController.animateToPage(
    //       _currentStep,
    //       duration: const Duration(milliseconds: 300),
    //       curve: Curves.easeInOut,
    //     );
    //   }
    // });

    _chat.request(prompt);
  }
}
