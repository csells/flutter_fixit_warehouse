import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../chat_service.dart';
import '../gardening_action.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.action, required this.image});

  final GardeningAction action;
  final XFile image;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _title = ValueNotifier('Loading...');
  final _chat = Chat();
  final _selectedOptions = <LlmQuestion, String>{};
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();

    // NOTE: delaying so that the page can draw on the web before starting
    // the chat; the delay is sending the image to the server.
    final delay = kIsWeb ? const Duration(seconds: 1) : Duration.zero;
    Future.delayed(delay, () async {
      await _chat.sendMessage(widget.action.prompt, widget.image);
      final title = _chat.turns.whereType<LlmQuestion>().last.titleForChat;
      _title.value = title ?? widget.action.chatTitle;
    });
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
    valueListenable: _title,
    builder:
        (context, title, child) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green,
            title: Text(title, style: const TextStyle(color: Colors.white)),
          ),
          body: child,
        ),
    child: ListenableBuilder(
      listenable: _chat,
      builder: (context, child) {
        final llmTurns = _chat.turns.whereType<LlmQuestion>().toList();

        if (llmTurns.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        // Update current step if new questions have been added
        if (_currentStep < llmTurns.length - 1) {
          _currentStep = llmTurns.length - 1;
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
                children: List.generate(llmTurns.length, (index) {
                  final isCurrentStep = index == _currentStep;
                  final hasAnswer = _selectedOptions.containsKey(
                    llmTurns[index],
                  );

                  return GestureDetector(
                    onTap: () {
                      // Only allow going back to previous steps, not forward
                      if (index <= _currentStep) {
                        setState(() {
                          _currentStep = index;
                        });
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
                            hasAnswer
                                ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                                : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color:
                                        isCurrentStep
                                            ? Colors.white
                                            : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Question title
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Question #${_currentStep + 1}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            // PageView for horizontal swiping between questions
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: llmTurns.length,
                physics:
                    _currentStep == llmTurns.length - 1
                        ? const NeverScrollableScrollPhysics() // Prevent scrolling past the last question
                        : const PageScrollPhysics(),
                onPageChanged: (index) {
                  // Only allow going back to previous steps, not forward
                  if (index <= _currentStep) {
                    setState(() {
                      _currentStep = index;
                    });
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
                  final turn = llmTurns[index];
                  final isCurrentStep = index == _currentStep;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: LlmQuestionView(
                      text: turn.llmResponse,
                      options: turn.optionsForUser,
                      onPressed:
                          isCurrentStep
                              ? (option) =>
                                  _optionSelected(turn, option, pageController)
                              : null,
                      selectedOption: _selectedOptions[turn],
                      isActive: isCurrentStep,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  );

  void _optionSelected(
    LlmQuestion turn,
    String option,
    PageController pageController,
  ) {
    setState(() {
      _selectedOptions[turn] = option;
      // Move to the next step after answering
      if (_currentStep < _chat.turns.whereType<LlmQuestion>().length - 1) {
        _currentStep++;
        // Animate to the next page
        pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    _chat.sendMessage(option);
  }
}

class LlmQuestionView extends StatelessWidget {
  const LlmQuestionView({
    super.key,
    required this.text,
    required this.options,
    required this.onPressed,
    this.selectedOption,
    this.isActive = true,
  });

  final String text;
  final List<String> options;
  final void Function(String)? onPressed;
  final String? selectedOption;
  final bool isActive;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.eco, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MarkdownBody(
                data: text,
                styleSheet: MarkdownStyleSheet(
                  p: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 40.0), // Align with text
          child: Center(
            child: Column(
              children: [
                for (final option in options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed:
                            !isActive
                                ? null
                                : (selectedOption == null ||
                                    selectedOption == option)
                                ? () => onPressed?.call(option)
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        child: Text(option, textAlign: TextAlign.center),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
