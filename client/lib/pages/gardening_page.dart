import 'package:flutter/material.dart';
import 'package:flutter_picture_taker/flutter_picture_taker.dart';
import 'package:provider/provider.dart';

import '../data/garden_data.dart';
import 'chat_page.dart';

class GardeningPage extends StatelessWidget {
  const GardeningPage({super.key});

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
            style: TextStyle(fontSize: 12, color: Colors.grey),
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
              ElevatedButton.icon(
                onPressed: () {
                  Provider.of<GardeningData>(context, listen: false)
                      .selectedAction = 'Expand my garden';
                },
                icon: const Icon(Icons.local_florist),
                label: const Text('Expand my garden'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen.shade100,
                  foregroundColor: Colors.black,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Provider.of<GardeningData>(context, listen: false)
                      .selectedAction = 'Keep my garden healthy';
                },
                icon: const Icon(Icons.water_drop),
                label: const Text('Keep my garden healthy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen.shade100,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Your plants',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Center(
            child: InkWell(
              onTap: () {
                // Handle "Take a picture" action.
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => _takePicture(context),
                    child: const Text(
                      'Take a picture',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const Text(' of a plant to get started'),
                ],
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Ask a gardening question',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _takePicture(BuildContext context) async {
    final image = await showStillCameraDialog(context);
    if (image == null || !context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatPage()),
    );
  }
}
