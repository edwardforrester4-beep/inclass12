import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final FirestoreService service = FirestoreService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void openItemDialog({Item? item}) {
    final formKey = GlobalKey<FormState>();

    if (item != null) {
      nameController.text = item.name;
      quantityController.text = item.quantity.toString();
      priceController.text = item.price.toString();
    } else {
      nameController.clear();
      quantityController.clear();
      priceController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Add Item' : 'Edit Item'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a quantity';
                    }
                    final parsed = int.tryParse(value.trim());
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid non-negative integer';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a price';
                    }
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid non-negative price';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final newItem = Item(
                  id: item?.id ?? '',
                  name: nameController.text.trim(),
                  quantity: int.parse(quantityController.text.trim()),
                  price: double.parse(priceController.text.trim()),
                );

                if (item == null) {
                  await service.addItem(newItem);
                } else {
                  await service.updateItem(newItem);
                }

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(item == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory App'),
      ),
      body: StreamBuilder<List<Item>>(
        stream: service.streamItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final items = snapshot.data ?? [];

          final filteredItems = items.where((item) {
            return item.name.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          final totalInventoryValue = filteredItems.fold<double>(
            0.0,
            (sum, item) => sum + (item.quantity * item.price),
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search by item name',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Total Inventory Value: \$${totalInventoryValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          items.isEmpty
                              ? 'No items yet.'
                              : 'No items match your search.',
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];

                          return ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                              'Qty: ${item.quantity} | \$${item.price.toStringAsFixed(2)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => openItemDialog(item: item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => service.deleteItem(item.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openItemDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}