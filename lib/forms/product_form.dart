/*
 * This GrowERP software is in the public domain under CC0 1.0 Universal plus a
 * Grant of Patent License.
 * 
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 * 
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

import 'dart:io';
import 'package:decimal/decimal.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:models/@models.dart';
import 'package:core/blocs/@blocs.dart';
import 'package:core/helper_functions.dart';
import 'package:core/templates/@templates.dart';
import '@forms.dart';

class ProductForm extends StatelessWidget {
  final FormArguments? formArguments;
  const ProductForm({Key? key, this.formArguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Product? product = formArguments!.object as Product?;
    catalogMap[0] = MapItem(
        form: ProductPage(formArguments!.message, product),
        label: "product #${product != null ? product.productId : 'New'}",
        icon: Icon(Icons.home));
    return MainTemplate(
      menu: menuItems,
      mapItems: catalogMap,
      menuIndex: 3,
      tabIndex: 0,
    );
  }
}

class ProductPage extends StatefulWidget {
  final String? message;
  final Product? product;
  ProductPage(this.message, this.product);
  @override
  _ProductState createState() => _ProductState(message, product);
}

class _ProductState extends State<ProductPage> {
  final String? message;
  final Product? product;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _categorySearchBoxController = TextEditingController();

  bool loading = false;
  late Product updatedProduct;
  ProductCategory? _selectedCategory;
  PickedFile? _imageFile;
  dynamic _pickImageError;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  _ProductState(this.message, this.product) {
    HelperFunctions.showTopMessage(scaffoldMessengerKey, message);
  }

  void _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    try {
      final pickedFile = await _picker.getImage(
        source: source,
      );
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Future<void> retrieveLostData() async {
    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file;
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    var repos = context.read<Object>();
    return ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
            floatingActionButton: imageButtons(context, _onImageButtonPressed),
            body: BlocListener<ProductBloc, ProductState>(
                listener: (context, state) {
              if (state is ProductProblem) {
                loading = false;
                HelperFunctions.showMessage(
                    context, '${state.errorMessage}', Colors.red);
              }
              if (state is ProductSuccess) Navigator.of(context).pop();
            }, child: Builder(builder: (BuildContext context) {
              return Center(
                child:
                    !kIsWeb && defaultTargetPlatform == TargetPlatform.android
                        ? FutureBuilder<void>(
                            future: retrieveLostData(),
                            builder: (BuildContext context,
                                AsyncSnapshot<void> snapshot) {
                              if (snapshot.hasError) {
                                return Text(
                                  'Pick image error: ${snapshot.error}}',
                                  textAlign: TextAlign.center,
                                );
                              }
                              return _showForm(repos);
                            })
                        : _showForm(repos),
              );
            }))));
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Widget _showForm(repos) {
    if (product != null) {
      _nameController..text = product!.productName!;
      _descriptionController..text = product!.description!;
      _priceController..text = product!.price.toString();
      if (_selectedCategory == null && product?.categoryId != null)
        _selectedCategory = ProductCategory(
            categoryId: product!.categoryId,
            categoryName: product!.categoryName);
    }
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    }
    return Center(
        child: Container(
            width: 400,
            child: Form(
                key: _formKey,
                child: ListView(children: <Widget>[
                  SizedBox(height: 30),
                  CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 80,
                      child: _imageFile != null
                          ? kIsWeb
                              ? Image.network(_imageFile!.path)
                              : Image.file(File(_imageFile!.path))
                          : product?.image != null
                              ? Image.memory(
                                  product!.image!,
                                )
                              : Text(
                                  product?.productName?.substring(0, 1) ?? '',
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.black))),
                  SizedBox(height: 30),
                  TextFormField(
                    key: Key('name'),
                    decoration: InputDecoration(labelText: 'Product Name'),
                    controller: _nameController,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter a product name?';
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    key: Key('description'),
                    maxLines: 5,
                    decoration: InputDecoration(labelText: 'Description'),
                    controller: _descriptionController,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    key: Key('price'),
                    decoration: InputDecoration(labelText: 'Product Price'),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[0-9.,]+'))
                    ],
                    controller: _priceController,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter a price?';
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  DropdownSearch<ProductCategory>(
                    label: 'Category',
                    dialogMaxWidth: 300,
                    autoFocusSearchBox: true,
                    selectedItem: _selectedCategory,
                    dropdownSearchDecoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0)),
                    ),
                    searchBoxDecoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0)),
                    ),
                    showSearchBox: true,
                    searchBoxController: _categorySearchBoxController,
                    isFilteredOnline: true,
                    showClearButton: true,
                    key: Key('dropDownCategory'),
                    itemAsString: (ProductCategory? u) => "${u?.categoryName}",
                    onFind: (String filter) async {
                      var result = await repos.getCategory(
                          filter: _categorySearchBoxController.text);
                      return result;
                    },
                    onChanged: (ProductCategory newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                      key: Key('update'),
                      child: Text(
                          product?.productId == null ? 'Create' : 'Update'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate() && !loading) {
                          updatedProduct = Product(
                              productId: product?.productId,
                              productName: _nameController.text,
                              description: _descriptionController.text,
                              price: Decimal.parse(_priceController.text),
                              categoryId: _selectedCategory!.categoryId,
                              image: await HelperFunctions.getResizedImage(
                                  _imageFile?.path));
                          BlocProvider.of<ProductBloc>(context)
                              .add(UpdateProduct(
                            updatedProduct,
                          ));
                        }
                      }),
                  SizedBox(height: 20),
                  ElevatedButton(
                      key: Key('cancel'),
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ]))));
  }
}
