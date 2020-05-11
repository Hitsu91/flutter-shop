import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/cart.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    const url = 'https://antsrl-academy.firebaseio.com/orders.json';
    final response = await http.get(url);
    print(json.decode(response.body));
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url = 'https://antsrl-academy.firebaseio.com/orders.json';
    final timestamp = DateTime.now().toIso8601String();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timestamp,
        'products': [
          cartProducts
              .map(
                (cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price
                },
              )
              .toList()
        ],
      }),
    );

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: DateTime.now(),
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
