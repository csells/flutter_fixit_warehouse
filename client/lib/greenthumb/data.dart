import 'dart:convert';

class RawMessage {
  final String role;
  final List<Content> content;
  final MessageMetadata? metadata;

  RawMessage({required this.role, required this.content, this.metadata});

  factory RawMessage.fromRawJson(String str) =>
      RawMessage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RawMessage.fromJson(Map<String, dynamic> json) => RawMessage(
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

  Content({this.text, this.toolRequest, this.metadata, this.toolResponse});

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
    if (text != null) 'text': text,
    if (toolRequest != null) 'toolRequest': toolRequest!.toJson(),
    if (metadata != null) 'metadata': metadata!.toJson(),
    if (toolResponse != null) 'toolResponse': toolResponse!.toJson(),
  };
}

class ContentMetadata {
  final bool? interrupt;
  final bool? resolvedInterrupt;

  ContentMetadata({this.interrupt, this.resolvedInterrupt});

  factory ContentMetadata.fromRawJson(String str) =>
      ContentMetadata.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ContentMetadata.fromJson(Map<String, dynamic> json) =>
      ContentMetadata(
        interrupt: json['interrupt'] as bool?,
        resolvedInterrupt: json['resolvedInterrupt'] as bool?,
      );

  Map<String, dynamic> toJson() => {
    if (interrupt != null) 'interrupt': interrupt,
    if (resolvedInterrupt != null) 'resolvedInterrupt': resolvedInterrupt,
  };
}

class ToolRequest {
  final String? ref;
  final String name;
  final Input input;

  ToolRequest({required this.ref, required this.name, required this.input});

  factory ToolRequest.fromRawJson(String str) =>
      ToolRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ToolRequest.fromJson(Map<String, dynamic> json) => ToolRequest(
    ref: json['ref'],
    name: json['name'],
    input: Input.fromJson(json['input']),
  );

  Map<String, dynamic> toJson() => {
    if (ref != null) 'ref': ref,
    'name': name,
    'input': input.toJson(),
  };
}

class Input {
  final String? question;
  final String? description;
  final List<String> choices;
  final int? min;
  final int? max;

  Input({
    required this.choices,
    required this.question,
    required this.description,
    this.min,
    this.max,
  });

  factory Input.fromRawJson(String str) => Input.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Input.fromJson(Map<String, dynamic> json) => Input(
    question: json['question'],
    description: json['description'],
    choices:
        json['choices'] == null
            ? []
            : List<String>.from(json['choices'].map((x) => x)),
    min: json['min'] != null ? (json['min'] as num).toInt() : null,
    max: json['max'] != null ? (json['max'] as num).toInt() : null,
  );

  Map<String, dynamic> toJson() => {
    'question': question,
    'choices': List<dynamic>.from(choices.map((x) => x)),
    if (min != null) 'min': min,
    if (max != null) 'max': max,
  };
}

class ToolResponse {
  final String? ref;
  final String name;
  final dynamic output;

  ToolResponse({required this.ref, required this.name, required this.output});

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
