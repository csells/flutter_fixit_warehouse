import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:future_builder_ex/future_builder_ex.dart';

import '../data/product_repository.dart';
import '../provider/custom_provider.dart';
import '../views/product_list_view.dart';
import '../views/product_response_view.dart';
import '../views/search_box.dart';
import 'split_or_tabs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String _searchText = '';
  final _repositoryFuture = ProductRepository.instance;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Flutter Fixit Warehouse')),
    body: FutureBuilderEx<ProductRepository>(
      future: _repositoryFuture,
      builder:
          (context, repository) => SplitOrTabs(
            tabs: const [Tab(text: 'Products'), Tab(text: 'Chat')],
            children: [
              Column(
                children: [
                  SearchBox(onSearchChanged: _updateSearchText),
                  Expanded(
                    child: ProductListView(
                      repository: repository!,
                      searchText: _searchText,
                    ),
                  ),
                ],
              ),
              LlmChatView(
                provider: CustomProvider(),
                responseBuilder:
                    (context, response) =>
                        ProductResponseView(response: response),
              ),
            ],
          ),
    ),
  );

  void _updateSearchText(String text) => setState(() => _searchText = text);
}
