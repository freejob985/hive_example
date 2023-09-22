import 'package:flutter/material.dart';
import 'package:hive_example/Item.dart';
import 'package:hive_example/ItemAdapter.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ItemAdapter());

  await Hive.openBox('items');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Flutter Example',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _itemController = TextEditingController();
  final _searchController = TextEditingController();
  final _itemBox = Hive.box('items');
  List<Item> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hive Flutter Example'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _itemController,
            decoration: InputDecoration(labelText: 'Enter an item'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final itemName = _itemController.text;
                if (itemName.isNotEmpty) {
                  final newItem = Item(itemName);
                  await _itemBox.add(newItem);
                  _itemController.clear();
                  setState(() {});
                }
              } catch (e) {
                print("ERR::$e");
              }
            },
            child: Text('Add Item'),
          ),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(labelText: 'Search for an item'),
          ),
          ElevatedButton(
            onPressed: () {
              _searchResults.clear();
              final query = _searchController.text.toLowerCase();
              for (var i = 0; i < _itemBox.length; i++) {
                final item = _itemBox.getAt(i) as Item;
                if (item.name.toLowerCase().contains(query)) {
                  _searchResults.add(item);
                }
              }
              setState(() {});
            },
            child: Text('Search'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.isNotEmpty
                  ? _searchResults.length
                  : _itemBox.length,
              itemBuilder: (context, index) {
                final item = _searchResults.isNotEmpty
                    ? _searchResults[index]
                    : _itemBox.getAt(index) as Item;
                return ListTile(
                  title: Text(item.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _itemBox.deleteAt(index);
                          if (_searchResults.isNotEmpty) {
                            _searchResults.removeAt(index);
                          }
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          final updatedItemName = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              final textController =
                                  TextEditingController(text: item.name);
                              return AlertDialog(
                                title: Text('Edit Item'),
                                content: TextField(
                                  controller: textController,
                                  decoration: InputDecoration(
                                      labelText: 'Enter updated item name'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(textController.text);
                                    },
                                    child: Text('Update'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (updatedItemName != null) {
                            item.name = updatedItemName;
                            _itemBox.putAt(index, item);
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _itemController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
