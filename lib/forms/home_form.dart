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

class HomeForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthAuthenticated) {
        Authenticate authenticate = state.authenticate!;
        return MainTemplate(
            menu: menuItems,
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
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              child: GridView.count(
                crossAxisCount:
                    ResponsiveWrapper.of(context).isSmallerThan(TABLET) ? 2 : 3,
                padding: EdgeInsets.all(3.0),
                children: <Widget>[
                  makeDashboardItem(
                    context,
                    menuItems[1],
                    authenticate.company!.name!.length > 20
                        ? "${authenticate.company!.name!.substring(0, 20)}..."
                        : "${authenticate.company!.name}",
                    "Administrators: ${authenticate.stats!.admins}",
                    "Employees: ${authenticate.stats!.employees}",
                    "",
                  ),
                  makeDashboardItem(
                    context,
                    menuItems[2],
                    "All Opportunities: ${authenticate.stats!.opportunities}",
                    "My Opportunities: ${authenticate.stats!.myOpportunities}",
                    "Leads: ${authenticate.stats!.leads}",
                    "Customers: ${authenticate.stats!.customers}",
                  ),
                  makeDashboardItem(
                    context,
                    menuItems[3],
                    "Categories: ${authenticate.stats!.categories}",
                    "Products: ${authenticate.stats!.products}",
                    "",
                    "",
                  ),
                  makeDashboardItem(
                    context,
                    menuItems[4],
                    "Orders: ${authenticate.stats!.openSlsOrders}",
                    "Customers: ${authenticate.stats!.customers}",
                    "",
                    "",
                  ),
                  makeDashboardItem(
                    context,
                    menuItems[6],
                    "Sls open inv: "
                        "${authenticate.company!.currencyId} "
                        "${authenticate.stats!.salesInvoicesNotPaidAmount}"
                        "(${authenticate.stats!.salesInvoicesNotPaidCount})",
                    "Pur unp inv: "
                        "${authenticate.company!.currencyId} "
                        "${authenticate.stats!.purchInvoicesNotPaidAmount}"
                        "(${authenticate.stats!.purchInvoicesNotPaidCount})",
                    "",
                    "",
                  ),
                  makeDashboardItem(
                    context,
                    menuItems[5],
                    "Orders: ${authenticate.stats!.openPurOrders}",
                    "Suppliers: ${authenticate.stats!.suppliers}",
                    "",
                    "",
                  ),
                ],
              ),
            ));
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
                  SizedBox(height: 150),
                  Text("Login with an existing Id"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    key: Key('loginButton'),
                    autofocus: true,
                    child: Text('Login'),
                    onPressed: () async {
                      dynamic result =
                          await Navigator.pushNamed(context, '/login');
                      if (result)
                        Navigator.pushNamed(context, '/',
                            arguments: FormArguments(
                                message: "Successfully logged in."));
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
                      BlocProvider.of<AuthBloc>(context)
                          .add(UpdateAuth(authenticate));
                      Navigator.popAndPushNamed(context, '/register');
                    },
                  ),
                ]))));
      }
      return LoadingIndicator();
    });
  }
}
