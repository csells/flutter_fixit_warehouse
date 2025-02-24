import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'platform_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlatformUtil.init();
  runApp(const FixItWarehouseApp());
}

class FixItWarehouseApp extends StatelessWidget {
  const FixItWarehouseApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Fix-It Warehouse',
    home: const HomePage(),
    debugShowCheckedModeBanner: false,
  );
}
