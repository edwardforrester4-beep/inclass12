class Item {
  final String id;
  final String name;
  final int quantity;
  final double price;

  Item({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  factory Item.fromMap(String id, Map<String, dynamic> map) {
    final quantityValue = map['quantity'];
    final priceValue = map['price'];

    return Item(
      id: id,
      name: map['name']?.toString() ?? '',
      quantity: quantityValue is int
          ? quantityValue
          : int.tryParse(quantityValue.toString()) ?? 0,
      price: priceValue is num
          ? priceValue.toDouble()
          : double.tryParse(priceValue.toString()) ?? 0.0,
    );
  }
}