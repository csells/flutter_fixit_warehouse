import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

typedef History = List<dynamic>;

sealed class Turn {}

class UserTurn extends Turn {
  final String userQuery;

  UserTurn({required this.userQuery});
}

class ModelTurn extends Turn {
  final String llmQuery;
  final List<String> optionsForUser;
  final List<dynamic> storeOptions;
  final History history;

  ModelTurn.fromMap(Map<String, dynamic> object)
    : llmQuery = object['output']['llmQuery'],
      optionsForUser = object['output']['optionsForUser'].cast<String>() ?? [],
      storeOptions = object['output']['storeOptions'] ?? [],
      history = object['history'];
}

class Chat with ChangeNotifier {
  List<Turn> turns = [];

  History get _previousHistory =>
      turns
          .whereType<ModelTurn>()
          .map((modelTurn) => modelTurn.history)
          .lastOrNull ??
      [];

  Future<void> sendMessage(String userQuery) async {
    turns.add(UserTurn(userQuery: userQuery));

    final jsonResponse = await greenThumbRequest(
      userQuery: userQuery,
      history: _previousHistory,
    );

    turns.add(ModelTurn.fromMap(jsonResponse['result']));

    notifyListeners();
  }
}

Future<Map<String, dynamic>> greenThumbRequest({
  required String userQuery,
  required History history,
}) async {
  final url = Uri.parse('http://127.0.0.1:3400/greenThumb');
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({
    'data': {
      'input': {'userQuery': userQuery},
      'history': history,
    },
  });

  final response = await http.post(url, headers: headers, body: body);
  if (response.statusCode != 200) {
    throw "Response failed: ${response.statusCode} ${response.body}";
  }

  return json.decode(response.body);
}
