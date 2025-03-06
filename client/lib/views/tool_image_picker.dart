import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fix_warehouse/greenthumb/model.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image/image.dart' as img;

import '../platform_util.dart';
import 'view_model.dart';

class ToolImagePicker extends StatelessWidget {
  ToolImagePicker({required this.unit, required this.onResume, super.key})
    : assert(unit.type == MessageUnitType.tool),
      image =
          unit.toolResponse?.output != null
              ? base64Decode(unit.toolResponse!.output.split(',').last)
              : null;

  final MessageUnit unit;
  final Uint8List? image;
  final void Function(ToolResponse)? onResume;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          child: MarkdownBody(
            data: unit.text,
            styleSheet: MarkdownStyleSheet(
              p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              image == null
                  ? InkWell(
                    onTap: () => _getPicture(context),
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Tap to take a picture',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ),
                  )
                  : Image.memory(image!, fit: BoxFit.contain),
        ),
      ],
    ),
  );

  void _getPicture(BuildContext context) async {
    final file = await PlatformUtil.getPicture(context);
    if (file == null) return;

    // shrink the image if it's too large for Genkit
    final bytes = await file.readAsBytes();
    final shrunk = (await _resizeImageIfNeeded(bytes))!;
    final base64Image = 'data:image/jpeg;base64,${base64Encode(shrunk)}';

    onResume!(
      ToolResponse(
        ref: unit.toolRequest.ref,
        name: unit.toolRequest.name,
        output: base64Image,
      ),
    );
  }

  Future<Uint8List?> _resizeImageIfNeeded(Uint8List bytes) async {
    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) return null;

    // resize image to max dimension of 400px while maintaining aspect ratio
    final resized = img.copyResize(
      originalImage,
      width: originalImage.width > originalImage.height ? 400 : null,
      height: originalImage.height >= originalImage.width ? 400 : null,
    );

    // encode as JPG with 85% quality and create data URL
    return img.encodeJpg(resized, quality: 85);
  }
}
