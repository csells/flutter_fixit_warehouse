import 'package:flutter/material.dart';
import 'package:flutter_fix_warehouse/greenthumb/service.dart';
import 'package:flutter_fix_warehouse/views/tool_choice_picker.dart';
import 'package:flutter_fix_warehouse/views/tool_range_value_picker.dart';
import 'package:flutter_fix_warehouse/views/user_prompt_picker.dart';

import '../views/llm_response_view.dart';
import '../views/tool_image_picker.dart';
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
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _chat,
    builder: (context, child) {
      final units = _chat.units;

      const titleTextStyle = TextStyle(fontSize: 18, color: Colors.white);
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Row(
            children: [
              const Icon(Icons.eco, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'GreenThumb',
                        style: titleTextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' by Fix-It Warehouse',
                        style: titleTextStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (units.length > 1)
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Restart',
                onPressed:
                    () => setState(() {
                      _chat.clear();
                      _currentStep = 0;
                    }),
              ),
          ],
        ),
        body: Builder(
          builder: (context) {
            // Create a PageController that starts at the current step
            final pageController = PageController(
              initialPage: units.length - 1,
            );

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
                            color:
                                isCurrentStep
                                    ? Colors.green
                                    : Colors.green[100],
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
                      final widget = _buildStepView(
                        units[index],
                        index == _currentStep,
                      );

                      return _chat.isLoading
                          ? Stack(
                            children: [
                              // Dimmed widget
                              Opacity(opacity: 0.4, child: widget),
                              // Overlay with progress indicator
                              Container(
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  color: Colors.green,
                                ),
                              ),
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
    },
  );

  Widget _buildStepView(MessageUnit unit, bool isCurrentStep) {
    final isToolResponse =
        unit.type == MessageUnitType.tool && unit.toolResponse != null;
    final onRequest = isCurrentStep && !isToolResponse ? _onRequest : null;
    final onResume = isCurrentStep && !isToolResponse ? _onResume : null;

    return switch (unit.type) {
      // gather initial user prompt
      MessageUnitType.user => UserPromptPicker(
        unit: unit,
        onRequest: onRequest,
      ),

      // display final model response
      MessageUnitType.model => LlmResponseView(unit: unit),

      // Handle interrupt tools
      MessageUnitType.tool => switch (unit.toolRequest.name) {
        'choiceInterrupt' => ToolChoicePicker(unit: unit, onResume: onResume),
        'imageInterrupt' => ToolImagePicker(unit: unit, onResume: onResume),
        'rangeInterrupt' => ToolRangeValuePicker(
          unit: unit,
          onResume: onResume,
        ),
        _ => throw Exception('Unknown tool: ${unit.toolRequest.name}'),
      },
    };
  }

  void _onRequest(String prompt) => _chat.request(prompt);

  void _onResume({String? ref, required String name, required String output}) =>
      _chat.resume(ref: ref, name: name, output: output);
}
