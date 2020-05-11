import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus() async {
    final url = 'https://antsrl-academy.firebaseio.com/products/$id.json';
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final res = await http.patch(
        url,
        body: json.encode({
          'isFavorite': isFavorite,
        }),
      );

      if (res.statusCode >= 400) {
        isFavorite = !isFavorite;
        notifyListeners();
        throw HttpException('Cannot delete');
      }
    } catch (error) {
      throw error;
    }
  }
}
