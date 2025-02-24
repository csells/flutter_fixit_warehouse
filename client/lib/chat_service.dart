import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fix_warehouse/platform_util.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

typedef History = List<dynamic>;

sealed class Turn {}

class UserTurn extends Turn {
  final String userQuery;

  UserTurn({required this.userQuery});
}

class LlmQuestion extends Turn {
  final String llmResponse;
  final List<String> optionsForUser;
  final History history;
  final String? titleForChat;

  LlmQuestion.fromMap(Map<String, dynamic> object)
    : llmResponse = object['output']['llmResponse'],
      titleForChat = object['output']['titleForChat'],
      optionsForUser = object['output']['optionsForUser'].cast<String>() ?? [],
      history = object['history'];
}

class Chat with ChangeNotifier {
  List<Turn> turns = [];

  History get _previousHistory =>
      turns
          .whereType<LlmQuestion>()
          .map((llmQuestion) => llmQuestion.history)
          .lastOrNull ??
      [];

  Future<void> sendMessage(String userQuery, [XFile? image]) async {
    turns.add(UserTurn(userQuery: userQuery));

    final jsonResponse = await sendQuestionRequest(
      userQuery: userQuery,
      image: image,
      history: _previousHistory,
    );

    turns.add(LlmQuestion.fromMap(jsonResponse['result']));
    notifyListeners();
  }
}

Future<Map<String, dynamic>> sendQuestionRequest({
  required String userQuery,
  required History history,
  XFile? image,
}) async {
  final host = PlatformUtil.isAndroidEmulator ? '10.0.2.2' : '127.0.0.1';
  final url = Uri.parse('http://$host:3400/greenThumb');
  final headers = {'Content-Type': 'application/json'};

  String? base64Image;
  if (image != null) {
    final bytes = await image.readAsBytes();
    final originalImage = img.decodeImage(bytes);
    if (originalImage != null) {
      // Resize image to max dimension of 400px while maintaining aspect ratio
      final resized = img.copyResize(
        originalImage,
        width: originalImage.width > originalImage.height ? 400 : null,
        height: originalImage.height >= originalImage.width ? 400 : null,
      );
      // Encode as JPG with 85% quality and create data URL
      final compressed = img.encodeJpg(resized, quality: 85);
      base64Image = 'data:image/jpeg;base64,${base64Encode(compressed)}';
    }
  }

  final body = jsonEncode({
    'data': {
      'input': {'userQuery': userQuery, 'image': base64Image},
      'history': history,
    },
  });

  final response = await http.post(url, headers: headers, body: body);
  if (response.statusCode != 200) {
    throw "Response failed: ${response.statusCode} ${response.body}";
  }

  return json.decode(response.body);
}
