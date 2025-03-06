import 'package:flutter/material.dart';
import 'package:flutter_fix_warehouse/greenthumb/service.dart';
import 'package:flutter_fix_warehouse/views/tool_choices_view.dart';
import 'package:flutter_fix_warehouse/views/user_prompt_view.dart';

import '../greenthumb/model.dart';
import '../views/model_response_view.dart';
import '../views/view_model.dart';

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

        // Create a PageController that starts at the current step
        final pageController = PageController(initialPage: units.length - 1);

        // Update current step if new questions have been added
        if (_currentStep < units.length - 1) {
          _currentStep = units.length - 1;
          Future.microtask(() {
            pageController.animateToPage(
              _currentStep,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        }

        return Column(
          children: [
            // Step indicators at the top
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(units.length, (index) {
                  final isCurrentStep = index == _currentStep;

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
                            isCurrentStep
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

            // PageView for horizontal swiping between questions
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: units.length,
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
                    units[index],
                    isCurrentStep ? _onRequest : null,
                    isCurrentStep ? _onResume : null,
                  );

                  return _chat.isLoading
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
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
    MessageUnit unit,
    void Function(String)? onRequest,
    void Function(ToolResponse)? onResume,
  ) => switch (unit.type) {
    MessageUnitType.user => UserPromptView(unit: unit, onRequest: onRequest),
    MessageUnitType.model => ModelResponseView(unit: unit),
    MessageUnitType.tool => switch (unit.m1.content[1].toolRequest!.name) {
      'choiceInterrupt' => ToolChoicesView(unit: unit, onResume: onResume),
      _ =>
        throw Exception(
          'Unknown tool: ${unit.m1.content.first.toolRequest!.name}',
        ),
    },
  };

  void _onRequest(String prompt) => _chat.request(prompt);

  void _onResume(ToolResponse toolResponse) => _chat.resume(toolResponse);
}
