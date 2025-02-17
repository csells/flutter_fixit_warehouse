import 'package:flutter/material.dart';

import 'gardening_page.dart';

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
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.location_on),
              Text('Valley Stream'),
              Text(' 10PM'),
              Spacer(),
              Icon(Icons.local_shipping),
              Text('11581'),
            ],
          ),
        ),
      ),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Image.network(
                'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
                fit: BoxFit.cover,
              ),
            ),
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
                        builder: (context) => const GardeningPage(),
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
        NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.shopping_bag),
              label: 'Shop All',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Services',
            ),
            NavigationDestination(icon: Icon(Icons.build), label: 'DIY'),
            NavigationDestination(
              icon: Icon(Icons.account_circle),
              label: 'Log In',
            ),
          ],
          onDestinationSelected: (index) {},
        ),
      ],
    ),
  );
}
