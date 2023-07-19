import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';

import 'new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-base-41bef-default-rtdb.firebaseio.com', 'shopping-list.json');
    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.name == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'something went wrong! please try again';
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https('flutter-prep-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      // Optional: Show error message
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet.'));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shopping_list/data/categories.dart';
// import 'package:shopping_list/widget/dart/new_item.dart';
//
// import '../../models/grocery_item.dart';
//
// class GroceryList extends StatefulWidget {
//   const GroceryList({super.key});
//
//   @override
//   State<GroceryList> createState() => _GroceryListState();
// }
//
// class _GroceryListState extends State<GroceryList> {
//   List<GroceryItem> _groceryItem = [];
//   var isLoading = true;
//   String? error;
//
//   @override
//   void initState() {
//     super.initState();
//     loadItems();
//   }
//
//   void loadItems() async {
//     final url = Uri.https(
//       'flutter-base-41bef-default-rtdb.firebaseio.com',
//       'shopping-list.json',
//     );
//
//     final response = await http.get(url);
//     if (response.statusCode >= 400) {
//       setState(() {
//         error = 'Failed to fetch data.'
//             'Please try again later';
//       });
//     }
//     print(response.statusCode);
//     if (response.body == 'null') {
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }
//     final Map<String, dynamic> listData = json.decode(response.body);
//     final List<GroceryItem> loadedItems = [];
//     for (final item in listData.entries) {
//       final category = categories.entries
//           .firstWhere((cat) => cat.value.name == item.value['category'])
//           .value;
//       loadedItems.add(
//         GroceryItem(
//           id: item.key,
//           name: item.value['name'],
//           quantity: item.value['quantity'],
//           category: category,
//         ),
//       );
//     }
//     setState(() {
//       _groceryItem = loadedItems;
//       isLoading = false;
//     });
//     // print(response.body);
//     // print(response.statusCode);
//   }
//
//   void _addItem() async {
//     final newItem = await Navigator.of(context).push<GroceryItem>(
//       MaterialPageRoute(
//         builder: (_) => const NewItem(),
//       ),
//     );
//     if (newItem == null) {
//       return;
//     }
//     setState(() {
//       _groceryItem.add(newItem);
//     });
//   }
//
//   void removeItem(GroceryItem item) async {
//     final index = _groceryItem.indexOf(item);
//     setState(() {
//       _groceryItem.remove(item);
//     });
//     final url = Uri.https(
//       'flutter-base-41bef-default-rtdb.firebaseio.com',
//       'shopping-list/${item.id}.json',
//     );
//     final response = await http.delete(url);
//     if (response.statusCode >= 400) {
//       setState(() {
//         _groceryItem.insert(index, item);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Widget content = const Center(
//       child: Text('No item add yet.'),
//     );
//     if (isLoading) {
//       content = const Center(child: CircularProgressIndicator());
//     }
//     if (_groceryItem.isNotEmpty) {
//       content = ListView.builder(
//         itemCount: _groceryItem.length,
//         itemBuilder: (ctx, index) => Dismissible(
//           onDismissed: (_) {
//             removeItem(_groceryItem[index]);
//           },
//           key: ValueKey(_groceryItem[index].id),
//           child: ListTile(
//             title: Text(_groceryItem[index].name),
//             leading: Container(
//               width: 25,
//               height: 25,
//               decoration: BoxDecoration(
//                 color: _groceryItem[index].category.color,
//               ),
//             ),
//             trailing: Text(_groceryItem[index].quantity.toString()),
//           ),
//         ),
//       );
//     }
//     if (error != null) {
//       content = Center(
//         child: Text(error!),
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Your Categories',
//           // style: Theme.of(context).textTheme.titleLarge!.copyWith(
//           //  color: Theme.of(context).colorScheme.onBackground,
//         ),
//
//         //  backgroundColor: Theme.of(context).colorScheme.surface,
//         actions: [
//           IconButton(
//             onPressed: _addItem,
//             icon: const Icon(Icons.add),
//           )
//         ],
//       ),
//       body: content,
//     );
//   }
// }
