/*
 * This software is in the public domain under CC0 1.0 Universal plus a
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../models/@models.dart';
import '../blocs/@blocs.dart';
import '../helper_functions.dart';
import '../routing_constants.dart';
import '../widgets/@widgets.dart';

class CategoriesForm extends StatelessWidget {
  final FormArguments formArguments;
  CategoriesForm(this.formArguments);
  @override
  Widget build(BuildContext context) {
    var a = (formArguments) => (CategoriesFormHeader(formArguments.authenticate,
        formArguments.message, formArguments.object));
    return CheckConnectAndAddRail(a(formArguments), 4);
  }
}

class CategoriesFormHeader extends StatefulWidget {
  final Authenticate authenticate;
  final String message;
  final Catalog catalog;
  const CategoriesFormHeader(this.authenticate, this.message, this.catalog);
  @override
  _CategoriesFormStateHeader createState() =>
      _CategoriesFormStateHeader(authenticate, message, catalog);
}

class _CategoriesFormStateHeader extends State<CategoriesFormHeader> {
  final Authenticate authenticate;
  final String message;
  final Catalog catalog;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _CategoriesFormStateHeader(this.authenticate, this.message, this.catalog) {
    HelperFunctions.showTopMessage(_scaffoldKey, message);
  }
  @override
  Widget build(BuildContext context) {
    Authenticate authenticate = this.authenticate;
    Catalog catalog = this.catalog;
    BlocProvider.of<CatalogBloc>(context).add(LoadCatalog());
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            title: companyLogo(context, authenticate, 'Category List'),
            automaticallyImplyLeading:
                ResponsiveWrapper.of(context).isSmallerThan(TABLET)),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            dynamic cat = await Navigator.pushNamed(context, CategoryRoute,
                arguments: FormArguments(
                    authenticate, 'Enter new category information', catalog));
            Navigator.pushNamed(context, UsersRoute,
                arguments:
                    FormArguments(authenticate, 'User has been added..', cat));
          },
          tooltip: 'Add new category',
          child: Icon(Icons.add),
        ),
        body: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthProblem)
                HelperFunctions.showMessage(
                    context, '${state.errorMessage}', Colors.red);
            },
            child: BlocConsumer<CatalogBloc, CatalogState>(
                listener: (context, state) {
              print("===cats listen  state: $state");
              if (state is CatalogProblem)
                HelperFunctions.showMessage(
                    context, '${state.errorMessage}', Colors.red);
              if (state is CatalogLoaded)
                HelperFunctions.showMessage(
                    context, '${state.message}', Colors.green);
              if (state is CatalogLoading)
                HelperFunctions.showMessage(
                    context, '${state.message}', Colors.green);
            }, builder: (context, state) {
              print("===cats build  state: $state");
              if (state is CatalogLoaded) catalog = state.catalog;
              return categoryList(catalog);
            })));
  }

  Widget categoryList(catalog) {
    List<ProductCategory> categories = catalog?.categories;
    print("=====cats form $catalog");
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          // you could add any widget
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.transparent,
            ),
            title: Row(
              children: <Widget>[
                Expanded(
                    child: Text("Category Name", textAlign: TextAlign.center)),
                Expanded(
                    child:
                        Text("productCategoryId", textAlign: TextAlign.center)),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return InkWell(
                onTap: () async {
                  dynamic result = await Navigator.pushNamed(
                      context, CategoryRoute,
                      arguments: FormArguments(
                          authenticate, null, catalog, categories[index]));
                  setState(() {
                    if (result is Catalog) categories = result?.categories;
                  });
                  HelperFunctions.showMessage(
                      context,
                      'Category ${categories[index].categoryName}  modified',
                      Colors.green);
                },
                onLongPress: () async {
                  bool result = await confirmDialog(
                      context,
                      "${categories[index].categoryName}",
                      "Delete this category?");
                  if (result) {
                    BlocProvider.of<CatalogBloc>(context)
                        .add(DeleteCategory(catalog, categories[index]));
                  }
                },
                child: ListTile(
                  //return  ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: categories[index]?.image != null
                        ? Image.memory(categories[index]?.image)
                        : Text(categories[index]?.categoryName[0]),
                  ),
                  title: Row(
                    children: <Widget>[
                      Expanded(
                          child: Text("${categories[index].categoryName}, "
                              "[${categories[index].categoryId}]")),
                      Expanded(
                          child: Text("${categories[index].categoryId}",
                              textAlign: TextAlign.center)),
                    ],
                  ),
                ),
              );
            },
            childCount: categories == null ? 0 : categories?.length,
          ),
        ),
      ],
    );
  }
}
