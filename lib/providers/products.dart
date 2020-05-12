import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  // var _showFavoritesOnly = false;
  final String authToken;
  final String userId;

  Products(
    this.authToken,
    this.userId,
    this._items,
  );

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prod) => prod.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://antsrl-academy.firebaseio.com/products.json?auth=$authToken&$filterString';
    print(filterString);
    try {
      final res = await http.get(url);
      final resBody = json.decode(res.body) as Map<String, dynamic>;
      if (resBody == null) {
        return;
      }
      url =
          'https://antsrl-academy.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      final favoriteData = jsonDecode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      resBody.forEach((key, value) {
        loadedProducts.add(
          Product(
            id: key,
            title: value['title'],
            description: value['description'],
            price: value['price'],
            imageUrl: value['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[key] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addProduct(Product p) async {
    final url =
        'https://antsrl-academy.firebaseio.com/products.json?auth=$authToken';
    try {
      final res = await http.post(
        url,
        body: json.encode({
          'title': p.title,
          'description': p.description,
          'imageUrl': p.imageUrl,
          'price': p.price,
          'creatorId': userId
        }),
      );

      final newProduct = new Product(
        id: json.decode(res.body)['name'],
        title: p.title,
        description: p.description,
        price: p.price,
        imageUrl: p.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final url =
        'https://antsrl-academy.firebaseio.com/products/$id.json?auth=$authToken';
    final prodIndex = _items.indexWhere((p) => p.id == id);
    if (prodIndex < 0) return;

    await http.patch(
      url,
      body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'imageUrl': newProduct.imageUrl,
        'price': newProduct.price,
      }),
    );
    _items[prodIndex] = newProduct;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://antsrl-academy.firebaseio.com/products/$id.json?auth=$authToken';
    final existinProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items.removeAt(existinProductIndex);
    notifyListeners();
    final res = await http.delete(url);

    if (res.statusCode >= 400) {
      _items.insert(existinProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Cannot delete');
    }
    existingProduct = null;
  }
}
