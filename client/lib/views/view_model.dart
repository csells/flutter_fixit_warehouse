import '../greenthumb/model.dart';

enum MessageUnitType { user, tool, model }

class MessageUnit {
  MessageUnit._(this.type, this.m1, [this.m2]);

  final MessageUnitType type;
  final Message m1;
  final Message? m2;

  factory MessageUnit.user(Message m1) {
    assert(m1.role == 'user');
    assert(m1.content.isNotEmpty);
    assert(m1.content.first.text != null);
    return MessageUnit._(MessageUnitType.user, m1);
  }

  factory MessageUnit.tool(Message m1, [Message? m2]) {
    assert(m1.role == 'model');
    assert(m2 == null || m2.role == 'tool');
    assert(m1.content.isNotEmpty);
    assert(m1.content[1].toolRequest != null);
    assert(m1.content[1].metadata != null);
    assert(
      m1.content[1].metadata!.interrupt == true ||
          m1.content[1].metadata!.resolvedInterrupt == true,
    );
    return MessageUnit._(MessageUnitType.tool, m1, m2);
  }

  factory MessageUnit.model(Message m1) {
    assert(m1.role == 'model');
    assert(m1.content.isNotEmpty);
    assert(m1.content.first.text != null);
    return MessageUnit._(MessageUnitType.model, m1);
  }

  String get text => switch (type) {
    MessageUnitType.user => m1.content.first.text!,
    MessageUnitType.model => m1.content.first.text!,
    MessageUnitType.tool => m1.content[1].toolRequest!.input.question,
  };

  static List<MessageUnit> unitsFrom(List<Message> messages) {
    final units = <MessageUnit>[];

    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];

      // Skip system messages
      if (message.role == 'system') continue;

      // Handle user messages
      if (message.role == 'user') {
        units.add(MessageUnit.user(message));
        continue;
      }

      // Handle model messages
      if (message.role == 'model') {
        if (message.content.length > 1 && message.content[1].metadata == null) {
          units.add(MessageUnit.model(message));
        } else if (i + 1 < messages.length && messages[i + 1].role == 'tool') {
          // if the next message is a tool, we've got a tool response
          units.add(MessageUnit.tool(message, messages[i + 1]));
          i++; // Skip the tool message in next iteration
        } else {
          // if the next message is not a tool, we've got a tool request
          units.add(MessageUnit.tool(message));
        }
      }
    }

    if (units.isEmpty) {
      // placeholder to make building the UI easier; shows the UserPromptView
      // before there are any messages (because we haven't requested anything
      // yet)
      units.add(
        MessageUnit.user(
          Message(role: 'user', content: [Content(text: 'TBD')]),
        ),
      );
    }

    return List.unmodifiable(units);
  }
}
