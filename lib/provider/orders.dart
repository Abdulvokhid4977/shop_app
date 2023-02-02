import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final DateTime dateTime;
  final double amount;
  final List<CartItem> product;
  OrderItem({
    required this.id,
    required this.product,
    required this.amount,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<OrderItem> get orders {
    return [..._orders];
  }
  final String? token;
  final String? userId;
  Orders(this.token, this.userId, this._orders);

  Future<void> addOrder(List<CartItem> addingProduct, double amount) async {
    final timestamp = DateTime.now();
    final url = Uri.parse(
        'https://flutter-update-8e677-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    final response = await http.post(
      url,
      body: json.encode({
        'product': addingProduct
            .map((e) => {
                  'id': e.id,
                  'title': e.title,
                  'quantity': e.quantity,
                  'price': e.price,
                })
            .toList(),
        'amount': amount,
        'dateTime': timestamp.toIso8601String(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        product: addingProduct,
        amount: amount,
        dateTime: timestamp,
      ),
    );
    notifyListeners();
  }

  Future<void> getDataFromDatabase() async {

    final url = Uri.parse(
        'https://flutter-update-8e677-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body);
      if(extractedData==null){
        return;
      }
      final List<OrderItem> loadedOrders = [];
      extractedData.forEach((order, orderData) {
        loadedOrders.add(
          OrderItem(
            id: order,
            product: (orderData['product'] as List<dynamic>)
                .map((e) => CartItem(
                    title: e['title'],
                    id: e['id'],
                    price: e['price'],
                    quantity: e['quantity']))
                .toList(),
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
          ),
        );
        _orders = loadedOrders.reversed.toList();
        notifyListeners();
      });
    } catch (error) {
      rethrow;
    }
  }
}
