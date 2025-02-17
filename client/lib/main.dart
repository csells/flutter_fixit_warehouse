import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/chat_data.dart';
import 'pages/home_page.dart';

void main() => runApp(
  ChangeNotifierProvider<ConversationData>(
    create: (context) => ConversationData(),
    builder: (context, child) => const FixItWarehouseApp(),
  ),
);

class FixItWarehouseApp extends StatelessWidget {
  const FixItWarehouseApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Fix-It Warehouse',
    home: const HomePage(),
    debugShowCheckedModeBanner: false,
  );
}
