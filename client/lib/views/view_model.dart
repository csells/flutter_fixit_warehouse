import 'package:collection/collection.dart';

import '../greenthumb/data.dart';

sealed class Message {
  Message._(RawMessage rawMessage) : _rawMessage = rawMessage;
  final RawMessage _rawMessage;

  String get text;

  static List<Message> messagesFrom(List<RawMessage> rawMessages) {
    final result = <Message>[];

    for (var i = 0; i < rawMessages.length; i++) {
      final rawMessage = rawMessages[i];

      // skip system messages
      if (rawMessage.role == 'system') continue;

      // handle user messages
      if (rawMessage.role == 'user') {
        result.add(UserRequest(rawMessage));
        continue;
      }

      // handle model messages
      assert(rawMessage.role == 'model');
      assert(rawMessage.content.isNotEmpty);

      final toolRequest = Message.toolRequestFrom(rawMessage);

      if (toolRequest == null) {
        // found a model response and not a interrupt tool request
        result.add(ModelResponse(rawMessage));
        continue;
      }

      final metadata = Message.metadataFrom(rawMessage);

      if (i + 1 == rawMessages.length || rawMessages[i + 1].role != 'tool') {
        // found a tool request without a response, but is it an interrupt?

        if (metadata == null) {
          // no metadata means this is not an interrupt, so skip it
          continue;
        } else {
          // metadata means this is an interrupt
          result.add(InterruptMessage(rawMessage));
        }
        continue;
      }

      // found a tool response and a tool request, but is it an interrupt?
      if (metadata == null) {
        // no metadata means this is not an interrupt, so skip it
      } else {
        // metadata means this is an interrupt
        result.add(InterruptMessage(rawMessage, rawMessages[i + 1]));
      }

      // skip the interrupt tool response message in next loop thru
      i++;
    }

    if (result.isEmpty) {
      // placeholder to make building the UI easier; shows the UserPromptView
      // before there are any messages (because we haven't requested anything
      // yet)
      result.add(
        UserRequest(RawMessage(role: 'user', content: [Content(text: 'TBD')])),
      );
    }

    return List.unmodifiable(result);
  }

  static ContentMetadata? metadataFrom(RawMessage rawMessage) {
    return rawMessage.content
        .firstWhereOrNull((m) => m.metadata != null)
        ?.metadata;
  }

  static ToolRequest? toolRequestFrom(RawMessage rawMessage) {
    return rawMessage.content
        .firstWhereOrNull((m) => m.toolRequest != null)
        ?.toolRequest;
  }

  static ToolResponse? toolResponseFrom(RawMessage rawMessage) {
    return rawMessage.content
        .firstWhereOrNull((m) => m.toolResponse != null)
        ?.toolResponse;
  }
}

class UserRequest extends Message {
  UserRequest(RawMessage rawMessage) : super._(rawMessage) {
    assert(rawMessage.role == 'user');
    assert(rawMessage.content.isNotEmpty);
    assert(rawMessage.content.first.text != null);
  }

  @override
  String get text => _rawMessage.content.first.text!;
}

class InterruptMessage extends Message {
  final RawMessage? _rawMessage2;

  InterruptMessage(RawMessage rawMessage, [RawMessage? rawMessage2])
    : _rawMessage2 = rawMessage2,
      super._(rawMessage) {
    assert(rawMessage.role == 'model');
    assert(rawMessage2 == null || rawMessage2.role == 'tool');
    assert(rawMessage.content.isNotEmpty);
  }

  ContentMetadata? get metadata => Message.metadataFrom(_rawMessage);
  ToolRequest? get toolRequest => Message.toolRequestFrom(_rawMessage);
  ToolResponse? get toolResponse =>
      _rawMessage2 == null ? null : Message.toolResponseFrom(_rawMessage2);

  @override
  String get text => toolRequest?.input.question ?? '';
}

class ModelResponse extends Message {
  ModelResponse(RawMessage rawMessage) : super._(rawMessage) {
    assert(rawMessage.role == 'model');
    assert(rawMessage.content.isNotEmpty);
    assert(rawMessage.content.first.text != null);
  }

  @override
  String get text => _rawMessage.content.first.text!;
}
