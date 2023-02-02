import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../provider/orders.dart';

class OrderItems extends StatefulWidget {
  final OrderItem orders;
  const OrderItems(this.orders, {super.key});

  @override
  State<OrderItems> createState() => _OrderItemsState();
}

class _OrderItemsState extends State<OrderItems> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: expanded ? min(widget.orders.product.length * 20.0 + 110, 200) : 95,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text(
                '\$${widget.orders.amount.toStringAsFixed(2)}',
              ),
              subtitle: Text(
                DateFormat("dd/MM/yyyy hh:mm").format(widget.orders.dateTime),
              ),
              trailing: IconButton(
                icon: expanded
                    ? const Icon(Icons.expand_less)
                    : const Icon(Icons.expand_more),
                onPressed: () {
                  setState(() {
                    expanded = !expanded;
                  });
                },
              ),
            ),
              AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: expanded ? min(widget.orders.product.length * 20.0 + 10, 100) : 0,
              child: ListView(
                children: [
                  ...(widget.orders.product)
                      .map((e) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                  Text(
                                  e.title,
                                  // softWrap: true,
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),

                                ),

                              Text(
                                '${e.quantity}x \$${e.price}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),)
                      .toList(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
