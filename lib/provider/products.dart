import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  List<Product> get items {
    return [..._items];
  }

  final String?  authToken;
  final String? userId;
  Products(this.authToken,this.userId, this._items);

  
  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    debugPrint('here');
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> getDataFromDatabase([bool filterUser=false]) async {
    final filterByUser=filterUser? 'orderBy="creatorId"&equalTo="$userId"': '';
    var url = Uri.parse(
        'https://flutter-update-8e677-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterByUser');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        return;
      }
      url = Uri.parse(
          'https://flutter-update-8e677-default-rtdb.firebaseio.com/userFavoriteStatus/$userId.json?auth=$authToken');
      final favoriteResponse=await http.get(url);
      final extractedData1=json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((key, value) {
        loadedProducts.add(
          Product(
            id: key,
            title: value['title'],
            imageUrl: value['imageUrl'],
            description: value['description'],
            price: value['price'],
            isFavorite: extractedData1==null?false: extractedData1[key] ??false,
          ),
        );
        _items = loadedProducts;
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://flutter-update-8e677-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      var addingProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          imageUrl: product.imageUrl,
          description: product.description,
          price: product.price);
      _items.add(addingProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteItem(String productId) async {
    final url = Uri.parse(
        'https://flutter-update-8e677-default-rtdb.firebaseio.com/products/$productId.json?auth=$authToken');
    final existingPRodIndex =
        _items.indexWhere((element) => element.id == productId);
    Product? existingProd = _items[existingPRodIndex];
    _items.removeAt(existingPRodIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingPRodIndex, existingProd);
      notifyListeners();
      throw HttpException('Could not delete an item.');
    }
    existingProd = null;
  }

  Future<void> editProduct(String id, Product product) async {
    final url = Uri.parse(
        'https://flutter-update-8e677-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final indexOfProduct = _items.indexWhere((element) => element.id == id);
    await http.patch(
      url,
      body: json.encode({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
      }),
    );
    if (indexOfProduct >= 0) {
      _items[indexOfProduct] = product;

      notifyListeners();
    } else {
      debugPrint('error');
    }
  }
}
