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

import 'package:core/domains/common/functions/helper_functions.dart';
import 'package:core/domains/domains.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:core/templates/@templates.dart';
import 'package:global_configuration/global_configuration.dart';

class HomeForm extends StatefulWidget {
  final String? message;
  final List<MenuItem> menuItems;
  final String title;

  const HomeForm(
      {Key? key, this.message, required this.menuItems, this.title = "GrowERP"})
      : super(key: key);
  @override
  _HomeFormState createState() => _HomeFormState(message);
}

class _HomeFormState extends State<HomeForm> {
  final String? message;
  String singleCompany = GlobalConfiguration().get("singleCompany");

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  _HomeFormState(this.message) {
    HelperFunctions.showTopMessage(scaffoldMessengerKey, message, 4);
  }

  @override
  Widget build(BuildContext context) {
    bool isPhone = ResponsiveWrapper.of(context).isSmallerThan(TABLET);
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      switch (state.status) {
        case AuthStatus.authenticated:
          Authenticate authenticate = state.authenticate!;
          return DisplayMenuItem(
            scaffoldMessengerKey: scaffoldMessengerKey,
            menuList: widget.menuItems,
            menuIndex: 0,
            actions: <Widget>[
              if (authenticate.apiKey != null)
                IconButton(
                    key: Key('logoutButton'),
                    icon: Icon(Icons.do_not_disturb, key: Key('HomeFormAuth')),
                    tooltip: 'Logout',
                    onPressed: () => {
                          BlocProvider.of<AuthBloc>(context)
                              .add(AuthLoggedOut()),
                        }),
            ],
          );
        case AuthStatus.unAuthenticated:
          Authenticate authenticate = state.authenticate!;
          return ScaffoldMessenger(
              key: scaffoldMessengerKey,
              child: Scaffold(
                  appBar: AppBar(
                      key: Key('HomeFormUnAuth'),
                      title: appBarTitle(
                          context,
                          authenticate,
                          'Login' +
                              (singleCompany.isEmpty ? ' / New company' : ''))),
                  body: Center(
                      child: Column(children: <Widget>[
                    SizedBox(height: 100),
                    InkWell(
                        onLongPress: () {
                          BlocProvider.of<AuthBloc>(context)
                              .add(AuthChangedIp());
                        },
                        child: Text(widget.title,
                            style: TextStyle(
                                fontSize: isPhone ? 15 : 25,
                                color: Colors.black,
                                fontWeight: FontWeight.bold))),
                    SizedBox(height: 40),
                    authenticate.company?.partyId != null
                        ? ElevatedButton(
                            key: Key('loginButton'),
                            child: Text('Login with an Existing ID'),
                            onPressed: () async {
                              await showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return LoginDialog();
                                  });
                            })
                        : Text('No companies yet, create one!'),
                    SizedBox(height: 100),
                    Visibility(
                        visible: singleCompany.isEmpty,
                        child: ElevatedButton(
                            key: Key('newCompButton'),
                            child: Text('Create a new company and admin'),
                            onPressed: () async {
                              await showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return NewCompanyDialog(
                                        formArguments: FormArguments(
                                            object: authenticate.copyWith(
                                                company: null)));
                                  });
                            })),
                  ]))));
        default:
          return LoadingIndicator();
      }
    });
  }
}
