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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:models/@models.dart';
import 'package:core/blocs/@blocs.dart';
import 'package:core/helper_functions.dart';
import 'package:core/widgets/@widgets.dart';

class CategoryForm extends StatelessWidget {
  final FormArguments formArguments;
  CategoryForm(this.formArguments);

  @override
  Widget build(BuildContext context) {
    var a = (formArguments) =>
        (MyCategoryPage(formArguments.message, formArguments.object));
    return ShowNavigationRail(a(formArguments), 3);
  }
}

class MyCategoryPage extends StatefulWidget {
  final String message;
  final ProductCategory category;
  MyCategoryPage(this.message, this.category);
  @override
  _MyCategoryState createState() => _MyCategoryState(message, category);
}

class _MyCategoryState extends State<MyCategoryPage> {
  final String message;
  final ProductCategory category;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descrController = TextEditingController();

  bool loading = false;
  ProductCategory updatedCategory;
  PickedFile _imageFile;
  dynamic _pickImageError;
  String _retrieveDataError;

  final ImagePicker _picker = ImagePicker();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  _MyCategoryState(this.message, this.category) {
    HelperFunctions.showTopMessage(scaffoldMessengerKey, message);
  }

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
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
      _retrieveDataError = response.exception.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    Authenticate authenticate;
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthAuthenticated) authenticate = state.authenticate;
      return ScaffoldMessenger(
          key: scaffoldMessengerKey,
          child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading:
                    ResponsiveWrapper.of(context).isSmallerThan(TABLET),
                title: companyLogo(context, authenticate, 'Category detail'),
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.home),
                      onPressed: () => Navigator.pushNamed(context, '/home'))
                ],
              ),
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 100),
                  FloatingActionButton(
                    onPressed: () {
                      _onImageButtonPressed(ImageSource.gallery,
                          context: context);
                    },
                    heroTag: 'image0',
                    tooltip: 'Pick Image from gallery',
                    child: const Icon(Icons.photo_library),
                  ),
                  SizedBox(height: 20),
                  Visibility(
                    visible: !kIsWeb,
                    child: FloatingActionButton(
                      onPressed: () {
                        _onImageButtonPressed(ImageSource.camera,
                            context: context);
                      },
                      heroTag: 'image1',
                      tooltip: 'Take a Photo',
                      child: const Icon(Icons.camera_alt),
                    ),
                  )
                ],
              ),
              drawer: myDrawer(context, authenticate),
              body: BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthProblem)
                      HelperFunctions.showMessage(
                          context, '${state.errorMessage}', Colors.red);
                  },
                  child: BlocListener<CategoryBloc, CategoryState>(
                      listener: (context, state) {
                    if (state is CategoryProblem) {
                      loading = false;
                      HelperFunctions.showMessage(
                          context, '${state.errorMessage}', Colors.red);
                    }
                    if (state is CategorySuccess) Navigator.of(context).pop();
                  }, child: Builder(builder: (BuildContext context) {
                    return Center(
                      child: !kIsWeb &&
                              defaultTargetPlatform == TargetPlatform.android
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
                                return _showForm();
                              })
                          : _showForm(),
                    );
                  })))));
    });
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Widget _showForm() {
    _nameController..text = category?.categoryName;
    _descrController..text = category?.description;
    final Text retrieveError = _getRetrieveErrorWidget();
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
                              ? Image.network(_imageFile.path)
                              : Image.file(File(_imageFile.path))
                          : category?.image != null
                              ? Image.memory(category?.image)
                              : Text(
                                  category?.categoryName?.substring(0, 1) ?? '',
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.black))),
                  SizedBox(height: 30),
                  TextFormField(
                    key: Key('name'),
                    decoration: InputDecoration(labelText: 'Category Name'),
                    controller: _nameController,
                    validator: (value) {
                      if (value.isEmpty) return 'Please enter a category name?';
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    key: Key('descr'),
                    decoration: InputDecoration(labelText: 'Description'),
                    controller: _descrController,
                    maxLines: 5,
                    validator: (value) {
                      if (value.isEmpty)
                        return 'Please enter a category description?';
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  RaisedButton(
                      key: Key('update'),
                      child: Text(
                          category?.categoryId == null ? 'Create' : 'Update'),
                      onPressed: () async {
                        if (_formKey.currentState.validate() && !loading) {
                          updatedCategory = ProductCategory(
                              categoryId: category?.categoryId,
                              categoryName: _nameController.text,
                              description: _descrController.text,
                              image: await HelperFunctions.getResizedImage(
                                  _imageFile?.path));
                          BlocProvider.of<CategoryBloc>(context)
                              .add(UpdateCategory(
                            updatedCategory,
                          ));
                        }
                      }),
                  SizedBox(height: 20),
                  RaisedButton(
                      key: Key('cancel'),
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ]))));
  }
}
