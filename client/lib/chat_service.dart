import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

typedef History = List<dynamic>;

sealed class Turn {}

class UserTurn extends Turn {
  final String userQuery;

  UserTurn({required this.userQuery});
}

class ModelTurn extends Turn {
  final String llmQuery;
  final List<String> optionsForUser;
  final String productDescription;
  final History history;
  ModelTurn.fromMap(Map<String, dynamic> object)
    : llmQuery = object['output']['llmQuery'],
      optionsForUser = object['output']['optionsForUser'].cast<String>() ?? [],
      productDescription = object['output']['productDescription'],
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

  Future<void> sendMessage(String userQuery, [XFile? image]) async {
    turns.add(UserTurn(userQuery: userQuery));

    final jsonResponse = await greenThumbRequest(
      userQuery: userQuery,
      image: image,
      history: _previousHistory,
    );

    turns.add(ModelTurn.fromMap(jsonResponse['result']));

    notifyListeners();
  }
}

Future<Map<String, dynamic>> greenThumbRequest({
  required String userQuery,
  required History history,
  XFile? image,
}) async {
  final url = Uri.parse('http://127.0.0.1:3400/greenThumb');
  final headers = {'Content-Type': 'application/json'};

  String? base64Image;
  if (image != null) {
    final bytes = await image.readAsBytes();
    final originalImage = img.decodeImage(bytes);
    if (originalImage != null) {
      // TODO: still needed with GenKit 1.x?
      // TODO: this blocks the next page from loading on the web
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
