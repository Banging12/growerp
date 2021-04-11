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

import 'package:core/templates/companyLogo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/blocs/@blocs.dart';
import 'package:models/@models.dart';
import 'package:core/widgets/@widgets.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:core/templates/@templates.dart';
import '../menuItem_data.dart';

class HomeForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthAuthenticated) {
        Authenticate authenticate = state.authenticate!;
        return DisplayMenuItem(
          menuList: menuItems,
          menuIndex: 0,
          actions: <Widget>[
            IconButton(
                key: Key('aboutButton'),
                icon: Image.asset('assets/images/about.png'),
                tooltip: 'About',
                onPressed: () => {
                      Navigator.pushNamed(context, '/about'),
                    }),
            if (authenticate.apiKey != null)
              IconButton(
                  key: Key('logoutButton'),
                  icon: Icon(Icons.do_not_disturb),
                  tooltip: 'Logout',
                  onPressed: () => {
                        BlocProvider.of<AuthBloc>(context).add(Logout()),
                      }),
          ],
        );
      }

      if (state is AuthUnauthenticated) {
        final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
            GlobalKey<ScaffoldMessengerState>();
        Authenticate? authenticate = state.authenticate;
        return ScaffoldMessenger(
            key: scaffoldMessengerKey,
            child: Scaffold(
                appBar: AppBar(
                    key: Key('DashBoardUnAuth'),
                    title: companyLogo(context, authenticate,
                        authenticate?.company?.name ?? 'Company??')),
                body: Center(
                    child: Column(children: <Widget>[
                  SizedBox(height: 100),
                  Text("Login with an existing Id"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    key: Key('loginButton'),
                    autofocus: true,
                    child: Text('Login'),
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/login');
                    },
                  ),
                  SizedBox(height: 50),
                  Text(
                      "Or create a new company and you being the administrator"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    key: Key('newCompButton'),
                    child: Text('Create a new company and admin'),
                    onPressed: () {
                      authenticate!.company = null;
                      Navigator.popAndPushNamed(context, '/register');
                    },
                  ),
                ]))));
      }
      return LoadingIndicator();
    });
  }
}
