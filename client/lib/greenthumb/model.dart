import 'dart:convert';

class Message {
  final String role;
  final List<Content> content;
  final MessageMetadata? metadata;

  Message({required this.role, required this.content, required this.metadata});

  factory Message.fromRawJson(String str) => Message.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    role: json['role'],
    content: List<Content>.from(
      json['content'].map((x) => Content.fromJson(x)),
    ),
    metadata:
        json['metadata'] == null
            ? null
            : MessageMetadata.fromJson(json['metadata']),
  );

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': List<dynamic>.from(content.map((x) => x.toJson())),
    if (metadata != null) 'metadata': metadata!.toJson(),
  };
}

class Content {
  final String? text;
  final ToolRequest? toolRequest;
  final ContentMetadata? metadata;
  final ToolResponse? toolResponse;

  Content({
    required this.text,
    required this.toolRequest,
    required this.metadata,
    required this.toolResponse,
  });

  factory Content.fromRawJson(String str) => Content.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    text: json['text'],
    toolRequest:
        json['toolRequest'] == null
            ? null
            : ToolRequest.fromJson(json['toolRequest']),
    metadata:
        json['metadata'] == null
            ? null
            : ContentMetadata.fromJson(json['metadata']),
    toolResponse:
        json['toolResponse'] == null
            ? null
            : ToolResponse.fromJson(json['toolResponse']),
  );

  Map<String, dynamic> toJson() => {
    'text': text,
    if (toolRequest != null) 'toolRequest': toolRequest!.toJson(),
    if (metadata != null) 'metadata': metadata!.toJson(),
    if (toolResponse != null) 'toolResponse': toolResponse!.toJson(),
  };
}

class ContentMetadata {
  final bool? resolvedInterrupt;

  ContentMetadata({required this.resolvedInterrupt});

  factory ContentMetadata.fromRawJson(String str) =>
      ContentMetadata.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ContentMetadata.fromJson(Map<String, dynamic> json) =>
      ContentMetadata(resolvedInterrupt: json['resolvedInterrupt']);

  Map<String, dynamic> toJson() => {
    if (resolvedInterrupt != null) 'resolvedInterrupt': resolvedInterrupt,
  };
}

class ToolRequest {
  final String name;
  final Input input;

  ToolRequest({required this.name, required this.input});

  factory ToolRequest.fromRawJson(String str) =>
      ToolRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ToolRequest.fromJson(Map<String, dynamic> json) =>
      ToolRequest(name: json['name'], input: Input.fromJson(json['input']));

  Map<String, dynamic> toJson() => {'name': name, 'input': input.toJson()};
}

class Input {
  final List<String> choices;
  final String question;

  Input({required this.choices, required this.question});

  factory Input.fromRawJson(String str) => Input.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Input.fromJson(Map<String, dynamic> json) => Input(
    choices: List<String>.from(json['choices'].map((x) => x)),
    question: json['question'],
  );

  Map<String, dynamic> toJson() => {
    'choices': List<dynamic>.from(choices.map((x) => x)),
    'question': question,
  };
}

class ToolResponse {
  final String? ref;
  final String name;
  final String output;

  ToolResponse({this.ref, required this.name, required this.output});

  factory ToolResponse.fromRawJson(String str) =>
      ToolResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ToolResponse.fromJson(Map<String, dynamic> json) => ToolResponse(
    ref: json['ref'],
    name: json['name'],
    output: json['output'],
  );

  Map<String, dynamic> toJson() => {
    if (ref != null) 'ref': ref,
    'name': name,
    'output': output,
  };
}

class MessageMetadata {
  final bool resumed;

  MessageMetadata({required this.resumed});

  factory MessageMetadata.fromRawJson(String str) =>
      MessageMetadata.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MessageMetadata.fromJson(Map<String, dynamic> json) =>
      MessageMetadata(resumed: json['resumed']);

  Map<String, dynamic> toJson() => {'resumed': resumed};
}

class Resumption {
  final List<Respond> respond;

  Resumption({required this.respond});

  factory Resumption.fromRawJson(String str) =>
      Resumption.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Resumption.fromJson(Map<String, dynamic> json) => Resumption(
    respond: List<Respond>.from(
      json['respond'].map((x) => Respond.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    'respond': List<dynamic>.from(respond.map((x) => x.toJson())),
  };
}

class Respond {
  final ToolResponse toolResponse;

  Respond({required this.toolResponse});

  factory Respond.fromRawJson(String str) => Respond.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Respond.fromJson(Map<String, dynamic> json) =>
      Respond(toolResponse: ToolResponse.fromJson(json['toolResponse']));

  Map<String, dynamic> toJson() => {'toolResponse': toolResponse.toJson()};
}

enum MessageUnitType { user, tool, model }

class MessageUnit {
  MessageUnit._(this.type, this.m1, [this.m2]);

  final MessageUnitType type;
  final Message m1;
  final Message? m2;

  factory MessageUnit.user(Message m1) {
    assert(m1.role == 'user');
    return MessageUnit._(MessageUnitType.user, m1);
  }

  factory MessageUnit.tool(Message m1, Message m2) {
    assert(m1.role == 'model' && m2.role == 'tool');
    return MessageUnit._(MessageUnitType.tool, m1, m2);
  }

  factory MessageUnit.model(Message m1) {
    assert(m1.role == 'model');
    return MessageUnit._(MessageUnitType.model, m1);
  }

  String get text => switch (type) {
    MessageUnitType.user => m1.content.first.text!,
    MessageUnitType.model => m1.content.first.text!,
    _ => throw ArgumentError('Message unit type $type has no default text'),
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
        // Check next message if available
        if (i + 1 < messages.length && messages[i + 1].role == 'tool') {
          units.add(MessageUnit.tool(message, messages[i + 1]));
          i++; // Skip the tool message in next iteration
        } else {
          units.add(MessageUnit.model(message));
        }
      }
    }

    return List.unmodifiable(units);
  }
}
