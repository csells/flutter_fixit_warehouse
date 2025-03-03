import 'dart:convert';

// import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fix_warehouse/platform_util.dart';
import 'package:http/http.dart' as http;
// import 'package:image/image.dart' as img;

typedef History = List<dynamic>;

sealed class Turn {
  const Turn();

  factory Turn.fromMap(Map<String, dynamic> map) => switch (map['type']) {
    'interruptRequest' => _interruptFromMap(map),
    _ => throw ArgumentError('Unknown turn type: ${map['type']}'),
  };

  static Turn _interruptFromMap(Map<String, dynamic> map) {
    assert(map['type'] == 'interruptRequest');
    assert(map['interrupts'].length == 1); // TODO: handle multiple interrupts

    final toolRequest = map['interrupts'].first['toolRequest'];
    return switch (toolRequest['name']) {
      'gtChoiceInterrupt' => LlmChoice.fromMap(toolRequest),
      _ =>
        throw ArgumentError(
          'Unknown tool request name: ${toolRequest['name']}',
        ),
    };
  }
}

class UserQuery extends Turn {
  final String query;
  UserQuery({required this.query});

  // { "type": "gtInput", "query": "I'd like to expand my garden." }
  Map<String, dynamic> toMap() => {'type': 'gtInput', 'query': query};
}

class LlmChoice extends Turn {
  final String query;
  final List<String> choices;

  // {
  //   "query": "What kind of plants are you growing?",
  //   "choices": [ "Vegetables", "Herbs", "A mix of different plants" ]
  // }
  LlmChoice.fromMap(Map<String, dynamic> map)
    : query = map['query'],
      choices = map['choices'].cast<String>();
}

class Chat with ChangeNotifier {
  List<Turn> turns = [];

  Future<void> sendQuery(String query) async {
    final userQuery = UserQuery(query: query);
    turns.add(userQuery);
    final turn = await _postToGreenthumb(userQuery.toMap());
    turns.add(turn);
    notifyListeners();
  }

  Future<Turn> _postToGreenthumb(Map<String, dynamic> input) async {
    final host = PlatformUtil.isAndroidEmulator ? '10.0.2.2' : '127.0.0.1';
    final url = Uri.parse('http://$host:3400/greenThumb');
    final headers = {'Content-Type': 'application/json'};

    // String? base64Image;
    // if (image != null) {
    //   final bytes = await image.readAsBytes();
    //   final originalImage = img.decodeImage(bytes);
    //   if (originalImage != null) {
    //     // Resize image to max dimension of 400px while maintaining aspect ratio
    //     final resized = img.copyResize(
    //       originalImage,
    //       width: originalImage.width > originalImage.height ? 400 : null,
    //       height: originalImage.height >= originalImage.width ? 400 : null,
    //     );
    //     // Encode as JPG with 85% quality and create data URL
    //     final compressed = img.encodeJpg(resized, quality: 85);
    //     base64Image = 'data:image/jpeg;base64,${base64Encode(compressed)}';
    //   }
    // }

    final body = jsonEncode(input);
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode != 200) {
      throw "Response failed: ${response.statusCode} ${response.body}";
    }

    return json.decode(response.body);
  }
}
