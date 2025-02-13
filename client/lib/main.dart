import 'package:flutter/material.dart';
import 'package:flutter_picture_taker/flutter_picture_taker.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  ChangeNotifierProvider<ConversationData>(
    create: (context) => ConversationData(),
    builder: (context, child) => const FixItWarehouseApp(),
  ),
);

class FixItWarehouseApp extends StatelessWidget {
  const FixItWarehouseApp({super.key});

  @override
  Widget build(BuildContext context) =>
      const MaterialApp(title: 'Fix-It Warehouse', home: HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Row(
        children: [
          const Icon(Icons.build_circle, size: 30),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.white),
              Text('Valley Stream', style: TextStyle(color: Colors.white)),
              Text(' 10PM', style: TextStyle(color: Colors.white)),
              Spacer(),
              Icon(Icons.local_shipping, color: Colors.white),
              Text('11581', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Home',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const Text('/', style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'DIY Projects & Ideas',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const Text('/', style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Outdoor Living',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Garden Ideas & Projects',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Image.network(
              'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Looking for gardening help?'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF26722),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      debugPrint('Pressed');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GardeningScreen(),
                        ),
                      );
                    },
                    child: const Text('Try GreenThumb™'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Suggested Categories',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'All Categories',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag),
                    onPressed: () {},
                  ),
                  const Text('Shop All'),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                  ),
                  const Text('Services'),
                ],
              ),
              Column(
                children: [
                  IconButton(icon: const Icon(Icons.build), onPressed: () {}),
                  const Text('DIY'),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.account_circle),
                    onPressed: () {},
                  ),
                  const Text('Log In'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

class GardeningData extends ChangeNotifier {
  String? _selectedAction;

  String? get selectedAction => _selectedAction;

  set selectedAction(String? value) {
    _selectedAction = value;
    notifyListeners();
  }
}

class GardeningScreen extends StatelessWidget {
  const GardeningScreen({super.key});

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
      MaterialPageRoute(builder: (context) => const ChatScreen()),
    );
  }
}

class PlantHealthCheckPage extends StatefulWidget {
  const PlantHealthCheckPage({super.key});

  @override
  State createState() => _PlantHealthCheckPageState();
}

class _PlantHealthCheckPageState extends State<PlantHealthCheckPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Container(
      color: Colors.grey[200],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 48,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        // Handle camera button press
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class ConversationData extends ChangeNotifier {
  List<ChatMessage> messages = [
    ChatMessage(
      text:
          "Based on the leaf markings, that's a Calathea. I've added it to your plants.\nThe edges of the leaves are brown and crispy, indicating dehydration. How often are you watering this plant?",
      isUser: false,
      type: ChatMessageType.question,
      options: [
        'A few times a month',
        'A few times a week',
        'A few times a day',
      ],
    ),
  ];

  void addResponse(String response) {
    messages = [
      ...messages,
      ChatMessage(text: response, isUser: true, type: ChatMessageType.answer),
    ];
    messages = [
      ...messages,
      ChatMessage(
        text: 'Try watering daily for the next 3 weeks:',
        isUser: false,
        type: ChatMessageType.recommendation,
        reminder: 'Water Calathea #1\nDaily for 3 weeks',
        plantFood: 'Miracle-Gro Indoor Plant Food\n\$8.97',
        followUp: "We'll reassess in 3 weeks!",
      ),
    ];
    notifyListeners();
  }
}

enum ChatMessageType { question, answer, recommendation }

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.type,
    this.options,
    this.reminder,
    this.plantFood,
    this.followUp,
  });
  final String text;
  final bool isUser;
  final ChatMessageType type;
  List<String>? options;
  String? reminder;
  String? plantFood;
  String? followUp;
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Calathea #1')),
    body: Consumer<ConversationData>(
      builder:
          (context, conversationData, child) => Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: conversationData.messages.length,
                  itemBuilder: (context, index) {
                    final message = conversationData.messages[index];

                    if (message.type == ChatMessageType.question) {
                      return QuestionWidget(message: message);
                    } else if (message.type == ChatMessageType.answer) {
                      return AnswerWidget(message: message);
                    } else {
                      return RecommendationWidget(message: message);
                    }
                  },
                ),
              ),
            ],
          ),
    ),
  );
}

class QuestionWidget extends StatelessWidget {
  const QuestionWidget({required this.message, super.key});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.lightGreen,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(message.text),
          ),
        ),
        if (message.options != null)
          ...message.options!.map<Widget>(
            (option) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Provider.of<ConversationData>(
                    context,
                    listen: false,
                  ).addResponse(option);
                },
                child: Text(option),
              ),
            ),
          ),
      ],
    ),
  );
}

class AnswerWidget extends StatelessWidget {
  const AnswerWidget({required this.message, super.key});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: Align(
      alignment: Alignment.topRight,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(message.text),
        ),
      ),
    ),
  );
}

class RecommendationWidget extends StatelessWidget {
  const RecommendationWidget({required this.message, super.key});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.lightGreen,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(message.text),
          ),
        ),
        if (message.reminder != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.blue[100],
                border: Border.all(color: Colors.blue, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Icon(Icons.alarm_add, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text('Add reminder\n${message.reminder!}'),
                  ],
                ),
              ),
            ),
          ),
        if (message.plantFood != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Image.network(
                      'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "If you're worried about losing the plant, try:\n${message.plantFood!}",
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (message.followUp != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(message.followUp!),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(width: 1, color: Colors.grey),
            ),
            onPressed: () {},
            child: const Text(
              'Ask a follow up',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {},
            child: const Text('Done for now'),
          ),
        ),
      ],
    ),
  );
}
