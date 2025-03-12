import '../greenthumb/model.dart';

enum MessageUnitType { user, tool, model }

class MessageUnit {
  MessageUnit._(this.type, this.m1, [this.m2]);

  final MessageUnitType type;
  final RawMessage m1;
  final RawMessage? m2;

  factory MessageUnit.user(RawMessage m1) {
    assert(m1.role == 'user');
    assert(m1.content.isNotEmpty);
    assert(m1.content.first.text != null);
    return MessageUnit._(MessageUnitType.user, m1);
  }

  factory MessageUnit.tool(RawMessage m1, [RawMessage? m2]) {
    assert(m1.role == 'model');
    assert(m2 == null || m2.role == 'tool');
    assert(m1.content.isNotEmpty);
    return MessageUnit._(MessageUnitType.tool, m1, m2);
  }

  ContentMetadata get metadata {
    assert(type == MessageUnitType.tool);
    final metadata =
        m1.content.length == 2
            ? m1.content[1].metadata
            : m1.content[0].metadata;
    assert(metadata != null);
    return metadata!;
  }

  ToolRequest get toolRequest {
    assert(type == MessageUnitType.tool);
    return m1.content.length == 2
        ? m1.content[1].toolRequest!
        : m1.content[0].toolRequest!;
  }

  ToolResponse? get toolResponse {
    assert(type == MessageUnitType.tool);
    if (m2 == null) return null;

    assert(m2!.role == 'tool');
    assert(m2!.content.first.toolResponse != null);
    return m2!.content.first.toolResponse!;
  }

  factory MessageUnit.model(RawMessage m1) {
    assert(m1.role == 'model');
    assert(m1.content.isNotEmpty);
    assert(m1.content.first.text != null);
    return MessageUnit._(MessageUnitType.model, m1);
  }

  String get text => switch (type) {
    MessageUnitType.user => m1.content.first.text!,
    MessageUnitType.model => m1.content.first.text!,
    // NOTE: adding the content text is often redundant
    // MessageUnitType.tool =>
    //   '${m1.content[0].text ?? ''}\n${toolRequest.input.question}',
    MessageUnitType.tool => toolRequest.input.question,
  };

  static List<MessageUnit> unitsFrom(List<RawMessage> messages) {
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
        assert(message.content.isNotEmpty);
        final metadata =
            message.content.length == 2
                ? message.content[1].metadata
                : message.content[0].metadata;
        if (metadata == null) {
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
          RawMessage(role: 'user', content: [Content(text: 'TBD')]),
        ),
      );
    }

    return List.unmodifiable(units);
  }
}
