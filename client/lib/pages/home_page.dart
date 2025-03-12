import 'package:flutter/material.dart';
import 'package:flutter_fix_warehouse/pages/wizard_page.dart';

import '../views/gt_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.green,
      toolbarHeight: 68,
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
        child: Row(
          children: [
            const Icon(Icons.build_circle, size: 30, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search, color: Colors.green),
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
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
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
              child: Image.asset('assets/blue-bird.jpg', fit: BoxFit.cover),
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
                GtButton(
                  backgroundColor: const Color(0xFFF26722),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WizardPage(),
                      ),
                    );
                  },
                  child: const Text('Try GreenThumb'),
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
