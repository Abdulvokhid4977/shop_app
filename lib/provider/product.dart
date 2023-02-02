import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;
  Product(
      {required this.id,
      required this.title,
      required this.imageUrl,
      required this.description,
      this.isFavorite = false,
      required this.price}
      );

  void favoriteToggle(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteState(String? token, String? userId) async {
    var oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url = Uri.parse(
        'https://flutter-update-8e677-default-rtdb.firebaseio.com/userFavoriteStatus/$userId/$id.json?auth=$token');
    try {
      final response = await http.put(url,
          body: json.encode(
             isFavorite,
          ));
      if (response.statusCode >= 400) {
        favoriteToggle(oldStatus);
      }
    } catch (error) {
      favoriteToggle(oldStatus);
    }
  }
}
