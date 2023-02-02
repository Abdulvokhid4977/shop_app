import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/products.dart';

import '../provider/product.dart';

class EditProduct extends StatefulWidget {
  const EditProduct({Key? key}) : super(key: key);
  static const routeName = 'editing page';
  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  late Product product;
  var isLoading = false;
  var product1 = Product(
    id: null.toString(),
    title: '',
    imageUrl: '',
    description: '',
    price: 0,
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(updateScreen);
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(updateScreen);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments.toString();
      if (productId != 'null') {
        product = Provider.of<Products>(context).findById(productId!);
        _initValues = {
          'title': product.title,
          'description': product.description,
          'price': product.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = product.imageUrl;
      } else {
        debugPrint('here');
        product = product1;
        _initValues = {
          'title': product.title,
          'description': product.description,
          'price': product.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = product.imageUrl;
      }
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  void updateScreen() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> submitData() async {
    final isValidate = _form.currentState?.validate();
    if (!isValidate!) {
      return;
    }
    _form.currentState?.save();
    isLoading = true;
    if (product.id != 'null') {
      await Provider.of<Products>(context, listen: false).editProduct(product.id, product);
      setState(() {
        isLoading = false;
      });
    } else {
      product.id = UniqueKey().toString();
      try {
        await Provider.of<Products>(context, listen: false).addProduct(product);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An error occurred'),
            content: const Text('Something went wrong.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      }
    }
    setState(() {
      isLoading = false;
    });
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (product.id=='null')? const Text('Adding a product'):const Text('Editing a Product'),
        actions: [
          IconButton(
            onPressed: submitData,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: const InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Fill in this blank';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        onSaved: (value) {
                          product = Product(
                            id: product.id,
                            title: value!,
                            imageUrl: product.imageUrl,
                            description: product.description,
                            price: product.price,
                            isFavorite: product.isFavorite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue:
                            product.price == 0 ? null : _initValues['price'],
                        decoration: const InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Fill in this blank';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Enter numbers bigger than 0';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        onSaved: (value) {
                          product = Product(
                            id: product.id,
                            title: product.title,
                            imageUrl: product.imageUrl,
                            description: product.description,
                            price: double.parse(value!),
                            isFavorite: product.isFavorite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Fill in this blank';
                          }
                          if (value.length < 10) {
                            return 'Minimum 10 characters';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          product = Product(
                            id: product.id,
                            title: product.title,
                            imageUrl: product.imageUrl,
                            description: value!,
                            price: product.price,
                            isFavorite: product.isFavorite,
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8, right: 5),
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                border: Border.all(width: 1),
                                color: Colors.grey),
                            child: FittedBox(
                              child: _imageUrlController.text.isEmpty
                                  ? const Text('Enter URL')
                                  : Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Fill in this blank';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Enter a url starting with \'http\' or \'https\'';
                                }

                                return null;
                              },
                              onFieldSubmitted: (_) {
                                setState(() {});
                                submitData();
                              },
                              onSaved: (value) {
                                product = Product(
                                  id: product.id,
                                  title: product.title,
                                  imageUrl: value!,
                                  description: product.description,
                                  price: product.price,
                                  isFavorite: product.isFavorite,
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
