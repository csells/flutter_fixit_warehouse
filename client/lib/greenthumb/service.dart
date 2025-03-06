import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../platform_util.dart';
import 'model.dart';

class GreenthumbService extends ChangeNotifier {
  late final host = PlatformUtil.isAndroidEmulator ? '10.0.2.2' : '127.0.0.1';
  late final url = Uri.parse('http://$host:3400/greenThumb');
  late final headers = {'Content-Type': 'application/json'};

  final _messages = <Message>[];
  List<MessageUnit> get units => MessageUnit.unitsFrom(_messages);
  var _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> request(String prompt) => _post(Prompt(prompt: prompt).toJson());

  Future<void> resume(ToolResponse toolResponse) => _post({
    'resume':
        Resumption(respond: [Respond(toolResponse: toolResponse)]).toJson(),
    'messages': _messages.map((m) => m.toJson()).toList(),
  });

  Future<void> _post(Map<String, dynamic> body) async {
    _isLoading = true;
    notifyListeners();

    debugPrint('\n\n# REQUEST BODY:\n${jsonEncode(body)}\n\n');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw 'POST failed: ${response.statusCode} ${response.body}';
    }

    debugPrint('\n\n# RESPONSE BODY:\n${response.body}\n\n');

    final json = jsonDecode(response.body);

    _messages.clear();
    _messages.addAll([
      for (final message in json['messages']) Message.fromJson(message),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  // example usage:
  //     final image = await _compressImage(input['image']);
  //    final base64Image =
  //        image != null ? 'data:image/jpeg;base64,${base64Encode(image)}' : null;
  //
  // Future<Uint8List?> _compressImage(Uint8List image) async {
  //   String? base64Image;
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
  //   }
  //   return null;
  // }
}
