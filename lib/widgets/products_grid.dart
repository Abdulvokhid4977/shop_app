import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/products.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
 final bool showFavs;
  const ProductsGrid(this.showFavs, {super.key});

  @override
  Widget build(BuildContext context) {
    final productsData=Provider.of<Products>(context);
    final products=showFavs ? productsData.favoriteItems :productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2.4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: products[index],
        child: const ProductItem(
          // products[index].id,
          // products[index].imageUrl,
          // products[index].title,
        ),
      ),
      itemCount: products.length,
    );
  }
}
