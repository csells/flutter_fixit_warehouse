import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image/image.dart' as img;

import '../greenthumb/service.dart';
import '../platform_util.dart';
import 'gt_button.dart';
import 'view_model.dart';

class ToolImagePicker extends StatefulWidget {
  ToolImagePicker({required this.message, required this.onResume, super.key})
    : assert(message.toolResponse == null || onResume == null),
      selectedImage =
          message.toolResponse?.output != null
              ? base64Decode(message.toolResponse!.output.split(',').last)
              : null;

  final InterruptMessage message;
  final Uint8List? selectedImage;
  final ToolResumeCallback? onResume;

  @override
  State<ToolImagePicker> createState() => _ToolImagePickerState();
}

class _ToolImagePickerState extends State<ToolImagePicker> {
  Uint8List? _currentImageBytes;
  var _isCompressing = false;

  @override
  void initState() {
    super.initState();
    _currentImageBytes = widget.selectedImage;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MarkdownBody(
          data: widget.message.text,
          styleSheet: MarkdownStyleSheet(
            p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentImageBytes != null)
                  Expanded(
                    child: Image.memory(
                      _currentImageBytes!,
                      fit: BoxFit.contain,
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OverflowBar(
                    spacing: 16,
                    children: [
                      GtButton(
                        onPressed:
                            _isCompressing || widget.onResume == null
                                ? null
                                : () => _getPicture(context),
                        child: const Text('Take Picture'),
                      ),
                      if (_currentImageBytes != null)
                        GtButton(
                          onPressed:
                              _isCompressing || widget.onResume == null
                                  ? null
                                  : _submit,
                          child: const Text('Submit'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  void _getPicture(BuildContext context) async {
    final file = await PlatformUtil.getPicture(context);
    if (file == null) return;
    _currentImageBytes = await file.readAsBytes();
    setState(() {});
  }

  void _submit() async {
    assert(widget.onResume != null);
    assert(_currentImageBytes != null);

    // shrink the image if it's too large for Genkit
    setState(() => _isCompressing = true);

    // give the web a chance to show the disabled buttons
    Future.delayed(const Duration(microseconds: kIsWeb ? 250 : 0), () async {
      final bytes = (await _resizeImageIfNeeded(_currentImageBytes!))!;

      widget.onResume!(
        ref: widget.message.toolRequest!.ref,
        name: widget.message.toolRequest!.name,
        output: 'data:image/jpeg;base64,${base64Encode(bytes)}',
      );
      setState(() => _isCompressing = false);
    });
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
