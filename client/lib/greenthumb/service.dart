import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../platform_util.dart';
import '../views/view_model.dart';
import 'data.dart';

typedef ToolRequestCallback = void Function(String prompt);

typedef ToolResumeCallback =
    void Function({
      required String? ref,
      required String name,
      required String output,
    });

class GreenthumbService extends ChangeNotifier {
  late final host = PlatformUtil.isAndroidEmulator ? '10.0.2.2' : '127.0.0.1';
  final port = 3400;
  late final url = Uri.parse('http://$host:$port/greenThumb');
  late final headers = {'Content-Type': 'application/json'};

  final _messages = <RawMessage>[];
  List<Message> get messages => Message.messagesFrom(_messages);
  var _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> request(String prompt) {
    // clear the messages and add the new user prompt so that we can update
    // the UI immediately without waiting for the first response
    _messages.clear();
    _messages.add(RawMessage(role: 'user', content: [Content(text: prompt)]));

    return _post({
      'data': {'prompt': prompt},
    });
  }

  Future<void> resume({
    required String? ref,
    required String name,
    required String output,
  }) async {
    // add the tool response to the messages and notify listeners so that the
    // UI can update to show the tool response
    final toolResponse = ToolResponse(ref: ref, name: name, output: output);
    _messages.add(
      RawMessage(role: 'tool', content: [Content(toolResponse: toolResponse)]),
    );

    return _post({
      'data': {
        'resume': Resumption(respond: [Respond(toolResponse: toolResponse)]),
        'messages': _messages.take(_messages.length - 1).toList(),
      },
    });
  }

  Future<void> _post(Map<String, dynamic> body) async {
    _isLoading = true;
    notifyListeners();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw 'POST failed: ${response.statusCode} ${response.body}';
    }

    final json = jsonDecode(response.body);

    _messages.clear();
    _messages.addAll([
      for (final message in json['result']['messages'])
        RawMessage.fromJson(message),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _messages.clear();
    notifyListeners();
  }
}
