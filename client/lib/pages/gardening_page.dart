import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picture_taker/flutter_picture_taker.dart';
import 'package:image_picker/image_picker.dart';

import '../gardening_action.dart';
import 'chat_page.dart';

class GardeningPage extends StatefulWidget {
  const GardeningPage({super.key});

  @override
  State<GardeningPage> createState() => _GardeningPageState();
}

class _GardeningPageState extends State<GardeningPage> {
  GardeningAction? _selectedAction;
  final List<XFile> _images = [];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(
        children: [
          Icon(Icons.eco, color: Colors.green),
          SizedBox(width: 8),
          Text('GreenThumb', style: TextStyle(color: Colors.black)),
          Text(
            ' by Fix-It Warehouse',
            style: TextStyle(fontSize: 18, color: Colors.green),
          ),
        ],
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are you looking to do?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final action in GardeningAction.values)
                SizedBox(
                  width: 160,
                  height: 160,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _selectedAction = action),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedAction == action
                              ? Colors.lightGreen
                              : Colors.lightGreen.shade100,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(action.icon, size: 48),
                        SizedBox(height: 8),
                        Text(action.buttonName, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (_selectedAction != null) ...[
            const SizedBox(height: 32),
            const Text(
              'Your plants',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_images.isEmpty) const Text('Nothing yet! '),
                  InkWell(
                    onTap: _getPicture,
                    child: const Text(
                      'Take a picture',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  if (_images.isNotEmpty) const Text(' or choose a picture '),
                  const Text(' of a plant to get started'),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: GridView.extent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 32,
                  crossAxisSpacing: 32,
                  children: [
                    for (final image in _images)
                      InkWell(
                        onTap: () => _navigateToChat(image),
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              kIsWeb
                                  ? Image.network(image.path, fit: BoxFit.cover)
                                  : Image.file(
                                    File(image.path),
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Future<void> _getPicture() async {
    final image =
        _isDesktop
            ? await ImagePicker().pickImage(source: ImageSource.gallery)
            // ignore: use_build_context_synchronously
            : await showStillCameraDialog(context);

    if (image == null) return;
    setState(() => _images.add(image));
    _navigateToChat(image);
  }

  Future<void> _navigateToChat(XFile image) {
    assert(_selectedAction != null);

    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(action: _selectedAction!, image: image),
      ),
    );
  }

  bool get _isDesktop => switch (defaultTargetPlatform) {
    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.linux => true,
    _ => false,
  };
}
