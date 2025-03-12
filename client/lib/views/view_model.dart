import '../greenthumb/model.dart';

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
      if (rawMessage.role == 'model') {
        assert(rawMessage.content.isNotEmpty);
        final toolRequest =
            rawMessage.content.length == 2
                ? rawMessage.content[1].toolRequest
                : rawMessage.content[0].toolRequest;

        if (toolRequest == null) {
          // found a model response and not a tool request
          result.add(ModelResponse(rawMessage));
        } else if (i + 1 < rawMessages.length &&
            rawMessages[i + 1].role == 'tool') {
          // found a tool response as well as a tool request
          result.add(ToolMessage(rawMessage, rawMessages[i + 1]));

          // skip the tool message in next iteration
          i++;
        } else {
          // found a tool request without a response
          result.add(ToolMessage(rawMessage));
        }
      }
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

class ToolMessage extends Message {
  final RawMessage? _rawMessage2;

  ToolMessage(RawMessage rawMessage, [RawMessage? rawMessage2])
    : _rawMessage2 = rawMessage2,
      super._(rawMessage) {
    assert(rawMessage.role == 'model');
    assert(rawMessage2 == null || rawMessage2.role == 'tool');
    assert(rawMessage.content.isNotEmpty);
  }

  ContentMetadata get metadata {
    final metadata =
        _rawMessage.content.length == 2
            ? _rawMessage.content[1].metadata
            : _rawMessage.content[0].metadata;
    assert(metadata != null);
    return metadata!;
  }

  ToolRequest get toolRequest {
    return _rawMessage.content.length == 2
        ? _rawMessage.content[1].toolRequest!
        : _rawMessage.content[0].toolRequest!;
  }

  ToolResponse? get toolResponse {
    if (_rawMessage2 == null) return null;

    assert(_rawMessage2.role == 'tool');
    return _rawMessage2.content.first.toolResponse!;
  }

  @override
  String get text => toolRequest.input.question;
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
