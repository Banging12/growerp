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
import 'package:core/blocs/@blocs.dart';
import 'package:models/@models.dart';
import 'package:core/helper_functions.dart';
import 'package:core/widgets/@widgets.dart';
import 'package:responsive_framework/responsive_framework.dart';

class AccntForm extends StatelessWidget {
  final FormArguments formArguments;
  AccntForm(this.formArguments);

  @override
  Widget build(BuildContext context) {
    var a = (formArguments) => (AccntPage(formArguments?.message));
    return ShowNavigationRail(a(formArguments), 0);
  }
}

class AccntPage extends StatelessWidget {
  final String message;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  AccntPage([this.message]) {
    HelperFunctions.showTopMessage(scaffoldMessengerKey, message);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthProblem) {
        return Container(
            child: Center(
                child: Text("${state.errorMessage}",
                    style:
                        new TextStyle(fontSize: 18.0, color: Colors.black))));
      }
      if (state is AuthAuthenticated) {
        Authenticate authenticate = state.authenticate;
        return ScaffoldMessenger(
            key: scaffoldMessengerKey,
            child: Scaffold(
                appBar: AppBar(
                  key: Key('AccntPageAuth'),
                  automaticallyImplyLeading:
                      ResponsiveWrapper.of(context).isSmallerThan(TABLET),
                  title: companyLogo(context, authenticate,
                      authenticate?.company?.name ?? 'Company??'),
                ),
                drawer: myDrawer(context, authenticate),
                body: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  child: GridView.count(
                    crossAxisCount:
                        ResponsiveWrapper.of(context).isSmallerThan(TABLET)
                            ? 2
                            : 3,
                    padding: EdgeInsets.all(3.0),
                    children: <Widget>[
                      makeDashboardItem(
                        context,
                        MenuItem(
                            title: "Open Sales Invoices",
                            selectedImage: "assets/images/accounting.png"),
                        "Sls open inv: "
                            "${authenticate.company.currencyId} "
                            "${authenticate.stats.salesInvoicesNotPaidAmount}"
                            "(${authenticate.stats.salesInvoicesNotPaidCount})",
                        "",
                        "",
                        "",
                      ),
                      makeDashboardItem(
                        context,
                        MenuItem(
                            title: "Open purchase invoices",
                            selectedImage: "assets/images/accounting.png"),
                        "Pur unp inv: "
                            "${authenticate.company.currencyId} "
                            "${authenticate.stats.purchInvoicesNotPaidAmount}"
                            "(${authenticate.stats.purchInvoicesNotPaidCount})",
                        "",
                        "",
                        "",
                      ),
                      makeDashboardItem(
                        context,
                        MenuItem(
                            title: "Profit/Loss",
                            selectedImage: "assets/images/accounting.png"),
                        "Income",
                        "Spending",
                        "",
                        "",
                      ),
                      makeDashboardItem(
                        context,
                        MenuItem(
                            title: "Bank accounts",
                            selectedImage: "assets/images/accounting.png"),
                        "Bank1",
                        "Bank2",
                        "",
                        "",
                      ),
                      makeDashboardItem(
                        context,
                        MenuItem(
                            title: "Balance Sheet",
                            selectedImage: "assets/images/accounting.png"),
                        "Assets",
                        "Liabilities",
                        "Expenses",
                        "Owners Equity",
                      ),
                      makeDashboardItem(
                        context,
                        MenuItem(
                            title: "Ledger",
                            selectedImage: "assets/images/accounting.png"),
                        "Accounts",
                        "Transactions",
                        "",
                        "",
                      ),
                    ],
                  ),
                )));
      }
      return LoadingIndicator();
    });
  }
}
