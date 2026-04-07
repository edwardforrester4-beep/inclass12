import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'items';

  Future<void> addItem(Item item) async {
    await _firestore.collection(_collection).add(item.toMap());
  }

  Future<void> updateItem(Item item) async {
    await _firestore.collection(_collection).doc(item.id).update(item.toMap());
  }

  Future<void> deleteItem(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Stream<List<Item>> streamItems() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
}